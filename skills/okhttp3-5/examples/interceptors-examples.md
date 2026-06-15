# Interceptor Examples

## Logging Interceptor (Built-in)

```groovy
// Gradle
implementation("com.squareup.okhttp3:logging-interceptor:5.4.0")
```

```java
import okhttp3.logging.HttpLoggingInterceptor;

HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
logging.setLevel(HttpLoggingInterceptor.Level.BODY); // NONE, BASIC, HEADERS, BODY

OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(logging)
    .build();
```

**Log levels:**
- `NONE` — no logging
- `BASIC` — request/response line
- `HEADERS` — request/response line + headers
- `BODY` — request/response line + headers + body

## Custom Logging Interceptor

```java
class LoggingInterceptor implements Interceptor {
    @Override
    public Response intercept(Interceptor.Chain chain) throws IOException {
        Request request = chain.request();

        long t1 = System.nanoTime();
        logger.info(String.format("Sending request %s on %s%n%s",
            request.url(), chain.connection(), request.headers()));

        Response response = chain.proceed(request);

        long t2 = System.nanoTime();
        logger.info(String.format("Received response for %s in %.1fms%n%s",
            response.request().url(), (t2 - t1) / 1e6d, response.headers()));

        return response;
    }
}

OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new LoggingInterceptor())
    .build();
```

## Gzip Request Compression

```java
class GzipRequestInterceptor implements Interceptor {
    @Override
    public Response intercept(Interceptor.Chain chain) throws IOException {
        Request originalRequest = chain.request();
        if (originalRequest.body() == null || originalRequest.header("Content-Encoding") != null) {
            return chain.proceed(originalRequest);
        }

        Request compressed = originalRequest.newBuilder()
            .header("Content-Encoding", "gzip")
            .method(originalRequest.method(), gzip(originalRequest.body()))
            .build();
        return chain.proceed(compressed);
    }

    private RequestBody gzip(final RequestBody body) {
        return new RequestBody() {
            @Override public MediaType contentType() { return body.contentType(); }
            @Override public long contentLength() { return -1; }
            @Override public void writeTo(BufferedSink sink) throws IOException {
                BufferedSink gzipSink = Okio.buffer(new GzipSink(sink));
                body.writeTo(gzipSink);
                gzipSink.close();
            }
        };
    }
}

OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new GzipRequestInterceptor())
    .build();
```

## Cache-Control Rewrite Interceptor

```java
// Force 60-second cache for all responses
Interceptor rewriteCacheControl = new Interceptor() {
    @Override
    public Response intercept(Interceptor.Chain chain) throws IOException {
        Response originalResponse = chain.proceed(chain.request());
        return originalResponse.newBuilder()
            .header("Cache-Control", "max-age=60")
            .build();
    }
};

OkHttpClient client = new OkHttpClient.Builder()
    .addNetworkInterceptor(rewriteCacheControl)
    .build();
```

## Authentication Interceptor

```java
class AuthInterceptor implements Interceptor {
    private final String token;

    AuthInterceptor(String token) {
        this.token = token;
    }

    @Override
    public Response intercept(Interceptor.Chain chain) throws IOException {
        Request originalRequest = chain.request();
        Request authenticatedRequest = originalRequest.newBuilder()
            .header("Authorization", "Bearer " + token)
            .build();
        return chain.proceed(authenticatedRequest);
    }
}

OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new AuthInterceptor("my-api-token"))
    .build();
```

## Application vs Network Interceptor

```java
// Application interceptor — runs once (even for cache)
OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new LoggingInterceptor())
    .build();

// Network interceptor — runs for each network call
OkHttpClient client = new OkHttpClient.Builder()
    .addNetworkInterceptor(new LoggingInterceptor())
    .build();
```

**Key differences:**
- Application: sees original request, runs once, can short-circuit
- Network: sees network data, runs per call, has access to Connection
