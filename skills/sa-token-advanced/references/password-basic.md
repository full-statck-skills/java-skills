# 密码加密 + Http Basic/Digest

> 密码加密来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/password-secure.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/password-secure.md)
> Http Basic来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/basic-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/basic-auth.md)

## 密码加密（SaSecureUtil）

```java
// 摘要加密
SaSecureUtil.md5("123456");                    // MD5
SaSecureUtil.sha1("123456");                   // SHA1
SaSecureUtil.sha256("123456");                 // SHA256

// 对称加密(AES)
String key = SaSecureUtil.aesRandomKey();      // 生成随机密钥
String encrypted = SaSecureUtil.aesEncrypt(key, "data");
String decrypted = SaSecureUtil.aesDecrypt(key, encrypted);

// 非对称加密(RSA)
String[] rsaKeys = SaSecureUtil.rsaGenerateKeyPair(); // 生成密钥对
String publicKey = rsaKeys[0];
String privateKey = rsaKeys[1];
String encrypted = SaSecureUtil.rsaEncryptByPublic(publicKey, "data");
String decrypted = SaSecureUtil.rsaDecryptByPrivate(privateKey, encrypted);

// TOTP验证码
String secret = SaTotpUtil.generateSecret();   // 生成密钥
String code = SaTotpUtil.generateCode(secret);  // 获取当前验证码
boolean ok = SaTotpUtil.verify(secret, code);   // 验证

// BCrypt
String hash = SaSecureUtil.bCryptPasswordEncoder("123456");
boolean match = SaSecureUtil.bCryptPasswordMatches("123456", hash);
```

## Http Basic 认证

```java
// 方法调用
SaHttpBasicUtil.check("sa:123456");             // 指定账号密码
SaHttpBasicUtil.check();                        // 使用yml配置

// 注解
@SaCheckHttpBasic(account = "sa:123456")

// 全局拦截
SaRouter.match("/test/**", () -> SaHttpBasicUtil.check("sa:123456"));

// URL直接认证
// http://sa:123456@127.0.0.1:8081/test/test3
```

## Http Digest 认证

```java
// 方法调用
SaHttpDigestUtil.check("sa", "123456");
SaHttpDigestUtil.check();                        // 使用yml配置

// 注解
@SaCheckHttpDigest("sa:123456")

// URL直接认证
// http://sa:123456@127.0.0.1:8081/test/testDigest
```

## 配置

```yaml
sa-token:
  # Http Basic 账号密码
  basic: "sa:123456"
  # Http Digest
  # 使用注解或方法调用，无需额外配置
```
