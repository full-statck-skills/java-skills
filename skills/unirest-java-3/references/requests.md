# Making Requests — Full Reference (Unirest 3.x)

Complete guide to building HTTP requests with Unirest-Java 3.x.

## Basic Request Types

```java
Unirest.get("http://localhost/users").asString();
Unirest.post("http://localhost/users").body(json).asJson();
Unirest.put("http://localhost/users/1").body(user).asEmpty();
Unirest.delete("http://localhost/users/1").asEmpty();
Unirest.patch("http://localhost/users/1").body(patch).asJson();
```

## Route Parameters

Dynamic URL parameters with `{placeholder}` syntax:

```java
Unirest.get("http://localhost/{fruit}")
    .routeParam("fruit", "apple")
    .asString();
// Results in http://localhost/apple
```

- Placeholder format: `{custom_name}`
- All values are URL-encoded automatically
- Multiple parameters supported: `{version}/{resource}/{id}`

## Default Base URLs

Configure a base URL for all requests without a full URL:

```java
Unirest.config().defaultBaseUrl("http://homestar.com");
Unirest.get("/runner").asString(); // GET http://homestar.com/runner
```

## Query Parameters

**Single params:**
```java
Unirest.get("http://localhost")
    .queryString("fruit", "apple")
    .queryString("droid", "R2D2")
    .asString();
// http://localhost?fruit=apple&droid=R2D2
```

**Arrays and maps:**
```java
Unirest.get("http://localhost")
    .queryString("fruit", Arrays.asList("apple", "orange"))
    .queryString(ImmutableMap.of("droid", "R2D2", "beatle", "Ringo"))
    .asString();
// http://localhost?fruit=apple&fruit=orange&droid=R2D2&beatle=Ringo
```

All param values are URL-encoded automatically.

## Headers

```java
Unirest.get("http://localhost")
    .header("Accept", "application/json")
    .header("X-Custom-Header", "hello")
    .asString();
```

## Basic Authentication

```java
Unirest.get("http://localhost")
    .basicAuth("user", "password1!")
    .asString();
// Adds: Authorization: Basic dXNlcjpwYXNzd29yZDEh
```

> ⚠️ Always use HTTPS with basic auth.

## Body Data

### Entity Bodies

Full body as string (default Content-Type: `text/plain; charset=UTF-8`):
```java
Unirest.post("http://localhost")
    .body("This is the entire body")
    .asEmpty();
```

Object body (serialized via ObjectMapper — GSON included by default):
```java
Unirest.post("http://localhost")
    .header("Content-Type", "application/json")
    .body(new SomeUserObject("Bob"))
    .asEmpty();
```

### JSON Patch Bodies (RFC-6902)

Default Content-Type: `application/json-patch+json`

```java
Unirest.jsonPatch("http://localhost")
    .add("/fruits/-", "Apple")
    .remove("/bugs")
    .replace("/lastname", "Flintstone")
    .test("/firstname", "Fred")
    .move("/old/location", "/new/location")
    .copy("/original/location", "/new/location")
    .asJson();
```

### Basic Forms

Content-Type: `application/x-www-form-urlencoded`

```java
Unirest.post("http://localhost")
    .field("fruit", "apple")
    .field("droid", "R2D2")
    .asEmpty();
// fruit=apple&droid=R2D2
```

### File Uploads

Content-Type: `multipart/form-data`

```java
// File object
Unirest.post("http://localhost")
    .field("upload", new File("/MyFile.zip"))
    .asEmpty();

// InputStream with filename
InputStream file = new FileInputStream(new File("/MyFile.zip"));
Unirest.post("http://localhost")
    .field("upload", file, "MyFile.zip")
    .asEmpty();
```

### Upload Progress Monitoring

```java
Unirest.post("http://localhost")
    .field("upload", new File("/MyFile.zip"))
    .uploadMonitor((field, fileName, bytesWritten, totalBytes) -> {
        updateProgressBar(totalBytes - bytesWritten);
    })
    .asEmpty();
```

## Asynchronous Requests

```java
CompletableFuture<HttpResponse<JsonNode>> future = Unirest.post("http://localhost/post")
    .header("accept", "application/json")
    .field("param1", "value1")
    .field("param2", "value2")
    .asJsonAsync(response -> {
        int code = response.getStatus();
        JsonNode body = response.getBody();
    });
```

## Per-Request Proxy (3.x Only)

```java
Unirest.get("http://localhost/data")
    .proxy("proxy.com", 8080)
    .asString();
```

> ⚠️ Per-request proxies are removed in 4.x. Use global `Unirest.config().proxy()` instead.

## Paged Requests

Follow paginated APIs until all pages are consumed:

```java
PagedList<Doggos> result = Unirest.get("https://somewhere/dogs")
    .asPaged(
        r -> r.asObject(Doggos.class),
        r -> r.getHeaders().getFirst("nextPage")
    );
```

## Client Certificates

Provide a custom PKCS#12 keystore for mutual TLS:

```java
// From file path
Unirest.config()
    .clientCertificateStore("/path/mykeystore.p12", "password1!");

// From KeyStore object
Unirest.config()
    .clientCertificateStore(keyStore, "password1!");
```
