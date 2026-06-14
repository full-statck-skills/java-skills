# Configuration — Full Reference

Complete guide to configuring Unirest-Java.

## Config Options

All configuration is done through `Unirest.config()`. Ideally done once at startup.

```java
Unirest.config()
    .connectTimeout(1000)
    .proxy(new Proxy("https://proxy"))
    .setDefaultHeader("Accept", "application/json")
    .followRedirects(false)
    .enableCookieManagement(false)
    .addInterceptor(new MyCustomInterceptor());
```

## Full Options Table

| Builder Method | Impact | Default |
|---------------|--------|---------|
| `clientCertificateStore(String,String)` | Add PKCS12 KeyStore by path | — |
| `clientCertificateStore(KeyStore,String)` | Add PKCS12 KeyStore object | — |
| `connectTimeout(int)` | Connection timeout (ms) | 10000 |
| `connectionTTL(Duration)` | Total time to live for connections | -1 (infinite) |
| `connectionTTL(long,TimeUnit)` | Total time to live for connections | -1 (infinite) |
| `cookieSpec(String)` | Cookie policy: 'default', 'netscape', 'ignoreCookies', 'standard', 'standard-strict' | default |
| `defaultBaseUrl(String)` | Default base URL for all requests | — |
| `disableHostNameVerification(Boolean)` | Disable hostname verification (system-wide) | false |
| `setDefaultHeader(String,String)` | Set default header (overwrite if exists) | — |
| `setDefaultHeader(String,Supplier<String>)` | Set default header by supplier (for trace tokens) | — |
| `addDefaultHeader(String,String)` | Add default header (multiple for same name) | — |
| `addDefaultHeader(String,Supplier<String>)` | Add default header by supplier | — |
| `setDefaultBasicAuth(String,String)` | Default Basic Auth header | — |
| `enableCookieManagement(boolean)` | Accept/store cookies | true |
| `errorHandler(Consumer<HttpResponse<?>>)` | Global error handler for status > 400 or parse errors | — |
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `interceptor(Interceptor)` | Global interceptor (before/after each request) | — |
| `proxy(Proxy)` | Proxy for all requests | — |
| `requestTimeout(int)` | Request timeout (ms) | none (infinite) |
| `retryAfter(boolean)` | Auto-retry on 429/529 with Retry-After header | false |
| `retryAfter(boolean,int)` | Auto-retry with max attempts | false |
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

Unirest supports GSON and Jackson via modules:

```xml
<!-- GSON -->
<dependency>
    <groupId>com.konghq</groupId>
    <artifactId>unirest-modules-gson</artifactId>
</dependency>

<!-- Jackson -->
<dependency>
    <groupId>com.konghq</groupId>
    <artifactId>unirest-modules-jackson</artifactId>
</dependency>
```

Custom ObjectMapper implementation:
```java
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
