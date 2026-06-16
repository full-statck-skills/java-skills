---
name: okhttp3-5.x
description: OkHttp 5.x HTTP client for Java/JVM 8+ and Android 5+. Use when making HTTP/HTTPS requests, building REST API clients, implementing connection pooling, response caching, request/response interceptors, certificate pinning, event monitoring, WebSocket connections, SSE consumption, or configuring TLS/cipher suites. Covers OkHttp 5.4.0 with HTTP/2, transparent GZIP, Fast Fallback (Happy Eyeballs), MockWebServer for testing, and GraalVM Native Image support.
---

# OkHttp 5.x Reference (v5.4.0)

OkHttp is an efficient HTTP client by default: HTTP/2 support, connection pooling, transparent GZIP, and response caching. It silently recovers from common connection problems and attempts alternate addresses when the first connect fails.

## Official Documentation Sources

All authoritative information is on the official OkHttp site:

| Topic | URL |
|-------|-----|
| **Overview** | https://square.github.io/okhttp/ |
| **Calls** | https://square.github.io/okhttp/features/calls/ |
| **Caching** | https://square.github.io/okhttp/features/caching/ |
| **Connections** | https://square.github.io/okhttp/features/connections/ |
| **Events** | https://square.github.io/okhttp/features/events/ |
| **HTTPS** | https://square.github.io/okhttp/features/https/ |
| **Interceptors** | https://square.github.io/okhttp/features/interceptors/ |
| **Recipes** | https://square.github.io/okhttp/recipes/ |
| **Security** | https://square.github.io/okhttp/security/ |
| **API Javadoc** | https://square.github.io/okhttp/5.x/okhttp/okhttp3/ |
| **MockWebServer** | https://square.github.io/okhttp/mockwebserver/ |
| **5.x Change Log** | https://square.github.io/okhttp/changelogs/changelog/ |
| **Maven Central** | https://central.sonatype.com/artifact/com.squareup.okhttp3/okhttp |
| **GitHub** | https://github.com/square/okhttp |

**RFC Standards followed by OkHttp:**
- HTTP Semantics — RFC 9110
- HTTP Caching — RFC 9111
- HTTP/1.1 — RFC 9112
- HTTP/2 — RFC 9113
- WebSockets — RFC 6455
- SSE — Server-sent events
- Happy Eyeballs — RFC 6555

## Capability Boundaries

### ✅ Strong Suits
1. HTTP/2 support — all requests to the same host share a socket
2. Connection pooling — reduces latency, automatic reuse
3. Transparent GZIP — shrinks download sizes automatically
4. Response caching — avoids network for repeat requests
5. Interceptors — monitor, rewrite, and retry calls (Application + Network layers)
6. Fast Fallback (Happy Eyeballs RFC 6555) — concurrent IPv4/IPv6 connection attempts
7. TLS 1.3, ALPN, certificate pinning
8. EventListener API — capture metrics on HTTP calls
9. MockWebServer — test HTTP/HTTPS/HTTP/2 clients
10. GraalVM Native Image support
11. Java 9 Modules support (5.2+)
12. BOM for dependency management

### ⚠️ Requirements
1. Java 8+ or Android 5.0+ (API level 21+)
2. Kotlin Multiplatform: Maven projects must use `okhttp-jvm` artifact (not `okhttp`)
3. Requires Okio and Kotlin stdlib (transitive dependencies)
4. For certificate pinning: server TLS admin coordination required

### ❌ Out of Scope (with alternatives)
1. GET with body — OkHttp does not allow GET with a body (use POST)
2. Custom cache implementations — Cache is not an interface (use interceptors for custom caching logic)
3. Highly invalid HTTP requests — OkHttp follows RFC strictly
4. Older Android (< 5.0) — use OkHttp 3.12.x branch for API 9+
5. Older Java (< 8) — use OkHttp 3.12.x branch for Java 7+

**Should not use** OkHttp for:
- GET requests with body (use POST instead)
- Custom cache implementations (use interceptors)
- Invalid HTTP requests (OkHttp follows RFC strictly)
- Android < 5.0 (use OkHttp 3.12.x)
- Java < 8 (use OkHttp 3.12.x)

## When to Use This Skill

Use this skill when the user needs to:
- Make HTTP/HTTPS requests in Java or Android
- Build REST API clients with connection pooling
- Implement response caching
- Add request/response interceptors (logging, auth, compression)
- Configure TLS versions and cipher suites
- Pin certificates for security
- Monitor HTTP call performance with EventListener
- Test HTTP clients with MockWebServer
- Handle redirects, retries, and authentication challenges
- Use HTTP/2 multiplexing

## 5.x New Features (vs 4.x)

**Key changes in OkHttp 5.x:**
- **Kotlin Multiplatform** — Separate JVM and Android artifacts (`okhttp-jvm` for Maven)
- **Happy Eyeballs (RFC 6555)** — Fast Fallback enabled by default; concurrent IPv4/IPv6 attempts
- **MockWebServer 3** — New coordinate (`mockwebserver3`), no JUnit 4 dependency, immutable API
- **GraalVM Native Image** — Automatic support; see `okcurl` module for example
- **Java 9 Modules (JPMS)** — Proper `module-info.java` files (5.2+)
- **Virtual Threads** — Java 21 virtual threads supported (uses Lock/Condition instead of synchronized)
- **Interceptor superpowers (5.4)** — Interceptors can now override OkHttpClient.Builder settings
- **Call tags (5.3)** — Attach application-specific metadata to Calls
- **Zstd compression (5.2)** — `okhttp-zstd` module for Zstandard compression
- **QUERY HTTP method (5.2)** — Support for QUERY method
- **HTTP 101 responses (5.2)** — Response.socket for connection upgrades

## Quick Start

**Gradle:**
```groovy
dependencies {
    implementation(platform("com.squareup.okhttp3:okhttp-bom:5.4.0"))
    implementation("com.squareup.okhttp3:okhttp")
    implementation("com.squareup.okhttp3:logging-interceptor")
}
```

**Maven (JVM — must use `okhttp-jvm`):**
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.squareup.okhttp3</groupId>
      <artifactId>okhttp-bom</artifactId>
      <version>5.4.0</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
<dependencies>
  <dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp-jvm</artifactId>
  </dependency>
</dependencies>
```

**Minimal GET:**
```java
OkHttpClient client = new OkHttpClient();
Request request = new Request.Builder().url("https://api.example.com/users").build();
try (Response response = client.newCall(request).execute()) {
    System.out.println(response.body().string());
}
```

**Minimal POST JSON:**
```java
RequestBody body = RequestBody.create("{\"name\":\"Alice\"}", MediaType.get("application/json"));
Request request = new Request.Builder().url("https://api.example.com/users").post(body).build();
try (Response response = client.newCall(request).execute()) {
    System.out.println(response.body().string());
}
```

## Workflow

Step 1. **Confirm environment** — Check Java 8+ or Android 5+, choose Maven (`okhttp-jvm`) or Gradle (`okhttp`)

Step 2. **Configure OkHttpClient** — Set timeouts, connection pool, cache, interceptors, TLS

Step 3. **Build Request** — Set URL, method, headers, body

Step 4. **Execute Call** — Synchronous (`execute()`) or asynchronous (`enqueue()`)

Step 5. **Handle Response** — Check status, read body, handle errors

## Critical: OkHttpClient Configuration

```java
OkHttpClient client = new OkHttpClient.Builder()
    .connectTimeout(10, TimeUnit.SECONDS)
    .readTimeout(30, TimeUnit.SECONDS)
    .writeTimeout(30, TimeUnit.SECONDS)
    .callTimeout(60, TimeUnit.SECONDS)    // Entire call timeout
    .connectionPool(new ConnectionPool(5, 5, TimeUnit.MINUTES))
    .cache(new Cache(new File("cache-dir"), 50L * 1024L * 1024L)) // 50 MiB
    .addInterceptor(new LoggingInterceptor())      // Application interceptor
    .addNetworkInterceptor(new NetworkInterceptor()) // Network interceptor
    .followRedirects(true)
    .followSslRedirects(true)
    .retryOnConnectionFailure(true)
    .build();
```

**Key configuration options:**

| Builder Method | Impact | Default |
|---------------|--------|---------|
| `connectTimeout(int, TimeUnit)` | TCP connection timeout | 10 seconds |
| `readTimeout(int, TimeUnit)` | Socket read timeout | 10 seconds |
| `writeTimeout(int, TimeUnit)` | Socket write timeout | 10 seconds |
| `callTimeout(int, TimeUnit)` | Entire call timeout (all steps) | no limit |
| `connectionPool(ConnectionPool)` | Connection pool settings | 5 idle, 5 min keepalive |
| `cache(Cache)` | Response cache (off by default) | null |
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `followSslRedirects(boolean)` | Follow HTTPS↔HTTP redirects | true |
| `retryOnConnectionFailure(boolean)` | Retry on stale connection | true |
| `dns(Dns)` | Custom DNS resolver | System DNS |
| `proxy(Proxy)` | Single proxy | null (direct) |
| `proxySelector(ProxySelector)` | Per-request proxy selection | system default |
| `authenticator(Authenticator)` | HTTP auth challenges | none |
| `certificatePinner(CertificatePinner)` | Certificate pinning | none |
| `sslSocketFactory(SSLSocketFactory, X509TrustManager)` | Custom TLS | platform default |
| `connectionSpecs(List<ConnectionSpec>)` | TLS versions and cipher suites | MODERN_TLS |
| `eventListenerFactory(EventListener.Factory)` | Event monitoring | none |

See [references/configuration.md](references/configuration.md) for full reference.

## Critical: Making Requests

**Request building:**
```java
Request request = new Request.Builder()
    .url("https://api.example.com/users/1")
    .header("Authorization", "Bearer token123")
    .addHeader("Accept", "application/json")
    .get()
    .build();
```

**POST with JSON body:**
```java
RequestBody body = RequestBody.create(jsonString, MediaType.get("application/json"));
Request request = new Request.Builder()
    .url("https://api.example.com/users")
    .post(body)
    .build();
```

**POST with form data:**
```java
RequestBody formBody = new FormBody.Builder()
    .add("username", "alice")
    .add("password", "secret")
    .build();
```

**Multipart upload:**
```java
RequestBody fileBody = RequestBody.create(new File("photo.jpg"), MediaType.get("image/jpeg"));
RequestBody requestBody = new MultipartBody.Builder()
    .setType(MultipartBody.FORM)
    .addFormDataPart("title", "My Photo")
    .addFormDataPart("photo", "photo.jpg", fileBody)
    .build();
```

See [references/calls.md](references/calls.md) for PUT/DELETE, request/response lifecycle.

## Critical: Handling Responses

**Synchronous:**
```java
try (Response response = client.newCall(request).execute()) {
    if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
    String body = response.body().string();
    int code = response.code();
    String contentType = response.header("Content-Type");
}
```

**Asynchronous:**
```java
client.newCall(request).enqueue(new Callback() {
    @Override public void onFailure(Call call, IOException e) { e.printStackTrace(); }
    @Override public void onResponse(Call call, Response response) throws IOException {
        try (ResponseBody body = response.body()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            System.out.println(body.string());
        }
    }
});
```

See [references/calls.md](references/calls.md) for follow-ups, retries, Dispatcher.

## Critical: Interceptors

**Application interceptor** — sees the original request, even for cached responses:
```java
OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new LoggingInterceptor())
    .build();
```

**Network interceptor** — sees the actual network request (with OkHttp-added headers):
```java
OkHttpClient client = new OkHttpClient.Builder()
    .addNetworkInterceptor(new LoggingInterceptor())
    .build();
```

**Logging interceptor (built-in):**
```java
import okhttp3.logging.HttpLoggingInterceptor;
HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
logging.setLevel(HttpLoggingInterceptor.Level.BODY);
```

See [references/interceptors.md](references/interceptors.md) for Application vs Network, GzipRequestInterceptor.

## Critical: Caching

**Enable cache:**
```java
OkHttpClient client = new OkHttpClient.Builder()
    .cache(new Cache(new File("cache-dir"), 50L * 1024L * 1024L)) // 50 MiB
    .build();
```

**Cache events:** `CacheHit`, `CacheMiss`, `CacheConditionalHit`

**Prune cache:**
```java
cache.evictAll(); // Clear all
Iterator<String> urlIterator = cache.urls();
while (urlIterator.hasNext()) {
    if (urlIterator.next().startsWith("https://api.example.com/")) urlIterator.remove();
}
```

See [references/caching.md](references/caching.md) for eviction, troubleshooting.

## Critical: Connections

OkHttp uses a layered model: **URL → Address → Route → Connection**

- **URL**: the resource identifier (scheme, host, path)
- **Address**: webserver + static config (port, TLS settings, protocols)
- **Route**: dynamic info (specific IP, proxy, TLS version)
- **Connection**: actual TCP socket (pooled and reused)

**Fast Fallback (Happy Eyeballs, 5.0+):**
- Attempts IPv6 and IPv4 concurrently
- Keeps the first successful connection
- Cancels others after 250ms delay

See [references/connections.md](references/connections.md) for connection pooling, Fast Fallback details.

## Critical: HTTPS/TLS

**4 built-in ConnectionSpecs:**
- `RESTRICTED_TLS` — strictest, for compliance
- `MODERN_TLS` — default, secure modern servers
- `COMPATIBLE_TLS` — older but still secure servers
- `CLEARTEXT` — for http:// URLs only

**Fallback configuration:**
```java
OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Arrays.asList(ConnectionSpec.MODERN_TLS, ConnectionSpec.COMPATIBLE_TLS))
    .build();
```

**Certificate pinning:**
```java
OkHttpClient client = new OkHttpClient.Builder()
    .certificatePinner(
        new CertificatePinner.Builder()
            .add("publicobject.com", "sha256/afwiKY3RxoMmLkuRW1l7QsPZTJPwDS2pdDROQjXw8ig=")
            .build())
    .build();
```

See [references/https.md](references/https.md) for TLS debugging, custom TrustManager, cipher suites.

## Critical: Recipes (Common Patterns)

| Pattern | Description |
|---------|-------------|
| Synchronous GET | `client.newCall(request).execute()` |
| Asynchronous GET | `client.newCall(request).enqueue(callback)` |
| POST String/File | `RequestBody.create(content, mediaType)` |
| POST Form | `FormBody.Builder().add(name, value)` |
| Multipart Upload | `MultipartBody.Builder().addFormDataPart(...)` |
| Per-call Config | `client.newBuilder().readTimeout(...).build()` |
| Authentication | `OkHttpClient.Builder().authenticator(...)` |
| Cancellation | `call.cancel()` |
| Upload Progress | Wrap RequestBody with ForwardingSink |

See [references/recipes.md](references/recipes.md) for complete code examples.

## Critical: Security

- **TLS Configuration** — Use `ConnectionSpec.MODERN_TLS` (default); fall back to `COMPATIBLE_TLS` for older servers
- **Certificate Pinning** — Use `CertificatePinner` to restrict trusted CAs
- **Custom TrustManager** — Replace platform CAs with your own (requires server TLS admin approval)
- **Conscrypt** — Use BoringSSL via Conscrypt provider for consistent TLS across platforms

See [references/security.md](references/security.md) for TLS history and provider configuration.

## Critical: Events (EventListener)

**Event sequence (successful call):**
```
callStart → dnsStart → dnsEnd → connectStart → secureConnectStart → secureConnectEnd → connectEnd → connectionAcquired → requestHeadersStart → requestHeadersEnd → responseHeadersStart → responseHeadersEnd → responseBodyStart → responseBodyEnd → connectionReleased → callEnd
```

**Pooled connection (skips connect events):**
```
callStart → connectionAcquired → requestHeadersStart → requestHeadersEnd → responseHeadersStart → responseHeadersEnd → responseBodyStart → responseBodyEnd → connectionReleased → callEnd
```

**Factory for concurrent calls:**
```java
EventListener.Factory factory = new EventListener.Factory() {
    @Override public EventListener create(Call call) {
        return new TimingEventListener();
    }
};
```

See [references/events.md](references/events.md) for complete EventListener code, failure/retry events, 10% sampling.

## Critical: MockWebServer

**Basic usage:**
```java
MockWebServer server = new MockWebServer();
server.enqueue(new MockResponse().setBody("Hello World!"));
server.start();

Request request = new Request.Builder().url(server.url("/")).build();
try (Response response = client.newCall(request).execute()) {
    assertEquals("Hello World!", response.body().string());
}
server.shutdown();
```

**Maven (use `mockwebserver3`):**
```xml
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>mockwebserver3</artifactId>
    <scope>test</scope>
</dependency>
```

See [references/calls.md](references/calls.md) for RecordedRequest verification.

## Quick Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `java.lang.NoClassDefFoundError: kotlin/jvm/internal/...` | Missing Kotlin stdlib | OkHttp 5.x is KMP; ensure `okhttp-jvm` in Maven or `okhttp` in Gradle |
| `SSLHandshakeException` | TLS version mismatch | Check ConnectionSpec; try `COMPATIBLE_TLS` fallback |
| `SocketTimeoutException` | Server too slow | Increase `readTimeout` or `callTimeout` |
| `ConnectionPool` exhaustion | Too many concurrent requests | Increase pool size or use async calls with Dispatcher limits |
| `IllegalStateException: cache is closed` | Cache directory conflict | Ensure single Cache instance per directory |
| `Certificate pinning failure` | Pin mismatch | Update pins after certificate rotation |
| `IOException: Canceled` | Call canceled | Check cancellation logic; don't cancel prematurely |
| `ProtocolException: HTTP/209` | Invalid HTTP method | OkHttp follows RFC; use POST instead of GET with body |
| Maven `okhttp` artifact empty | KMP artifact issue | Use `okhttp-jvm` for Maven projects |
| GraalVM native image fails | Missing reflection config | See okcurl module for example GraalVM config |

## Gotchas

1. **Maven must use `okhttp-jvm`** — OkHttp 5.x is Kotlin Multiplatform; the `okhttp` artifact is empty in Maven. Use `okhttp-jvm` for JVM projects.
2. **GET cannot have a body** — OkHttp follows HTTP RFC strictly. Use POST for requests with body.
3. **Cache is off by default** — Must explicitly configure `Cache` in OkHttpClient.Builder.
4. **Cache directory exclusive** — One Cache instance per directory. Don't share directories.
5. **Read response fully** — Cached responses require full read; partial reads won't cache.
6. **Close Response bodies** — Always close Response (use try-with-resources) to avoid connection leaks.
7. **Application vs Network interceptors** — Application interceptors run once (even for cache); Network interceptors run for each network call.
8. **Fast Fallback is default in 5.x** — Concurrent IPv4/IPv6 attempts. Disable with `fastFallback(false)` if needed.
9. **ConnectionSpec changes per release** — TLS versions and cipher suites may change. Stay up-to-date.
10. **Certificate pinning coordination** — Requires server TLS admin approval. Pins must be updated when certificates rotate.
11. **Dispatcher limits** — Default: 5 concurrent per host, 64 total. Configure via `dispatcher(new Dispatcher(executorService))`.
12. **Transparent GZIP** — OkHttp adds `Accept-Encoding: gzip` automatically. Interceptors see compressed data at network level.

## References

### Calls
- [calls.md](references/calls.md) — Request/Response lifecycle, rewriting, follow-ups, retries, Dispatcher

### Caching
- [caching.md](references/caching.md) — Cache configuration, EventListener cache events, directory management, eviction

### Connections
- [connections.md](references/connections.md) — URL/Address/Route/Connection model, connection pooling, Fast Fallback

### Events
- [events.md](references/events.md) — EventListener, Factory, concurrent calls, failure/retry events

### HTTPS
- [https.md](references/https.md) — ConnectionSpec, TLS debugging, certificate pinning, custom TrustManager

### Interceptors
- [interceptors.md](references/interceptors.md) — Application vs Network, request/response rewriting

### Recipes
- [recipes.md](references/recipes.md) — Common patterns: GET, POST, Form, Multipart, Auth, Upload Progress

### Security
- [security.md](references/security.md) — TLS configuration history, certificate providers, Conscrypt

### Configuration
- [configuration.md](references/configuration.md) — OkHttpClient.Builder full reference, Maven/Gradle/BOM dependencies
