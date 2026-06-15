# Caching Examples

## Basic Cache Configuration

```java
OkHttpClient client = new OkHttpClient.Builder()
    .cache(new Cache(
        new File("cache-dir"),
        50L * 1024L * 1024L // 50 MiB
    ))
    .build();
```

## Android Cache

```java
OkHttpClient client = new OkHttpClient.Builder()
    .cache(new Cache(
        new File(application.getCacheDir(), "http_cache"),
        50L * 1024L * 1024L // 50 MiB
    ))
    .build();
```

## Conditional Caching with EventListener

```java
EventListener.Factory factory = new EventListener.Factory() {
    @Override
    public EventListener create(Call call) {
        return new EventListener() {
            @Override
            public void cacheHit(Call call, Response response) {
                System.out.println("Cache hit: " + call.request().url());
            }

            @Override
            public void cacheMiss(Call call) {
                System.out.println("Cache miss: " + call.request().url());
            }

            @Override
            public void cacheConditionalHit(Call call, Response response) {
                System.out.println("Conditional hit: " + call.request().url());
            }
        };
    }
};

OkHttpClient client = new OkHttpClient.Builder()
    .cache(new Cache(new File("cache-dir"), 50L * 1024L * 1024L))
    .eventListenerFactory(factory)
    .build();
```

## Evict All Cache

```java
Cache cache = new Cache(new File("cache-dir"), 50L * 1024L * 1024L);
cache.evictAll();
```

## Remove Specific URLs from Cache

```java
Cache cache = new Cache(new File("cache-dir"), 50L * 1024L * 1024L);

Iterator<String> urlIterator = cache.urls();
while (urlIterator.hasNext()) {
    if (urlIterator.next().startsWith("https://api.example.com/")) {
        urlIterator.remove();
    }
}
```

## Delete Cache Directory

```java
Cache cache = new Cache(new File("cache-dir"), 50L * 1024L * 1024L);
cache.delete();
```

## Override Cache-Control via Interceptor

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
    .cache(new Cache(new File("cache-dir"), 50L * 1024L * 1024L))
    .addNetworkInterceptor(rewriteCacheControl)
    .build();
```

## Troubleshooting

**Problem:** Valid cacheable responses are not being cached.

**Solution:** Ensure responses are read fully. Partial reads won't cache.

```java
// ❌ Bad — response not fully read
Response response = client.newCall(request).execute();
System.out.println(response.code());
response.close();

// ✅ Good — response fully read
try (Response response = client.newCall(request).execute()) {
    String body = response.body().string();
    System.out.println(body);
}
```
