# HTTPS/TLS Examples

## ConnectionSpec Fallback

```java
// Try MODERN_TLS first, fall back to COMPATIBLE_TLS
OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Arrays.asList(ConnectionSpec.MODERN_TLS, ConnectionSpec.COMPATIBLE_TLS))
    .build();
```

## Custom TLS Configuration

```java
// Restrict to TLS 1.2 with specific cipher suites
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

## Certificate Pinning

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

## Get Pin from Certificate

```bash
openssl s_client -servername publicobject.com -connect publicobject.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

## Custom TrustManager

```java
X509TrustManager trustManager = trustManagerForCertificates(trustedCertificatesInputStream());
SSLContext sslContext = SSLContext.getInstance("TLS");
sslContext.init(null, new TrustManager[]{trustManager}, null);
SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

OkHttpClient client = new OkHttpClient.Builder()
    .sslSocketFactory(sslSocketFactory, trustManager)
    .build();
```

## Conscrypt Provider (BoringSSL)

```java
// Use Conscrypt for consistent TLS across platforms
Security.insertProviderAt(Conscrypt.newProvider(), 1);

OkHttpClient client = new OkHttpClient.Builder()
    .build();
```

## Debugging TLS Handshake Failures

**Error:**
```
javax.net.ssl.SSLProtocolException: SSL handshake aborted
```

**Solutions:**
1. Check server config with Qualys SSL Labs
2. Update OkHttp to latest version
3. Try COMPATIBLE_TLS fallback
4. On older Android: use Google Play Services ProviderInstaller

```java
// Try COMPATIBLE_TLS fallback
OkHttpClient client = new OkHttpClient.Builder()
    .connectionSpecs(Arrays.asList(ConnectionSpec.MODERN_TLS, ConnectionSpec.COMPATIBLE_TLS))
    .build();
```
