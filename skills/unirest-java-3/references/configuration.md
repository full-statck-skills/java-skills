# Configuration — Full Reference (Unirest 3.x)

Complete guide to configuring Unirest-Java 3.x.

## Config Options

All configuration is done through `Unirest.config()`. Ideally done once at startup.

```java
Unirest.config()
    .connectTimeout(1000)
    .socketTimeout(10000)
    .concurrency(200, 20)
    .proxy(new Proxy("https://proxy"))
    .setDefaultHeader("Accept", "application/json")
    .followRedirects(false)
    .enableCookieManagement(false)
    .automaticRetries(true)
    .addShutdownHook(true)
    .addInterceptor(new MyCustomInterceptor());
```

## Full Options Table

| Builder Method | Impact | Default |
|---------------|--------|---------|
| `asyncClient(AsyncClient)` | Set custom async client | Apache HttpAsyncClient |
| `addShutdownHook(boolean)` | Register JVM shutdown hook | false |
| `addInterceptor(HttpRequestInterceptor)` | Add Apache interceptor (deprecated) | — |
| `automaticRetries(boolean)` | Auto-retry on socket errors (up to 4 times) | true |
| `clientCertificateStore(String,String)` | Add PKCS12 KeyStore by path | — |
| `clientCertificateStore(KeyStore,String)` | Add PKCS12 KeyStore object | — |
| `connectTimeout(int)` | Connection timeout (ms) | 10000 |
| `connectionTTL(Duration)` | Total time to live for connections | -1 (infinite) |
| `connectionTTL(long,TimeUnit)` | Total time to live for connections | -1 (infinite) |
| `concurrency(int, int)` | Max total connections, max per route | 200/20 |
| `cookieSpec(String)` | Cookie policy | default |
| `defaultBaseUrl(String)` | Default base URL for all requests | — |
| `errorHandler(Consumer<HttpResponse<?>>)` | Global error handler (deprecated) | — |
| `httpClient(Client)` | Set custom sync client | Apache HttpClient |
| `hostnameVerifier(HostnameVerifier)` | Custom SSL hostname verifier | — |
| `setDefaultHeader(String,String)` | Set default header (overwrite if exists) | — |
| `setDefaultHeader(String,Supplier<String>)` | Set default header by supplier | — |
| `addDefaultHeader(String,String)` | Add default header (multiple for same name) | — |
| `setDefaultBasicAuth(String,String)` | Default Basic Auth header | — |
| `enableCookieManagement(boolean)` | Accept/store cookies | true |
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `interceptor(Interceptor)` | Global interceptor (before/after each request) | — |
| `proxy(Proxy)` | Proxy for all requests | — |
| `retryAfter(boolean)` | Auto-retry on 429/529 with Retry-After header | false |
| `retryAfter(boolean,int)` | Auto-retry with max attempts | false |
| `setObjectMapper(ObjectMapper)` | Custom object mapper | GSON (included) |
| `socketTimeout(int)` | Socket/read timeout (ms) | 60000 |
| `useSystemProperties(boolean)` | Use system properties for proxies etc. | true |
| `verifySsl(boolean)` | Enforce SSL verification | true |

## Global Interceptors

Set a global interceptor invoked before and after each request:

```java
Unirest.config().interceptor(new Interceptor() {
    @Override
    public void beforeRequest(HttpRequest<?> request) {
        // Logging, auth injection, etc.
    }
    @Override
    public void afterRequest(HttpResponse<?> response) {
        // Logging, metrics, etc.
    }
});
```

## Multiple Configurations

Get the primary instance or spawn a new one:

```java
// Same instance as static Unirest
UnirestInstance unirest = Unirest.primaryInstance();
unirest.config().connectTimeout(5000);
String result = unirest.get("http://foo").asString().getBody();

// New independent instance
UnirestInstance custom = Unirest.spawnInstance();
```

> ⚠️ Spawned instances are NOT tracked by `Unirest.shutDown()`. You must shut them down yourself.

## Object Mappers

GSON is included by default. You can replace it:

```java
// Custom ObjectMapper
Unirest.config().setObjectMapper(new MyCustomObjectMapper());
```

## Metrics

Collect request timing metrics:

```java
Unirest.config().instrumentWith(requestSummary -> {
    long startNanos = System.nanoTime();
    return (responseSummary, exception) ->
        logger.info("path: {} status: {} time: {}",
            requestSummary.getRawPath(),
            responseSummary.getStatus(),
            System.nanoTime() - startNanos);
});
```

## Changing Configuration

Once activated, client-creation config cannot be changed without reset:

```java
Unirest.config()
    .reset()
    .connectTimeout(5000);
```

## Client Certificates

```java
// From file path (PKCS#12)
Unirest.config()
    .clientCertificateStore("/path/mykeystore.p12", "password1!");

// From KeyStore object
Unirest.config()
    .clientCertificateStore(keyStore, "password1!");
```

## Apache-Specific Options (3.x Only)

**Custom Apache HttpClient:**
```java
Unirest.config()
    .httpClient(myApacheClient)
    .asyncClient(myAsyncClient);
```

**Socket timeout (independent of connect timeout):**
```java
Unirest.config().socketTimeout(30000); // 30 seconds
```

**Connection pool tuning:**
```java
Unirest.config().concurrency(500, 50); // 500 total, 50 per route
```

**Automatic retries on socket errors:**
```java
Unirest.config().automaticRetries(true); // Up to 4 retries
```

**Shutdown hooks:**
```java
Unirest.config().addShutdownHook(true); // Register JVM shutdown hooks
```

**HostnameVerifier:**
```java
Unirest.config().hostnameVerifier((hostname, session) -> true);
```
