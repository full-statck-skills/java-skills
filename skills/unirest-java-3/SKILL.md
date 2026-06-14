---
name: unirest-java-3
description: >
  Unirest-Java 3.x HTTP client library for Java 8+. Use when making HTTP requests (GET/POST/PUT/DELETE),
  building REST API clients, handling JSON responses, file uploads/downloads, async requests,
  mocking HTTP calls for testing, configuring proxies, or caching responses.
  Covers Unirest 3.x (Apache HttpClient based, default GSON included, kong.unirest package) with
  object mapping, request/response interceptors, and migration guidance.
---

# Unirest-Java 3.x Reference (v3.14.5)

This skill covers the Unirest-Java 3.x HTTP client library for Java 8+. It uses Apache HttpClient 4 as the HTTP engine and includes GSON as the default JSON parser.

## Capability Boundaries

### ✅ Strong Suits
1. Building HTTP requests (GET, POST, PUT, DELETE, PATCH) with fluent API
2. JSON/object mapping with built-in GSON (no extra dependency needed)
3. Async requests with CompletableFuture (via Apache HttpAsyncClient)
4. File uploads with progress monitoring
5. Mock testing for HTTP clients
6. Response caching with configurable eviction
7. Proxy configuration (simple, system, per-request)
8. Request/response interceptors for logging and auth
9. Connection pool tuning (`concurrency(total, perRoute)`)
10. Socket timeout control (independent of connect timeout)
11. Automatic retries on socket errors (`automaticRetries()`)
12. Shutdown hooks for background thread management
13. Custom HostnameVerifier support

### ⚠️ Requirements
1. Java 8 or higher
2. Apache HttpClient 4 (transitive dependency)
3. Maven/Gradle dependency management

### ❌ Out of Scope (with alternatives)
1. HTTP/2 → use Unirest 4.x (defaults to HTTP/2)
2. WebSocket via Unirest → use Apache HttpClient WebSocket or dedicated library
3. Server-Sent Events (SSE) → use Unirest 4.x or custom implementation
4. Custom executor support → not available in 3.x
5. Java Authenticator integration → use Apache-specific auth mechanisms
6. ProxySelector support → use per-request proxies or system properties

## When to Use This Skill

Use this skill when the user needs to:
- Make HTTP requests to REST APIs in Java 8+ projects
- Use Apache HttpClient as the HTTP engine
- Have built-in GSON without extra dependencies
- Tune connection pools (`concurrency()`)
- Control socket timeout independently
- Use automatic retries on socket errors
- Configure per-request proxies
- Use custom HostnameVerifier

## Quick Start

**Maven dependency (Unirest 3.14.5):**
```xml
<dependency>
    <groupId>com.konghq</groupId>
    <artifactId>unirest-java</artifactId>
    <version>3.14.5</version>
</dependency>
```

> ✅ **No JSON module declaration needed** — GSON is included by default.

**Minimal GET request:**
```java
String body = Unirest.get("https://api.example.com/users")
    .asString()
    .getBody();
```

**Minimal POST with JSON:**
```java
HttpResponse<JsonNode> response = Unirest.post("https://api.example.com/users")
    .header("Content-Type", "application/json")
    .body(new User("Alice", "alice@example.com"))
    .asJson();
```

## Critical: Installation

Unirest 3.x is a single dependency that includes GSON by default:

```xml
<dependency>
    <groupId>com.konghq</groupId>
    <artifactId>unirest-java</artifactId>
    <version>3.14.5</version>
</dependency>
```

> ✅ No need to declare a separate JSON module — `JsonObjectMapper` (GSON-based) is included.

## Critical: Configuration

All configuration goes through `Unirest.config()`:

```java
Unirest.config()
    .connectTimeout(5000)
    .socketTimeout(10000)
    .concurrency(200, 20)
    .setDefaultHeader("Accept", "application/json")
    .setDefaultBasicAuth("user", "pass")
    .followRedirects(true)
    .verifySsl(true)
    .enableCookieManagement(true)
    .automaticRetries(true)
    .proxy("proxy.com", 8080, "user", "pass");
```

**Key config options:**

| Method | Impact | Default |
|--------|--------|---------|
| `connectTimeout(int)` | Connection timeout (ms) | 10000 |
| `socketTimeout(int)` | Socket/read timeout (ms) | 60000 |
| `concurrency(int, int)` | Max total connections, max per route | 200/20 |
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `verifySsl(boolean)` | Enforce SSL verification | true |
| `enableCookieManagement(boolean)` | Accept/store cookies | true |
| `automaticRetries(boolean)` | Auto-retry on socket errors (up to 4 times) | true |
| `retryAfter(boolean)` | Auto-retry on 429/529 with Retry-After header | false |
| `defaultBaseUrl(String)` | Default base URL for all requests | none |
| `addShutdownHook(boolean)` | Register JVM shutdown hook | false |
| `useSystemProperties(boolean)` | Use system properties for proxies etc. | true |

**Multiple configurations:**
```java
// Primary instance (same as static Unirest)
UnirestInstance unirest = Unirest.primaryInstance();

// Spawn a new independent instance
UnirestInstance custom = Unirest.spawnInstance();
custom.config().connectTimeout(3000);
```

> ⚠️ If you spawn a new instance, YOU are responsible for shutting it down.

See [references/configuration.md](references/configuration.md) for full config table, interceptors, object mappers, and metrics.

## Critical: Making Requests

**Basic request types:**
```java
Unirest.get("http://localhost/users").asString();
Unirest.post("http://localhost/users").body(json).asJson();
Unirest.put("http://localhost/users/1").body(user).asEmpty();
Unirest.delete("http://localhost/users/1").asEmpty();
```

**Route parameters:**
```java
Unirest.get("http://localhost/users/{id}")
    .routeParam("id", "42")
    .asString();
// Results in http://localhost/users/42
```

**Query parameters:**
```java
Unirest.get("http://localhost/search")
    .queryString("q", "unirest")
    .queryString("page", 1)
    .asString();
```

**Headers and auth:**
```java
Unirest.get("http://localhost/protected")
    .header("X-Custom", "value")
    .basicAuth("user", "pass")
    .asString();
```

**Form data:**
```java
Unirest.post("http://localhost/form")
    .field("name", "Alice")
    .field("age", 30)
    .asEmpty();
```

**File upload:**
```java
Unirest.post("http://localhost/upload")
    .field("file", new File("/path/to/file.zip"))
    .asEmpty();
```

**Async request:**
```java
CompletableFuture<HttpResponse<JsonNode>> future = Unirest.get("http://localhost/data")
    .asJsonAsync(response -> {
        System.out.println(response.getBody());
    });
```

**Per-request proxy (3.x only):**
```java
Unirest.get("http://localhost/data")
    .proxy("proxy.com", 8080)
    .asString();
```

**JSON Patch (RFC-6902):**
```java
Unirest.jsonPatch("http://localhost/resource")
    .add("/fruits/-", "Apple")
    .remove("/bugs")
    .replace("/name", "Updated")
    .asJson();
```

See [references/requests.md](references/requests.md) for upload progress, paged requests, client certificates, and more.

## Critical: Handling Responses

**Response types:**
```java
// String
String body = Unirest.get(url).asString().getBody();

// Object mapping (GSON included by default)
Book book = Unirest.get(url).asObject(Book.class).getBody();

// Generic types
List<Book> books = Unirest.get(url)
    .asObject(new GenericType<List<Book>>(){}).getBody();

// JSON
JsonNode json = Unirest.get(url).asJson().getBody();

// File
File file = Unirest.get(url).asFile("/tmp/download.zip").getBody();

// Empty (status/headers only)
HttpResponse resp = Unirest.delete(url).asEmpty();
```

**Error handling:**
```java
Unirest.get("http://localhost/data")
    .asJson()
    .ifSuccess(response -> handleSuccess(response))
    .ifFailure(response -> {
        log.error("Status: " + response.getStatus());
        response.getParsingError().ifPresent(e -> {
            log.error("Parse error: " + e.getMessage());
        });
    });
```

**Parsing errors:**
```java
response.getParsingError().ifPresent(ex -> {
    String originalBody = ex.getOriginalBody();
    String message = ex.getMessage();
});
```

**Map error objects:**
```java
HttpResponse<Book> book = Unirest.get(url).asObject(Book.class);
Error err = book.mapError(Error.class);
```

See [references/responses.md](references/responses.md) for download progress, large responses, body mapping, and more.

## Critical: Mocking

**Static mock:**
```java
MockClient mock = MockClient.register();

mock.expect(HttpMethod.GET, "http://api.example.com/users")
    .thenReturn("{\"name\":\"Alice\"}")
    .withStatus(200);

String body = Unirest.get("http://api.example.com/users")
    .asString().getBody();
// body == "{\"name\":\"Alice\"}"

mock.verifyAll(); // Verify all expects were called
```

**Instance mock (3.x requires both clients):**
```java
UnirestInstance unirest = Unirest.spawnInstance();
MockClient mock = MockClient.register(unirest);
// In 3.x, the mock implements both Client and AsyncClient
```

**Body matching:**
```java
mock.expect(HttpMethod.POST, "http://api.example.com/users")
    .body(FieldMatcher.of("name", "Alice", "role", "admin"))
    .thenReturn()
    .withStatus(201);
```

**Verify with times:**
```java
var expect = mock.expect(HttpMethod.GET, "http://api.example.com/users").thenReturn();
expect.verify();              // At least once
expect.verify(Times.never()); // Never called
```

See [references/mocking.md](references/mocking.md) for POJO responses, multiple expects, and more.

## Critical: Caching

**Basic caching:**
```java
Unirest.config().cacheResponses(true);
```

**Advanced caching with options:**
```java
Unirest.config().cacheResponses(Cache.builder()
    .depth(100)                      // Max entries
    .maxAge(5, TimeUnit.MINUTES));   // Entry TTL
```

**Custom cache (e.g., Guava):**
```java
Unirest.config().cacheResponses(
    Cache.builder().backingCache(new MyGuavaCache()));
```

See [references/caching.md](references/caching.md) for custom cache implementation details.

## Critical: Proxies

**Simple proxy:**
```java
Unirest.config().proxy("proxy.com", 8080, "user", "pass");
```

**Per-request proxy (3.x only):**
```java
Unirest.get("http://localhost/data")
    .proxy("proxy.com", 8080)
    .asString();
```

**System properties (default: true in 3.x):**
```java
System.setProperty("http.proxyHost", "localhost");
System.setProperty("http.proxyPort", "7777");
// useSystemProperties defaults to true in 3.x
```

See [references/proxies.md](references/proxies.md) for details.

## Quick Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `NoClassDefFoundError: kong/unirest/Unirest` | Wrong package | Use `import kong.unirest.*` (not `kong.unirest.core.*`) |
| `asObject()` returns null body | Response parsing failed | Check `response.getParsingError()` for details |
| `ConnectException: Connection timed out` | Server unreachable or timeout too low | Increase `connectTimeout` or check network |
| `SocketTimeoutException` | Read timeout exceeded | Increase `socketTimeout` (default 60000ms) |
| `SSLHandshakeException` | SSL verification failure | Use `verifySsl(false)` for dev only, fix certs in prod |
| Proxy not working | System props may be disabled | Check `useSystemProperties(true)` (default true in 3.x) |
| Too many connections | Connection pool exhausted | Increase `concurrency(total, perRoute)` |
| Automatic retries not working | Disabled or not applicable | Check `automaticRetries(true)` (default true) |

## Gotchas

1. **Java 8+ is sufficient** — 3.x runs on Java 8 (unlike 4.x which requires Java 11+)
2. **GSON included by default** — No need to declare a separate JSON module (unlike 4.x)
3. **Package is `kong.unirest`** — Not `kong.unirest.core` (that's 4.x)
4. **Single Maven dependency** — `unirest-java:3.14.5` (unlike 4.x which uses BOM + core + module)
5. **Apache HttpClient engine** — Uses Apache HttpClient 4 (not java.net.http.HttpClient)
6. **Socket timeout is independent** — `socketTimeout()` controls read timeout separately from `connectTimeout()`
7. **Connection pool tuning** — `concurrency(total, perRoute)` lets you tune Apache's connection pool
8. **Automatic retries enabled by default** — `automaticRetries(true)` retries socket errors up to 4 times
9. **Per-request proxies supported** — `request.proxy(host, port)` works (removed in 4.x)
10. **HostnameVerifier supported** — `hostnameVerifier(verifier)` for custom SSL hostname verification
11. **Shutdown hooks available** — `addShutdownHook(true)` registers JVM shutdown hooks
12. **System proxy props enabled by default** — `useSystemProperties` defaults to `true` (unlike 4.x)
13. **No WebSocket via Unirest** — Use Apache HttpClient WebSocket or a dedicated library
14. **No SSE support** — `Unirest.sse()` does not exist in 3.x
15. **Mock registration requires both clients** — MockClient implements both `Client` and `AsyncClient`

## References

### Requests
- [requests.md](references/requests.md) — Route params, query params, headers, auth, body types, file uploads, upload progress, async, paged requests, per-request proxy

### Responses
- [responses.md](references/responses.md) — asEmpty/asString/asObject/asJson/asFile, GenericType, parsing errors, error object mapping, download progress, large responses, error handling

### Configuration
- [configuration.md](references/configuration.md) — Full config options table, global interceptors, multiple configurations, object mappers, metrics, Apache-specific options

### Mocking
- [mocking.md](references/mocking.md) — Static/instance mocks, multiple expects (scoring), verification, body matching, form params, POJO responses

### Caching
- [caching.md](references/caching.md) — Basic/advanced caching, custom cache implementations

### Proxies
- [proxies.md](references/proxies.md) — Simple proxy, system properties, per-request proxy
