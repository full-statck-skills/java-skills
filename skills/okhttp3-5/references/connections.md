# Connections — Full Reference

Official source: https://square.github.io/okhttp/features/connections/

Complete guide to connection management in OkHttp.

## URL → Address → Route → Connection Model

### URLs

URLs (like `https://github.com/square/okhttp`) are abstract:
- Specify `http` vs `https` but not cipher suites
- Don't specify proxy settings
- Identify specific path and query

### Addresses

Address specifies a webserver and all static connection config:
- Hostname, port
- HTTPS settings (TLS versions, cipher suites)
- Preferred protocols (HTTP/2)

**URLs sharing the same address may share the same TCP socket.** This provides:
- Lower latency
- Higher throughput (TCP slow start)
- Conserved battery

### Routes

Route provides dynamic connection info:
- Specific IP address (from DNS)
- Proxy server (if ProxySelector is in use)
- TLS version to negotiate

Multiple routes per address are possible (e.g., multiple datacenters).

### Connections

Connection is the actual TCP socket, pooled and reused.

## Connection Establishment

When you request a URL:

1. Create Address from URL + OkHttpClient config
2. Try to retrieve connection from pool with that address
3. If not pooled, select a route (DNS for IP, TLS version, proxy)
4. If new route: build socket (direct, TLS tunnel, or direct TLS)
5. Send HTTP request, read response
6. If problem: try another route

## Connection Pooling

OkHttp automatically reuses connections:
- HTTP/1.x connections are kept alive
- HTTP/2 connections are multiplexed

**Default pool:** 5 idle connections, 5 minute keepalive.

```java
ConnectionPool pool = new ConnectionPool(10, 10, TimeUnit.MINUTES);
OkHttpClient client = new OkHttpClient.Builder()
    .connectionPool(pool)
    .build();
```

Connections are evicted after a period of inactivity.

## Fast Fallback (Happy Eyeballs)

Since OkHttp 5.0, implements RFC 6555:

1. **Alternate address families** — Prefer IPv6, then IPv4, alternating
2. **250ms delay** — Don't start new attempt until 250ms after most recent
3. **Keep first success** — TCP connection that succeeds first wins; cancel others
4. **Race TCP only** — TLS handshake only on winning connection

If TLS handshake fails on winner, restart with remaining routes.

**Disable Fast Fallback:**
```java
OkHttpClient client = new OkHttpClient.Builder()
    .fastFallback(false)
    .build();
```
