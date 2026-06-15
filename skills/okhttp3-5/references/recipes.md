# Recipes — Common Patterns

Official source: https://square.github.io/okhttp/recipes/

## Synchronous GET

```java
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("https://publicobject.com/helloworld.txt")
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

        Headers responseHeaders = response.headers();
        for (int i = 0; i < responseHeaders.size(); i++) {
            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
        }

        System.out.println(response.body().string());
    }
}
```

## Asynchronous GET

```java
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://publicobject.com/helloworld.txt")
        .build();

    client.newCall(request).enqueue(new Callback() {
        @Override public void onFailure(Call call, IOException e) {
            e.printStackTrace();
        }

        @Override public void onResponse(Call call, Response response) throws IOException {
            try (ResponseBody responseBody = response.body()) {
                if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

                Headers responseHeaders = response.headers();
                for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                    System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                }

                System.out.println(responseBody.string());
            }
        }
    });
}
```

## Accessing Headers

```java
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("https://api.github.com/repos/square/okhttp/issues")
        .header("User-Agent", "OkHttp Headers.java")
        .addHeader("Accept", "application/json; q=0.5")
        .addHeader("Accept", "application/vnd.github.v3+json")
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

        System.out.println("Server: " + response.header("Server"));
        System.out.println("Date: " + response.header("Date"));
        System.out.println("Vary: " + response.headers("Vary"));
    }
}
```

**Header API:**
- `header(name, value)` — sets the only occurrence (removes existing)
- `addHeader(name, value)` — adds without removing existing
- `header(name)` — returns last occurrence (or null)
- `headers(name)` — returns all values as list

## Posting a String

```java
public static final MediaType MEDIA_TYPE_MARKDOWN
    = MediaType.parse("text/x-markdown; charset=utf-8");

private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    String postBody = ""
        + "Releases\n"
        + "--------\n"
        + "\n"
        + " * _1.0_ May 6, 2013\n"
        + " * _1.1_ June 15, 2013\n"
        + " * _1.2_ August 11, 2013\n";

    Request request = new Request.Builder()
        .url("https://api.github.com/markdown/raw")
        .post(RequestBody.create(MEDIA_TYPE_MARKDOWN, postBody))
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

## Post Streaming

```java
public static final MediaType MEDIA_TYPE_MARKDOWN
    = MediaType.parse("text/x-markdown; charset=utf-8");

private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    RequestBody requestBody = new RequestBody() {
        @Override public MediaType contentType() {
            return MEDIA_TYPE_MARKDOWN;
        }

        @Override public void writeTo(BufferedSink sink) throws IOException {
            sink.writeUtf8("Numbers\n");
            sink.writeUtf8("-------\n");
            for (int i = 2; i <= 997; i++) {
                sink.writeUtf8(String.format(" * %s = %s\n", i, factor(i)));
            }
        }

        private String factor(int n) {
            for (int i = 2; i < n; i++) {
                int x = n / i;
                if (x * i == n) return factor(x) + " × " + i;
            }
            return Integer.toString(n);
        }
    };

    Request request = new Request.Builder()
        .url("https://api.github.com/markdown/raw")
        .post(requestBody)
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

## Posting a File

```java
public static final MediaType MEDIA_TYPE_MARKDOWN
    = MediaType.parse("text/x-markdown; charset=utf-8");

private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    File file = new File("README.md");

    Request request = new Request.Builder()
        .url("https://api.github.com/markdown/raw")
        .post(RequestBody.create(MEDIA_TYPE_MARKDOWN, file))
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

## Posting Form Parameters

```java
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    RequestBody formBody = new FormBody.Builder()
        .add("search", "Jurassic Park")
        .build();
    Request request = new Request.Builder()
        .url("https://en.wikipedia.org/w/index.php")
        .post(formBody)
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

## Posting a Multipart Request

```java
private static final String IMGUR_CLIENT_ID = "9199fdef135c122";
private static final MediaType MEDIA_TYPE_PNG = MediaType.get("image/png");

private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    RequestBody requestBody = new MultipartBody.Builder()
        .setType(MultipartBody.FORM)
        .addFormDataPart("title", "Square Logo")
        .addFormDataPart("image", "logo-square.png",
            RequestBody.create(new File("docs/images/logo-square.png"), MEDIA_TYPE_PNG))
        .build();

    Request request = new Request.Builder()
        .header("Authorization", "Client-ID " + IMGUR_CLIENT_ID)
        .url("https://api.imgur.com/3/image")
        .post(requestBody)
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

## Parse a JSON Response With Moshi

```java
private final OkHttpClient client = new OkHttpClient();
private final Moshi moshi = new Moshi.Builder().build();
private final JsonAdapter<Gist> gistJsonAdapter = moshi.adapter(Gist.class);

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("https://api.github.com/gists/c2a7c39532239ff261be")
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

        Gist gist = gistJsonAdapter.fromJson(response.body().source());
        for (Map.Entry<String, GistFile> entry : gist.files.entrySet()) {
            System.out.println(entry.getKey());
            System.out.println(entry.getValue().content);
        }
    }
}
```

## Response Caching

```java
private final OkHttpClient client;

public CacheResponse(File cacheDirectory) throws Exception {
    int cacheSize = 10 * 1024 * 1024; // 10 MiB
    Cache cache = new Cache(cacheDirectory, cacheSize);

    client = new OkHttpClient.Builder()
        .cache(cache)
        .build();
}

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://publicobject.com/helloworld.txt")
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

        System.out.println("Response 1 response:          " + response);
        System.out.println("Response 1 cache response:    " + response.cacheResponse());
        System.out.println("Response 1 network response:  " + response.networkResponse());
    }
}
```

## Canceling a Call

```java
private final ScheduledExecutorService executor = Executors.newScheduledThreadPool(1);
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://httpbin.org/delay/2") // This URL is served with a 2 second delay.
        .build();

    final long startNanos = System.nanoTime();
    final Call call = client.newCall(request);

    // Schedule a job to cancel the call in 1 second.
    executor.schedule(new Runnable() {
        @Override public void run() {
            System.out.printf("%.2f Canceling call.%n", (System.nanoTime() - startNanos) / 1e9f);
            call.cancel();
            System.out.printf("%.2f Canceled call.%n", (System.nanoTime() - startNanos) / 1e9f);
        }
    }, 1, TimeUnit.SECONDS);

    System.out.printf("%.2f Executing call.%n", (System.nanoTime() - startNanos) / 1e9f);
    try (Response response = call.execute()) {
        System.out.printf("%.2f Call was expected to fail, but completed: %s%n",
            (System.nanoTime() - startNanos) / 1e9f, response);
    } catch (IOException e) {
        System.out.printf("%.2f Call failed as expected: %s%n",
            (System.nanoTime() - startNanos) / 1e9f, e);
    }
}
```

## Timeouts

```java
private final OkHttpClient client;

public ConfigureTimeouts() throws Exception {
    client = new OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .writeTimeout(10, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build();
}

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://httpbin.org/delay/2") // This URL is served with a 2 second delay.
        .build();

    try (Response response = client.newCall(request).execute()) {
        System.out.println("Response completed: " + response);
    }
}
```

## Per-call Configuration

```java
private final OkHttpClient client = new OkHttpClient();

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://httpbin.org/delay/1") // This URL is served with a 1 second delay.
        .build();

    // Copy to customize OkHttp for this request.
    OkHttpClient client1 = client.newBuilder()
        .readTimeout(500, TimeUnit.MILLISECONDS)
        .build();
    try (Response response = client1.newCall(request).execute()) {
        System.out.println("Response 1 succeeded: " + response);
    } catch (IOException e) {
        System.out.println("Response 1 failed: " + e);
    }

    // Copy to customize OkHttp for this request.
    OkHttpClient client2 = client.newBuilder()
        .readTimeout(3000, TimeUnit.MILLISECONDS)
        .build();
    try (Response response = client2.newCall(request).execute()) {
        System.out.println("Response 2 succeeded: " + response);
    } catch (IOException e) {
        System.out.println("Response 2 failed: " + e);
    }
}
```

## Handling Authentication

```java
private final OkHttpClient client;

public Authenticate() {
    client = new OkHttpClient.Builder()
        .authenticator(new Authenticator() {
            @Override public Request authenticate(Route route, Response response) throws IOException {
                if (response.request().header("Authorization") != null) {
                    return null; // Give up, we've already attempted to authenticate.
                }

                System.out.println("Authenticating for response: " + response);
                System.out.println("Challenges: " + response.challenges());
                String credential = Credentials.basic("jesse", "password1");
                return response.request().newBuilder()
                    .header("Authorization", credential)
                    .build();
            }
        })
        .build();
}

public void run() throws Exception {
    Request request = new Request.Builder()
        .url("http://publicobject.com/secrets/hellosecret.txt")
        .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }
}
```

**Avoid infinite retries:**
```java
if (credential.equals(response.request().header("Authorization"))) {
    return null; // If we already failed with these credentials, don't retry.
}
```

## Upload Progress

```java
public final class UploadProgress {
    private static final String IMGUR_CLIENT_ID = "9199fdef135c122";
    private static final MediaType MEDIA_TYPE_PNG = MediaType.get("image/png");

    private final OkHttpClient client = new OkHttpClient();

    public void run() throws Exception {
        final ProgressListener progressListener = new ProgressListener() {
            boolean firstUpdate = true;

            @Override public void update(long bytesWritten, long contentLength, boolean done) {
                if (done) {
                    System.out.println("completed");
                } else {
                    if (firstUpdate) {
                        firstUpdate = false;
                        if (contentLength == -1) {
                            System.out.println("content-length: unknown");
                        } else {
                            System.out.format("content-length: %d\n", contentLength);
                        }
                    }
                    System.out.println(bytesWritten);
                    if (contentLength != -1) {
                        System.out.format("%d%% done\n", (100 * bytesWritten) / contentLength);
                    }
                }
            }
        };

        RequestBody requestBody = RequestBody.create(
            new File("docs/images/logo-square.png"), MEDIA_TYPE_PNG);

        Request request = new Request.Builder()
            .header("Authorization", "Client-ID " + IMGUR_CLIENT_ID)
            .url("https://api.imgur.com/3/image")
            .post(new ProgressRequestBody(requestBody, progressListener))
            .build();

        Response response = client.newCall(request).execute();
        if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
        System.out.println(response.body().string());
    }

    private static class ProgressRequestBody extends RequestBody {
        private final ProgressListener progressListener;
        private final RequestBody delegate;

        public ProgressRequestBody(RequestBody delegate, ProgressListener progressListener) {
            this.delegate = delegate;
            this.progressListener = progressListener;
        }

        @Override public MediaType contentType() { return delegate.contentType(); }
        @Override public long contentLength() throws IOException { return delegate.contentLength(); }

        @Override public void writeTo(BufferedSink sink) throws IOException {
            BufferedSink bufferedSink = Okio.buffer(sink(sink));
            delegate.writeTo(bufferedSink);
            bufferedSink.flush();
        }

        public Sink sink(Sink sink) {
            return new ForwardingSink(sink) {
                private long totalBytesWritten = 0L;
                private boolean completed = false;

                @Override public void write(Buffer source, long byteCount) throws IOException {
                    super.write(source, byteCount);
                    totalBytesWritten += byteCount;
                    progressListener.update(totalBytesWritten, contentLength(), completed);
                }

                @Override public void close() throws IOException {
                    super.close();
                    if (!completed) {
                        completed = true;
                        progressListener.update(totalBytesWritten, contentLength(), completed);
                    }
                }
            };
        }
    }

    interface ProgressListener {
        void update(long bytesWritten, long contentLength, boolean done);
    }
}
```
