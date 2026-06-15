# Basic Usage Examples

## GET Request (Synchronous)

```java
OkHttpClient client = new OkHttpClient();

String run(String url) throws IOException {
    Request request = new Request.Builder()
        .url(url)
        .build();

    try (Response response = client.newCall(request).execute()) {
        return response.body().string();
    }
}
```

## GET Request (Asynchronous)

```java
OkHttpClient client = new OkHttpClient();

Request request = new Request.Builder()
    .url("https://api.example.com/users")
    .build();

client.newCall(request).enqueue(new Callback() {
    @Override
    public void onFailure(Call call, IOException e) {
        e.printStackTrace();
    }

    @Override
    public void onResponse(Call call, Response response) throws IOException {
        try (ResponseBody body = response.body()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected code " + response);
            }
            System.out.println(body.string());
        }
    }
});
```

## POST JSON

```java
public static final MediaType JSON = MediaType.get("application/json");

OkHttpClient client = new OkHttpClient();

String post(String url, String json) throws IOException {
    RequestBody body = RequestBody.create(json, JSON);
    Request request = new Request.Builder()
        .url(url)
        .post(body)
        .build();

    try (Response response = client.newCall(request).execute()) {
        return response.body().string();
    }
}
```

## POST Form Data

```java
RequestBody formBody = new FormBody.Builder()
    .add("username", "alice")
    .add("password", "secret")
    .build();

Request request = new Request.Builder()
    .url("https://api.example.com/login")
    .post(formBody)
    .build();
```

## POST Multipart (File Upload)

```java
RequestBody fileBody = RequestBody.create(
    new File("photo.jpg"),
    MediaType.get("image/jpeg")
);

RequestBody requestBody = new MultipartBody.Builder()
    .setType(MultipartBody.FORM)
    .addFormDataPart("title", "My Photo")
    .addFormDataPart("photo", "photo.jpg", fileBody)
    .build();

Request request = new Request.Builder()
    .url("https://api.example.com/upload")
    .post(requestBody)
    .build();
```

## PUT Request

```java
String json = "{\"name\":\"Alice Updated\"}";
RequestBody body = RequestBody.create(json, MediaType.get("application/json"));

Request request = new Request.Builder()
    .url("https://api.example.com/users/1")
    .put(body)
    .build();
```

## DELETE Request

```java
Request request = new Request.Builder()
    .url("https://api.example.com/users/1")
    .delete()
    .build();
```

## Timeout Configuration

```java
OkHttpClient client = new OkHttpClient.Builder()
    .connectTimeout(10, TimeUnit.SECONDS)
    .readTimeout(30, TimeUnit.SECONDS)
    .writeTimeout(30, TimeUnit.SECONDS)
    .callTimeout(60, TimeUnit.SECONDS)
    .build();
```

## Custom Headers

```java
Request request = new Request.Builder()
    .url("https://api.example.com/users")
    .header("Authorization", "Bearer token123")
    .addHeader("Accept", "application/json")
    .addHeader("X-Custom-Header", "value")
    .build();
```

## Response Handling

```java
try (Response response = client.newCall(request).execute()) {
    // Status
    int code = response.code();
    String message = response.message();
    
    // Headers
    String contentType = response.header("Content-Type");
    String server = response.header("Server");
    
    // Body
    String body = response.body().string();
    
    // Check success
    if (!response.isSuccessful()) {
        throw new IOException("Unexpected code " + response);
    }
}
```
