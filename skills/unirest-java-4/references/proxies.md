# Proxies — Full Reference

Complete guide to proxy configuration with Unirest-Java.

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

Java has built-in system properties for proxy configuration:

```java
System.setProperty("http.proxyHost", "localhost");
System.setProperty("http.proxyPort", "7777");

Unirest.config().useSystemProperties(true);
```

> ⚠️ In Unirest 4.x, `useSystemProperties` defaults to `false`. You must call it explicitly.

## Multiple Proxies (ProxySelector)

Use different proxies for different hosts:

```java
Unirest.config()
    .proxy(new ProxySelector() {
        @Override
        public List<java.net.Proxy> select(URI uri) {
            if (uri.getHost().equals("homestarrunner.com")) {
                return List.of(new java.net.Proxy(HTTP,
                    InetSocketAddress.createUnresolved("proxy-sad.com", 7777)));
            }
            return List.of(new java.net.Proxy(HTTP,
                InetSocketAddress.createUnresolved("default.com", 7777)));
        }

        @Override
        public void connectFailed(URI uri, SocketAddress sa, IOException ioe) {}
    })
    .authenticator(new Authenticator() {
        @Override
        public PasswordAuthentication requestPasswordAuthenticationInstance(
                String host, InetAddress addr, int port, String protocol,
                String prompt, String scheme, URL url, RequestorType reqType) {
            if (host.equals("homestarrunner.com")) {
                return new PasswordAuthentication("strongbad", "password".toCharArray());
            }
            return new PasswordAuthentication("default", "password".toCharArray());
        }
    });
```

## Limitations in 4.x

- **Per-request proxies removed** — only global proxy configuration is supported
- **`cookieSpec()` removed** — was Apache-specific
- **Custom HostNameVerifier removed** — no longer supported
