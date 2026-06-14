# Mocking — Full Reference

Complete guide to mocking HTTP calls with Unirest-Java for unit testing.

## Overview

Mocked clients intercept Unirest calls and return predefined responses without making real HTTP requests.

## Static Mocking

Mock the global static Unirest instance:

```java
class MyTest {
    @Test
    void mockStatic() {
        MockClient mock = MockClient.register();

        mock.expect(HttpMethod.GET, "http://api.example.com/users")
            .thenReturn("You can do anything!");

        assertEquals(
            "You can do anything!",
            Unirest.get("http://api.example.com/users").asString().getBody()
        );
    }
}
```

## Instance Mocking

Mock a specific `UnirestInstance`:

```java
@Test
void mockInstant() {
    UnirestInstance unirest = Unirest.spawnInstance();
    MockClient mock = MockClient.register(unirest);

    mock.expect(HttpMethod.GET, "http://zombo.com")
        .thenReturn("You can do anything!");

    assertEquals(
        "You can do anything!",
        unirest.get("http://zombo.com").asString().getBody()
    );
}
```

## Multiple Expects (Scoring System)

Register multiple expectations. The best match wins based on a points system:
- Positive match = positive points
- Negative match = immediately discarded

```java
@Test
void multipleExpects() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.POST, "https://somewhere.bad")
        .thenReturn("I'm Bad");

    mock.expect(HttpMethod.GET, "http://zombo.com")
        .thenReturn("You can do anything!");

    mock.expect(HttpMethod.GET, "http://zombo.com")
        .header("foo", "bar")
        .thenReturn("You can do anything with headers!");

    // Most specific match wins
    assertEquals("You can do anything with headers!",
        Unirest.get("http://zombo.com")
            .header("foo", "bar")
            .asString().getBody());

    assertEquals("You can do anything!",
        Unirest.get("http://zombo.com")
            .asString().getBody());
}
```

## Verifying Expects

**verifyAll** — all expectations called at least once:
```java
@Test
void verifyAll() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.POST, "http://zombo.com")
        .thenReturn().withStatus(200);

    Unirest.post("http://zombo.com").asString().getBody();

    mock.verifyAll();
}
```

**verify with Times:**
```java
@Test
void verifyMultiple() {
    MockClient mock = MockClient.register();

    var zombo = mock.expect(HttpMethod.POST, "http://zombo.com").thenReturn();
    var homestar = mock.expect(HttpMethod.DELETE, "http://homestarrunner.com").thenReturn();

    Unirest.post("http://zombo.com").asString().getBody();

    zombo.verify();              // At least once
    homestar.verify(Times.never()); // Never called
}
```

## Expected Body Matching

### Simple Bodies

```java
@Test
void simpleBody() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.POST, "http://zombo.com")
        .body("I can do anything? Anything at all?")
        .thenReturn()
        .withStatus(201);

    assertEquals(201,
        Unirest.post("http://zombo.com")
            .body("I can do anything? Anything at all?")
            .asEmpty().getStatus());
}
```

### Form Params (FieldMatcher)

```java
@Test
void formParams() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.POST, "http://zombo.com")
        .body(FieldMatcher.of("foo", "bar", "baz", "qux"))
        .thenReturn()
        .withStatus(201);

    assertEquals(201,
        Unirest.post("http://zombo.com")
            .field("foo", "bar")
            .field("baz", "qux")
            .asEmpty().getStatus());
}
```

## Expected Responses

### Custom Status, Headers, and Body

```java
@Test
void response() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.GET, "http://zombo.com")
        .thenReturn("Care for some tea mum?")
        .withHeader("x-zombo-brewing", "active")
        .withStatus(418, "I am a teapot");

    var response = Unirest.get("http://zombo.com").asString();

    assertEquals(418, response.getStatus());
    assertEquals("I am a teapot", response.getStatusText());
    assertEquals("Care for some tea mum?", response.getBody());
    assertEquals("active", response.getHeaders().getFirst("x-zombo-brewing"));
}
```

### POJO Responses

The mock framework uses the configured ObjectMapper to serialize POJOs:

```java
static class Teapot {
    public String brewstatus = "on";
}

@Test
void pojos() {
    MockClient mock = MockClient.register();

    mock.expect(HttpMethod.GET, "http://zombo.com")
        .thenReturn(new Teapot());

    var response = Unirest.get("http://zombo.com").asString();

    assertEquals("{\"brewstatus\":\"on\"}", response.getBody());
}
```
