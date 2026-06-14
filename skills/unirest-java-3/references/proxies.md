# Proxies — Full Reference (Unirest 3.x)

Complete guide to proxy configuration with Unirest-Java 3.x.

## Simple Proxy

With authentication:
```java
Unirest.config().proxy("proxy.com", 7777, "username", "password1!");
```

Without authentication:
```java
Unirest.config().proxy("proxy.com", 7777);
```

Using a Proxy object:
```java
Unirest.config().proxy(new Proxy("proxy.com", 7777));
```

## Using System Properties

Java has built-in system properties for proxy configuration. In 3.x, `useSystemProperties` defaults to `true`:

```java
System.setProperty("http.proxyHost", "localhost");
System.setProperty("http.proxyPort", "7777");

// useSystemProperties defaults to true in 3.x
// You may need to explicitly set it if changed
Unirest.config().useSystemProperties(true);
```

## Per-Request Proxy (3.x Only)

3.x supports setting a proxy on individual requests:

```java
Unirest.get("http://localhost/data")
    .proxy("proxy.com", 8080)
    .asString();

// With authentication
Unirest.get("http://localhost/data")
    .proxy("proxy.com", 8080, "user", "pass")
    .asString();
```

> ⚠️ Per-request proxies are removed in 4.x. Use global `Unirest.config().proxy()` instead.

## Limitations vs 4.x

- **No ProxySelector support** — 3.x uses Apache's proxy mechanism, not `java.net.ProxySelector`
- **No Authenticator integration** — Use Apache-specific auth mechanisms
- **System props enabled by default** — Unlike 4.x where `useSystemProperties` defaults to `false`
