# Caching — Full Reference

Official source: https://square.github.io/okhttp/features/caching/

Complete guide to HTTP response caching in OkHttp.

## Basic Usage

Cache is **off by default**. Enable it explicitly:

```java
OkHttpClient client = new OkHttpClient.Builder()
    .cache(new Cache(
        new File("cache-dir"),
        50L * 1024L * 1024L // 50 MiB
    ))
    .build();
```

## EventListener Cache Events

### Cache Hit

Cache fulfilled the request without network call. Skips DNS, connecting, body download.

```
CallStart
CacheHit
CallEnd
```

**Note:** OkHttp defaults document max age to 10% of the document's age based on `Last-Modified`. Default expiration is not used for URIs with query strings.

### Cache Miss

Normal request events plus cache presence indicator.

```
CallStart
CacheMiss
ProxySelectStart
... Standard Events ...
CallEnd
```

### Conditional Cache Hit

Cache checks if result is still valid. If 304 Not Modified, cache response is used.

```
CallStart
CacheConditionalHit
ConnectionAcquired
... Standard Events ...
ResponseBodyEnd (0 bytes)
CacheHit
ConnectionReleased
CallEnd
```

## Cache Directory

The cache directory must be exclusively owned by a single Cache instance.

**Delete cache:**
```java
cache.delete();
```

**Note:** Deleting removes all cached data. Cache is designed to persist between app restarts.

## Pruning the Cache

**Evict all entries:**
```java
cache.evictAll();
```

**Remove specific URLs:**
```java
Iterator<String> urlIterator = cache.urls();
while (urlIterator.hasNext()) {
    if (urlIterator.next().startsWith("https://api.example.com/")) {
        urlIterator.remove();
    }
}
```

This is typical after user-initiated pull-to-refresh.

## Troubleshooting

**Problem:** Valid cacheable responses are not being cached.

**Solution:** Ensure responses are read fully. Responses that are not fully read, cancelled, or stalled will not be cached.

**Problem:** Need to override cache behavior.

**Solution:** Use interceptors to modify `Cache-Control` headers.
