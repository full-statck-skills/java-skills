# Security — Full Reference

Official source: https://square.github.io/okhttp/security/

## TLS Configuration History

OkHttp tracks the TLS ecosystem and adjusts its configuration with each release:

| OkHttp Version | TLS Changes |
|---------------|-------------|
| 2.2 | Dropped SSL 3.0 (POODLE attack) |
| 2.3 | Dropped RC4 |
| 3.0 | Dropped SSL 3.0 by default |
| 3.11+ | EventListener API for monitoring |
| 4.0 | Kotlin migration, same TLS config |
| 5.0 | TLS 1.3 support, Fast Fallback |

## ConnectionSpec Summary

| Spec | Description | TLS Versions | Cipher Suites |
|------|-------------|-------------|---------------|
| `RESTRICTED_TLS` | Strictest, compliance | Latest only | Strongest only |
| `MODERN_TLS` | Default, secure | Modern | Modern |
| `COMPATIBLE_TLS` | Older servers | Wider range | Wider range |
| `CLEARTEXT` | http:// URLs | None | None |

## Certificate Providers

OkHttp uses your platform's built-in TLS implementation:

**Java:** Uses JVM's default TrustManager
**Android:** Uses Android's TrustManager
**Conscrypt:** Optional BoringSSL integration for consistent TLS

```java
// Use Conscrypt for consistent TLS across platforms
Security.insertProviderAt(Conscrypt.newProvider(), 1);

OkHttpClient client = new OkHttpClient.Builder()
    .build();
```

## Custom TrustManager

Replace platform CAs with your own:

```java
X509TrustManager trustManager = trustManagerForCertificates(trustedCertificatesInputStream());
SSLContext sslContext = SSLContext.getInstance("TLS");
sslContext.init(null, new TrustManager[]{trustManager}, null);
SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

OkHttpClient client = new OkHttpClient.Builder()
    .sslSocketFactory(sslSocketFactory, trustManager)
    .build();
```

**Warning:** Do not use custom certificates without server TLS admin approval.

## Certificate Pinning

```java
OkHttpClient client = new OkHttpClient.Builder()
    .certificatePinner(
        new CertificatePinner.Builder()
            .add("publicobject.com", "sha256/afwiKY3RxoMmLkuRW1l7QsPZTJPwDS2pdDROQjXw8ig=")
            .build())
    .build();
```

**Get pin from certificate:**
```bash
openssl s_client -servername publicobject.com -connect publicobject.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

## Debugging TLS Handshake Failures

**Error:**
```
Caused by: javax.net.ssl.SSLProtocolException: SSL handshake aborted: ssl=0x7f2719a89e80:
    Failure in SSL library, usually a protocol error
```

**Solutions:**
1. Check server config with [Qualys SSL Labs](https://www.ssllabs.com/ssltest/)
2. Update OkHttp to latest version
3. Try `COMPATIBLE_TLS` fallback
4. On older Android: use Google Play Services ProviderInstaller

```java
OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Arrays.asList(ConnectionSpec.MODERN_TLS, ConnectionSpec.COMPATIBLE_TLS))
    .build();
```

## Security Recommendations

1. **Stay up-to-date** — OkHttp tracks the TLS ecosystem and adjusts with each release
2. **Use MODERN_TLS** — Default is secure; only fall back to COMPATIBLE_TLS if needed
3. **Certificate pinning** — Coordinate with server TLS admin before enabling
4. **Conscrypt** — Use for consistent TLS across Java versions
5. **ProviderInstaller** — On older Android, use Google Play Services for TLS updates
