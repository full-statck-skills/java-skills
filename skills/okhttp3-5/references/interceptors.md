# Interceptors — Full Reference

Official source: https://square.github.io/okhttp/features/interceptors/

Complete guide to interceptors in OkHttp.

## Basic Interceptor

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
```

**Key:** `chain.proceed(request)` is where all HTTP work happens. Call it exactly once per interceptor (unless retrying).

## Application Interceptors

Registered via `addInterceptor()`:

```java
OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new LoggingInterceptor())
    .build();
```

**Characteristics:**
- Called once, even for cached responses
- Sees the original application request
- Unconcerned with OkHttp-injected headers
- Can short-circuit (not call `chain.proceed()`)
- Can retry (call `chain.proceed()` multiple times)
- Can adjust timeouts via `withConnectTimeout`, `withReadTimeout`, `withWriteTimeout`

## Network Interceptors

Registered via `addNetworkInterceptor()`:

```java
OkHttpClient client = new OkHttpClient.Builder()
    .addNetworkInterceptor(new LoggingInterceptor())
    .build();
```

**Characteristics:**
- Called for each network call (redirects, retries)
- NOT invoked for cached responses
- Sees data as transmitted over network
- Access to Connection (IP address, TLS config)

## Choosing Between Application and Network

| Feature | Application | Network |
|---------|-------------|---------|
| Called for redirects/retries | No | Yes |
| Called for cached responses | Yes | No |
| Sees original request | Yes | No |
| Sees OkHttp-added headers | No | Yes |
| Access to Connection | No | Yes |
| Can short-circuit | Yes | No |
| Can adjust timeouts | Yes | No |

## Rewriting Requests

Add, remove, or replace headers. Transform body.

**Gzip request compression:**
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
```

## Rewriting Responses

Rewrite response headers or transform body.

**Cache-Control override:**
```java
Interceptor rewriteCacheControl = new Interceptor() {
    @Override
    public Response intercept(Interceptor.Chain chain) throws IOException {
        Response originalResponse = chain.proceed(chain.request());
        return originalResponse.newBuilder()
            .header("Cache-Control", "max-age=60")
            .build();
    }
};
```

**Warning:** Rewriting responses may violate server expectations. Use with caution.

## Built-in Logging Interceptor

```groovy
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
