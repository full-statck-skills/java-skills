# WebSocket — Full Reference

Complete guide to WebSocket connections with Unirest-Java 4.x.

> ⚠️ WebSocket is a 4.x-only feature. Not available in 3.x.

## Basic WebSocket Connection

```java
Unirest.webSocket("ws://localhost/socket")
    .connect(ws -> {
        ws.sendText("Hello!");
        ws.onMessage(message -> {
            System.out.println("Received: " + message);
        });
    });
```

## WebSocket with POJO Mapping

Requires an ObjectMapper to be configured (GSON or Jackson module):

```java
Unirest.webSocket("ws://localhost/events")
    .connect(ws -> {
        ws.onMessage(event -> {
            MyEvent data = event.asObject(MyEvent.class);
            processEvent(data);
        });
    });
```

## WebSocket Lifecycle

1. **Connect** — `Unirest.webSocket(url).connect(handler)` opens the connection
2. **Send** — `ws.sendText(message)` sends text messages
3. **Receive** — `ws.onMessage(handler)` registers a message handler
4. **Close** — The connection closes when the handler completes or the server disconnects

## Important Notes

- WebSocket connections are persistent and managed by the underlying `java.net.http.HttpClient`
- Object mapping requires an ObjectMapper (GSON or Jackson module must be declared)
- WebSocket is not available in Unirest 3.x — use 3.x's Apache HttpClient WebSocket support or a dedicated library
