# Configuration — Full Reference

Official source: https://square.github.io/okhttp/ (Maven/Gradle section)

Complete guide to OkHttpClient configuration and dependencies.

## Dependencies

### Gradle (Recommended)

```groovy
dependencies {
    implementation(platform("com.squareup.okhttp3:okhttp-bom:5.4.0"))
    implementation("com.squareup.okhttp3:okhttp")
    implementation("com.squareup.okhttp3:logging-interceptor")
    testImplementation("com.squareup.okhttp3:mockwebserver3")
}
```

### Maven (JVM — must use `okhttp-jvm`)

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
  <dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>logging-interceptor</artifactId>
  </dependency>
  <dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>mockwebserver3</artifactId>
    <scope>test</scope>
  </dependency>
</dependencies>
```

**Important:** Maven must use `okhttp-jvm` because OkHttp 5.x is Kotlin Multiplatform. The `okhttp` artifact is empty in Maven.

## OkHttpClient.Builder Full Reference

### Timeouts

| Method | Impact | Default |
|--------|--------|---------|
| `connectTimeout(int, TimeUnit)` | TCP connection timeout | 10 seconds |
| `readTimeout(int, TimeUnit)` | Socket read timeout | 10 seconds |
| `writeTimeout(int, TimeUnit)` | Socket write timeout | 10 seconds |
| `callTimeout(int, TimeUnit)` | Entire call timeout (all steps) | no limit |

### Connection Pool

| Method | Impact | Default |
|--------|--------|---------|
| `connectionPool(ConnectionPool)` | Pool settings | 5 idle, 5 min keepalive |
| `ConnectionPool(int, long, TimeUnit)` | Custom pool | — |

### Cache

| Method | Impact | Default |
|--------|--------|---------|
| `cache(Cache)` | Response cache | null (off) |

### Redirects and Retries

| Method | Impact | Default |
|--------|--------|---------|
| `followRedirects(boolean)` | Follow HTTP redirects | true |
| `followSslRedirects(boolean)` | Follow HTTPS↔HTTP redirects | true |
| `retryOnConnectionFailure(boolean)` | Retry stale connections | true |

### Proxy and DNS

| Method | Impact | Default |
|--------|--------|---------|
| `proxy(Proxy)` | Single proxy | null (direct) |
| `proxySelector(ProxySelector)` | Per-request proxy | system default |
| `proxyAuthenticator(Authenticator)` | Proxy auth | none |
| `dns(Dns)` | Custom DNS | system DNS |

### Authentication

| Method | Impact | Default |
|--------|--------|---------|
| `authenticator(Authenticator)` | HTTP auth challenges | none |

### TLS/HTTPS

| Method | Impact | Default |
|--------|--------|---------|
| `sslSocketFactory(SSLSocketFactory, X509TrustManager)` | Custom TLS | platform default |
| `connectionSpecs(List<ConnectionSpec>)` | TLS versions/ciphers | MODERN_TLS |
| `certificatePinner(CertificatePinner)` | Certificate pinning | none |
| `hostnameVerifier(HostnameVerifier)` | Hostname verification | default verifier |

### Interceptors

| Method | Impact | Default |
|--------|--------|---------|
| `addInterceptor(Interceptor)` | Application interceptor | none |
| `addNetworkInterceptor(Interceptor)` | Network interceptor | none |

### Events

| Method | Impact | Default |
|--------|--------|---------|
| `eventListener(EventListener)` | Single event listener | none |
| `eventListenerFactory(EventListener.Factory)` | Factory for per-call listeners | none |

### Dispatcher

| Method | Impact | Default |
|--------|--------|---------|
| `dispatcher(Dispatcher)` | Async dispatch policy | 5 per host, 64 total |

### Other

| Method | Impact | Default |
|--------|--------|---------|
| `fastFallback(boolean)` | Happy Eyeballs (5.0+) | true |
| `cookieJar(CookieJar)` | Cookie management | no cookies |
| `socketFactory(SocketFactory)` | Custom sockets | default |
| `connectionSpecs(List<ConnectionSpec>)` | TLS and cleartext specs | MODERN_TLS |

## Android Requirements

- Android 5.0+ (API level 21+)
- Uses AndroidX Startup
- If disabled in manifest: call `OkHttp.initialize(applicationContext)` in `Application.onCreate()`

## Java Modules (5.2+)

OkHttp implements Java 9 Modules. Stable public API modules:

```
okhttp3
okhttp3.brotli
okhttp3.coroutines
okhttp3.dnsoverhttps
okhttp3.java.net.cookiejar
okhttp3.logging
okhttp3.sse
okhttp3.tls
okhttp3.urlconnection
mockwebserver3
mockwebserver3.junit4
mockwebserver3.junit5
```
