# Caching — Full Reference (Unirest 3.x)

Complete guide to HTTP response caching with Unirest-Java 3.x.

## Basic Cache

Enable with defaults:

```java
Unirest.config().cacheResponses(true);

// First request hits the network; second returns cached response
Unirest.get("https://somewhere").asString();
Unirest.get("https://somewhere").asString();
```

## Advanced Options

Customize eviction rules with a builder:

```java
Unirest.config().cacheResponses(Cache.builder()
    .depth(100)                      // Max number of entries cached
    .maxAge(5, TimeUnit.MINUTES));   // How long entries are kept
```

## Custom Caches

Implement the `Cache` interface to back with a dedicated cache like Guava or EHCache:

```java
public static void main(String[] args) {
    Unirest.config().cacheResponses(
        Cache.builder().backingCache(new GuavaCache()));
}

// Example backing cache using Guava
public static class GuavaCache implements Cache {
    com.google.common.cache.Cache<Key, HttpResponse> regular =
        CacheBuilder.newBuilder().build();
    com.google.common.cache.Cache<Key, CompletableFuture> async =
        CacheBuilder.newBuilder().build();

    @Override
    public <T> HttpResponse get(Key key, Supplier<HttpResponse<T>> fetcher) {
        try {
            return regular.get(key, fetcher::get);
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public <T> CompletableFuture getAsync(Key key, Supplier<CompletableFuture<HttpResponse<T>>> fetcher) {
        try {
            return async.get(key, fetcher::get);
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }
}
```

> ⚠️ In high-load systems, back the cache with a dedicated implementation like EHCache or Guava rather than using the default in-memory cache.
