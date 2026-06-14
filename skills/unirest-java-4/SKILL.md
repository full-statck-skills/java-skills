---
name: unirest-java-4
description: >
  Unirest-Java 4.x HTTP client library for Java 11+. Use when making HTTP requests (GET/POST/PUT/DELETE),
  building REST API clients, handling JSON responses, file uploads/downloads, async requests,
  Server-Sent Events (SSE), mocking HTTP calls for testing, configuring proxies, or caching responses.
  Covers Unirest 4.x (requires Java 11+, modular dependencies, kong.unirest.core package) with
  GSON/Jackson object mapping, request/response interceptors, and migration from Unirest 3.x.
---

# Unirest-Java 4.x Reference (v4.10.0)

This skill covers the Unirest-Java 4.x HTTP client library for Java 11+. It uses the built-in `java.net.http.HttpClient` (replacing Apache HttpClient in 3.x) and defaults to HTTP/2.

## Capability Boundaries

### ✅ Strong Suits
1. Building HTTP requests (GET, POST, PUT, DELETE, PATCH) with fluent API
2. JSON/object mapping with GSON or Jackson (must declare module explicitly)
3. Async requests with CompletableFuture (built into java.net.http.HttpClient)
4. File uploads with progress monitoring
5. Server-Sent Events (SSE) consumption via `Unirest.sse(url)`
6. WebSocket connections via `Unirest.webSocket(url)`
7. Mock testing for HTTP clients
8. Response caching with configurable eviction
9. Proxy configuration (simple, system, ProxySelector)
10. HTTP/2 by default (configurable via `config.version()`)
11. Custom executor support via `config.executor()`
12. Java Authenticator support via `config.authenticator()`

### ⚠️ Requirements
1. Java 11 or higher (uses `java.net.http.HttpClient`)
2. Must declare a JSON module (`unirest-modules-gson` or `unirest-modules-jackson`) for object mapping
3. Maven/Gradle dependency management with BOM

### ❌ Out of Scope (with alternatives)
1. Per-request proxies → use global `Unirest.config().proxy()` (removed in 4.x)
2. Custom HostnameVerifier → use `disableHostNameVerification()` system property
3. Socket timeout (independent of connect timeout) → use `requestTimeout()` instead
4. Connection pool tuning (`concurrency(total, perRoute)`) → not supported (java.net.http manages this)
5. Automatic retries on socket errors → use `retryAfter()` for 429/529 only
6. Shutdown hooks → not needed (no background threads to manage)
7. Apache HttpClient integration → use 3.x if you need Apache-specific features

## When to Use This Skill

Use this skill when the user needs to:
- Make HTTP requests to REST APIs in Java
- Upload or download files via HTTP
- Consume Server-Sent Event streams
- Mock HTTP calls in unit tests
- Configure proxies for HTTP requests
- Cache HTTP responses
- Migrate from Unirest 3.x to 4.x

## Quick Start

**Maven dependency (Unirest 4.10.0):**
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.konghq</groupId>
            <artifactId>unirest-java-bom</artifactId>
            <version>4.10.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>com.konghq</groupId>
        <artifactId>unirest-java-core</artifactId>
    </dependency>
    <!-- Choose ONE JSON module: -->
    <dependency>
        <groupId>com.konghq</groupId>
        <artifactId>unirest-modules-gson</artifactId>
    </dependency>
</dependencies>
```

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

Unirest 4 is modular. You must declare:
1. **`unirest-java-core`** — the HTTP client engine
2. **A JSON module** — `unirest-modules-gson` OR `unirest-modules-jackson` (required for object mapping/JSON parsing)

> ⚠️ **Without a JSON module**, calls to `asObject()`, `asJson()`, and JSON Patch will fail at runtime.

See [references/configuration.md](references/configuration.md) for full installation details.

## Critical: Configuration

All configuration goes through `Unirest.config()`:

```java
Unirest.config()
    .connectTimeout(5000)
    .setDefaultHeader("Accept", "application/json")
    .setDefaultBasicAuth("user", "pass")
    .followRedirects(true)
    .verifySsl(true)
    .enableCookieManagement(true)
    .proxy("proxy.com", 8080, "user", "pass");
```

**Key config options:**

| Method | Impact | Default |
|--------|--------|---------|
| `connectTimeout(int)` | Connection timeout (ms) | 10000 |
| `requestTimeout(int)` | Request timeout (ms) | infinite |
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `verifySsl(boolean)` | Enforce SSL verification | true |
| `enableCookieManagement(boolean)` | Accept/store cookies | true |
| `retryAfter(boolean)` | Auto-retry on 429/529 | false |
| `defaultBaseUrl(String)` | Default base URL for all requests | none |

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

// Object mapping
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

## Critical: Server-Sent Events (SSE)

**Async SSE consumption:**
```java
var future = Unirest.sse("https://stream.example.com/events")
    .connect(event -> {
        var data = event.asObject(MyEvent.class);
        System.out.println("Event: " + data.getTitle());
    });
```

**Synchronous SSE consumption:**
```java
Unirest.sse("https://stream.example.com/events")
    .connect()
    .map(event -> event.asObject(MyEvent.class))
    .forEach(data -> System.out.println("Event: " + data.getTitle()));
```

> ⚠️ SSE connections are persistent. Use async mode in production systems.
> ⚠️ Object mapping requires an ObjectMapper to be configured.

See [references/sse.md](references/sse.md) for full details.

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

**Instance mock:**
```java
UnirestInstance unirest = Unirest.spawnInstance();
MockClient mock = MockClient.register(unirest);
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

## Critical: Proxies

**Simple proxy:**
```java
Unirest.config().proxy("proxy.com", 8080, "user", "pass");
```

**System properties:**
```java
System.setProperty("http.proxyHost", "localhost");
System.setProperty("http.proxyPort", "7777");
Unirest.config().useSystemProperties(true);
```

**Multiple proxies (ProxySelector):**
```java
Unirest.config()
    .proxy(new ProxySelector() {
        @Override
        public List<Proxy> select(URI uri) {
            if (uri.getHost().equals("internal.com")) {
                return List.of(new Proxy(HTTP,
                    InetSocketAddress.createUnresolved("internal-proxy.com", 8080)));
            }
            return List.of(new Proxy(HTTP,
                InetSocketAddress.createUnresolved("default-proxy.com", 8080)));
        }
        @Override
        public void connectFailed(URI uri, SocketAddress sa, IOException ioe) {}
    });
```

See [references/proxies.md](references/proxies.md) for authenticator setup and details.

## Critical: WebSocket

**Connect to a WebSocket:**
```java
Unirest.webSocket("ws://localhost/socket")
    .connect(ws -> {
        ws.sendText("Hello!");
        ws.onMessage(message -> {
            System.out.println("Received: " + message);
        });
    });
```

**WebSocket with POJO mapping:**
```java
Unirest.webSocket("ws://localhost/events")
    .connect(ws -> {
        ws.onMessage(event -> {
            MyEvent data = event.asObject(MyEvent.class);
            processEvent(data);
        });
    });
```

> ⚠️ WebSocket is a 4.x-only feature. Not available in 3.x.

See [references/websocket.md](references/websocket.md) for full details.

## Quick Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `NoClassDefFoundError: JsonObject` | Missing JSON module | Add `unirest-modules-gson` or `unirest-modules-jackson` dependency |
| `java.lang.NoClassDefFoundError: kong/unirest/Unirest` | Wrong package in 4.x | Change import from `kong.unirest.*` to `kong.unirest.core.*` |
| `asObject()` returns null body | Response parsing failed | Check `response.getParsingError()` for details |
| `ConnectException: Connection timed out` | Server unreachable or timeout too low | Increase `connectTimeout` or check network |
| `SSLHandshakeException` | SSL verification failure | Use `verifySsl(false)` for dev only, fix certs in prod |
| `Host header override not allowed` | Java 11+ HttpClient restriction | Set system property `jdk.httpclient.allowRestrictedHeaders=host` |
| Proxy not working in 4.x | System props disabled by default in 4.x | Call `useSystemProperties(true)` explicitly |

## Gotchas

1. **Java 11+ is mandatory** — Unirest 4.x uses `java.net.http.HttpClient` and will not run on Java 8
2. **JSON module must be declared** — Unlike 3.x, 4.x has NO default JSON parser. Without `unirest-modules-gson` or `unirest-modules-jackson`, JSON parsing will fail at runtime
3. **Package rename** — `kong.unirest` (3.x) → `kong.unirest.core` (4.x), JSON modules at `kong.unirest.modules.gson/jackson` (4.3+)
4. **HTTP/2 by default** — 4.x defaults to `HttpClient.Version.HTTP_2`. Use `config.version(HttpClient.Version.HTTP_1_1)` to downgrade
5. **No per-request proxies** — 3.x allowed `request.proxy(host, port)`. 4.x only supports global proxy via `Unirest.config().proxy()`
6. **No socketTimeout** — 3.x had independent `socketTimeout()`. 4.x uses `requestTimeout()` which covers the entire request lifecycle
7. **No concurrency tuning** — `concurrency(total, perRoute)` was Apache-specific. java.net.http manages connection pools internally
8. **No automatic retries** — `automaticRetries(true)` was Apache-specific. 4.x only has `retryAfter()` for 429/529 responses
9. **No HostnameVerifier** — 3.x had `hostnameVerifier(verifier)`. 4.x uses `disableHostNameVerification()` system property (JVM-wide)
10. **System proxy props disabled by default** — Unlike 3.x (default true), 4.x defaults `useSystemProperties` to `false`
11. **SSE and WebSocket are 4.x-only** — `Unirest.sse()` and `Unirest.webSocket()` do not exist in 3.x
12. **Mock registration simplified** — 3.x: `MockClient.register()` required `.httpClient(client).asyncClient(client)`. 4.x: only `.httpClient(client)`
13. **Config changes require reset** — Once Unirest is activated, changing client-creation config requires `config().reset()` first
14. **`isRunning()` removed** — 3.x had `Unirest.isRunning()`. 4.x removed it (no background threads to monitor)

## References

### Requests
- [requests.md](references/requests.md) — Route params, query params, headers, auth, body types, file uploads, upload progress, async, paged requests, client certificates

### Responses
- [responses.md](references/responses.md) — asEmpty/asString/asObject/asJson/asFile, GenericType, parsing errors, error object mapping, download progress, large responses, error handling

### Configuration
- [configuration.md](references/configuration.md) — Full config options table, global interceptors, multiple configurations, object mappers (Jackson/GSON), metrics

### Mocking
- [mocking.md](references/mocking.md) — Static/instance mocks, multiple expects (scoring), verification, body matching, form params, POJO responses

### Caching
- [caching.md](references/caching.md) — Basic/advanced caching, custom cache implementations

### Server-Sent Events
- [sse.md](references/sse.md) — Async/sync SSE consumption, object mapping requirements

### WebSocket
- [websocket.md](references/websocket.md) — WebSocket connections, message handling, POJO mapping

### Proxies
- [proxies.md](references/proxies.md) — Simple proxy, system properties, ProxySelector with Authenticator

### Upgrade Guide
- [upgrade-guide.md](references/upgrade-guide.md) — 3.x→4.x migration, package renames, Maven coordinate changes, behavior differences
