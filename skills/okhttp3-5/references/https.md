# HTTPS/TLS — Full Reference

Official source: https://square.github.io/okhttp/features/https/

Complete guide to HTTPS and TLS configuration in OkHttp.

## ConnectionSpec

OkHttp includes 4 built-in ConnectionSpecs:

| Spec | Description | Use Case |
|------|-------------|----------|
| `RESTRICTED_TLS` | Strictest, compliance requirements | Government, healthcare |
| `MODERN_TLS` | Default, secure modern servers | Most applications |
| `COMPATIBLE_TLS` | Older but still secure servers | Legacy servers |
| `CLEARTEXT` | No encryption | http:// URLs only |

**Default:** OkHttp attempts `MODERN_TLS`.

## Fallback Configuration

```java
OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Arrays.asList(ConnectionSpec.MODERN_TLS, ConnectionSpec.COMPATIBLE_TLS))
    .build();
```

## Custom TLS Configuration

```java
ConnectionSpec spec = new ConnectionSpec.Builder(ConnectionSpec.MODERN_TLS)
    .tlsVersions(TlsVersion.TLS_1_2)
    .cipherSuites(
        CipherSuite.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
        CipherSuite.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
        CipherSuite.TLS_DHE_RSA_WITH_AES_128_GCM_SHA256)
    .build();

OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Collections.singletonList(spec))
    .build();
```

## Debugging TLS Handshake Failures

Error example:
```
Caused by: javax.net.ssl.SSLProtocolException: SSL handshake aborted: ssl=0x7f2719a89e80:
    Failure in SSL library, usually a protocol error
```

**Solutions:**
1. Check server config with [Qualys SSL Labs](https://www.ssllabs.com/ssltest/)
2. Update OkHttp to latest version
3. Try `COMPATIBLE_TLS` fallback
4. On older Android: use Google Play Services ProviderInstaller

## Certificate Pinning

Restrict which certificates/CAs are trusted:

```java
OkHttpClient client = new OkHttpClient.Builder()
    .certificatePinner(
        new CertificatePinner.Builder()
            .add("publicobject.com", "sha256/afwiKY3RxoMmLkuRW1l7QsPZTJPwDS2pdDROQjXw8ig=")
            .build())
    .build();

Request request = new Request.Builder()
    .url("https://publicobject.com/robots.txt")
    .build();

try (Response response = client.newCall(request).execute()) {
    for (Certificate cert : response.handshake().peerCertificates()) {
        System.out.println(CertificatePinner.pin(cert));
    }
}
```

**Get pin from certificate:**
```bash
openssl s_client -servername publicobject.com -connect publicobject.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
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
