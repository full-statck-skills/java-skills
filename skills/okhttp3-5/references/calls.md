# Calls — Full Reference

Official source: https://square.github.io/okhttp/features/calls/

Complete guide to HTTP calls in OkHttp.

## Requests

Each HTTP request contains a URL, a method (GET, POST, etc.), and headers. Requests may also contain a body.

```java
Request request = new Request.Builder()
    .url("https://api.example.com/users")
    .header("Authorization", "Bearer token")
    .post(RequestBody.create(json, MediaType.get("application/json")))
    .build();
```

## Responses

Responses contain a status code (200, 404, etc.), headers, and an optional body.

```java
try (Response response = client.newCall(request).execute()) {
    int code = response.code();           // 200
    String message = response.message();  // "OK"
    String body = response.body().string();
}
```

## Rewriting Requests

OkHttp rewrites requests before transmitting for correctness and efficiency:

**Automatically added headers:**
- `Content-Length` — if body is present
- `Transfer-Encoding` — for chunked transfers
- `User-Agent` — OkHttp user agent string
- `Host` — target host
- `Connection` — keep-alive management
- `Content-Type` — from RequestBody
- `Accept-Encoding: gzip` — for transparent compression (unless already present)
- `Cookie` — if cookies are configured

**Conditional GET headers** (when cached response is stale):
- `If-Modified-Since`
- `If-None-Match`

## Rewriting Responses

When transparent compression was used:
- `Content-Encoding` header is dropped
- `Content-Length` header is dropped
- Body is decompressed transparently

For conditional GETs (304 Not Modified):
- Network and cache responses are merged per RFC

## Follow-up Requests

OkHttp automatically follows redirects:

- **302, 301, 307, 308** — redirects to new URL
- **401 Unauthorized** — calls Authenticator for credentials
- **407 Proxy Authentication Required** — calls proxy Authenticator

## Retrying Requests

OkHttp retries when:
- A pooled connection was stale and disconnected
- The server couldn't be reached
- A different route is available

## Calls

Call models the task of satisfying a request through intermediate requests/responses.

**Synchronous:**
```java
try (Response response = client.newCall(request).execute()) {
    // Thread blocks until response is ready
}
```

**Asynchronous:**
```java
client.newCall(request).enqueue(new Callback() {
    @Override
    public void onFailure(Call call, IOException e) {
        // Called on caller's thread when request fails
    }

    @Override
    public void onResponse(Call call, Response response) throws IOException {
        // Called on OkHttp's thread when response arrives
    }
});
```

**Cancellation:**
```java
Call call = client.newCall(request);
call.cancel(); // Fails the call if not yet completed
```

## Dispatcher

For synchronous calls: you manage threads yourself.

For asynchronous calls: Dispatcher manages concurrent requests.

**Default limits:**
- Max 5 requests per host
- Max 64 requests total

**Custom dispatcher:**
```java
Dispatcher dispatcher = new Dispatcher();
dispatcher.setMaxRequests(100);
dispatcher.setMaxRequestsPerHost(10);

OkHttpClient client = new OkHttpClient.Builder()
    .dispatcher(dispatcher)
    .build();
```
