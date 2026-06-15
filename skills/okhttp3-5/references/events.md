# Events — Full Reference

Official source: https://square.github.io/okhttp/features/events/

Complete guide to HTTP event monitoring in OkHttp.

## EventListener

Subclass EventListener and override methods for events of interest.

**Successful call event sequence:**
```
callStart → dnsStart → dnsEnd → connectStart → secureConnectStart →
secureConnectEnd → connectEnd → connectionAcquired →
requestHeadersStart → requestHeadersEnd → responseHeadersStart →
responseHeadersEnd → responseBodyStart → responseBodyEnd →
connectionReleased → callEnd
```

**Pooled connection (skips connect events):**
```
callStart → connectionAcquired → requestHeadersStart →
requestHeadersEnd → responseHeadersStart → responseHeadersEnd →
responseBodyStart → responseBodyEnd → connectionReleased → callEnd
```

## EventListener.Factory

Use Factory to create new EventListener per Call for concurrent safety:

```java
EventListener.Factory factory = new EventListener.Factory() {
    @Override
    public EventListener create(Call call) {
        return new TimingEventListener(call.request().url());
    }
};

OkHttpClient client = new OkHttpClient.Builder()
    .eventListenerFactory(factory)
    .build();
```

## 10% Sampling

```java
EventListener.Factory factory = new EventListener.Factory() {
    @Override
    public EventListener create(Call call) {
        if (Math.random() < 0.10) {
            return new MetricsEventListener();
        }
        return EventListener.NONE;
    }
};
```

## Events with Failures

When operation fails:
- `connectFailed()` — failure building connection (not terminal)
- `callFailed()` — call fails permanently

A start event may not have a corresponding end event.

## Events with Retries and Follow-Ups

OkHttp can automatically recover from some failures. Event listeners receive multiple events of the same type when retries are attempted.

A single call may trigger multiple events due to:
- Authentication challenges
- Redirects
- HTTP-layer timeouts

## Availability

Events API is available since OkHttp 3.11. Future releases may introduce new event types.
