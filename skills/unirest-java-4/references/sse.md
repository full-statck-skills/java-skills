# Server-Sent Events (SSE) — Full Reference

Complete guide to consuming Server-Sent Events with Unirest-Java.

## About SSE

Server-Sent Events (SSE) is a server push technology enabling a client to receive automatic updates from a server via an HTTP connection. Default media type: `text/event-stream`.

## Async Consumption

Subscribe and handle events asynchronously. Returns `CompletableFuture<Void>`:

```java
var future = Unirest.sse("https://stream.wikimedia.org/v2/stream/recentchange")
    .connect(event -> {
        var change = event.asObject(RecentChange.class);
        System.out.println("Changed Page: " + change.getTitle());
    });
```

## Synchronous Consumption

Stream events synchronously using the Stream API:

```java
Unirest.sse("https://stream.wikimedia.org/v2/stream/recentchange")
    .connect()
    .map(event -> event.asObject(RecentChange.class))
    .forEach(change -> System.out.println("Changed Page: " + change.getTitle()));
```

## Important Notes

- **Persistent connections**: SSE connections stay open as long as the server sends data. Use async mode in production.
- **Object mapping requires ObjectMapper**: You must configure an ObjectMapper (GSON or Jackson) for `event.asObject()` to work.
- **Error handling**: SSE connections may drop; implement reconnection logic in production.
