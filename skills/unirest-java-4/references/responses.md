# Handling Responses — Full Reference

Complete guide to handling HTTP responses with Unirest-Java.

## Response Types

Unirest makes the request when you invoke an `as[type]()` method. The response is `HttpResponse<T>` with status, headers, and body.

### Empty Responses

Ignores any body; returns status and headers only:

```java
HttpResponse response = Unirest.delete("http://localhost").asEmpty();
```

### String Responses

```java
String body = Unirest.get("http://localhost")
    .asString()
    .getBody();
```

### Object Mapped Responses

Requires an ObjectMapper (GSON or Jackson module):

```java
Book book = Unirest.get("http://localhost/books/1")
    .asObject(Book.class)
    .getBody();
```

### Generic Types

Use `GenericType` to avoid type erasure:

```java
List<Book> books = Unirest.get("http://localhost/books/")
    .asObject(new GenericType<List<Book>>(){})
    .getBody();
```

### JSON Responses

Lightweight JSON without full object mapping:

```java
String wheel = Unirest.get("http://some.json.com")
    .asJson()
    .getBody()
    .getObject()
    .getJSONObject("car")
    .getJSONArray("wheels")
    .get(0);
```

### File Responses

```java
File result = Unirest.get("http://some.file.location/file.zip")
    .asFile("/disk/location/file.zip")
    .getBody();
```

### Download Progress Monitoring

```java
Unirest.get("http://localhost")
    .downLoadMonitor((b, fileName, bytesWritten, totalBytes) -> {
        updateProgressBar(totalBytes - bytesWritten);
    })
    .asFile("/disk/location/file.zip");
```

## Parsing Errors

When `asObject()` or `asJson()` fails to parse, the body is null and a `ParsingException` is available:

```java
HttpResponse<Book> response = Unirest.get(url).asObject(Book.class);

response.getParsingError().ifPresent(ex -> {
    String originalBody = ex.getOriginalBody(); // Raw response body
    String message = ex.getMessage();           // Parse error message
    Throwable cause = ex.getCause();            // Original exception
});
```

## Mapping Error Objects

REST APIs often return error objects. Map them with `mapError()`:

```java
HttpResponse<Book> book = Unirest.get("http://localhost/books/{id}")
    .asObject(Book.class);

// Returns null if no error
Error err = book.mapError(Error.class);
```

**Inside ifFailure:**
```java
Unirest.get("http://localhost/books/{id}")
    .asObject(Book.class)
    .ifFailure(Error.class, r -> {
        Error e = r.getBody();
    });
```

## Body Type Conversion Without ObjectMapper

Map response body using a simple function:

```java
int body = Unirest.get("http://httpbin/count")
    .asString()
    .mapBody(Integer::valueOf);
```

## Large Responses

Methods like `asString()` and `asJson()` read the entire stream into memory. For large responses, use functional methods:

```java
// Functional mapper
Map result = Unirest.get("http://localhost/data")
    .asObject(i -> new Gson().fromJson(i.getContentReader(), HashMap.class))
    .getBody();

// Consumer (e.g., write to disk)
Unirest.get("http://localhost/large-file")
    .thenConsumeAsync(r -> {
        // Write to file or process stream
    });
```

## Error Handling

Chain `ifSuccess` and `ifFailure` handlers:

```java
Unirest.get("http://somewhere")
    .asJson()
    .ifSuccess(response -> someSuccessMethod(response))
    .ifFailure(response -> {
        log.error("Oh No! Status: " + response.getStatus());
        response.getParsingError().ifPresent(e -> {
            log.error("Parsing Exception: ", e);
            log.error("Original body: " + e.getOriginalBody());
        });
    });
```

- `ifSuccess` — called for 2xx responses and successful body processing
- `ifFailure` — called for 4xx/5xx responses or body processing failures
