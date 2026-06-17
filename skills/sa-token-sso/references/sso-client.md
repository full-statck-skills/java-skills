# SSO-Client 接入指南

> 来源：
> - [readme.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/readme.md)
> - [signout.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/signout.md)
> - [anon-client.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/anon-client.md)
> - [sso-check-domain.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-check-domain.md)
> - [sso-custom-login.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-custom-login.md)
> - [sso-custom-api.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-custom-api.md)
> - [sso-questions.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-questions.md)

## Client 接入

```yaml
sa-token:
  sso:
    mode: mode1
    auth-url: http://sso-server.com:9000/sso/auth
```

```java
@RequestMapping("/sso/*")
public Object ssoRequest() {
    return SaSsoClientProcessor.instance.dister();
}
```

## 单点注销

Server端和所有配置了SSO的Client端在Server端注销时将同时下线。

```yaml
sa-token:
  sso:
    is-signout: true         # 开启单点注销
    slo-url: http://sso-server.com:9000/sso/signout  # 注销地址
```

## 自定义登录页面

```java
@RequestMapping("/sso/doLogin")
public SaResult doLogin(String name, String pwd) {
    if("admin".equals(name) && "123456".equals(pwd)) {
        SaSsoServerProcessor.instance.dister();
        return SaResult.ok("登录成功");
    }
    return SaResult.error("登录失败");
}
```

## 自定义API路由

```java
SaSsoServerProcessor.instance
    .setAuthApi("/myAuth")
    .setTicketApi("/myTicket");
```

## 域名校验

```yaml
sa-token:
  sso:
    is-check-domain: true
    allow-domains: client1.com, client2.com
```

## FAQ

| 问题 | 回答 |
|------|------|
| 三种模式如何选择？ | 同域名用模式1，跨域同Redis用模式2，完全隔离用模式3 |
| Server和Client必须同一语言？ | 模式1/2需要，模式3不限语言 |
| 如何保证ticket安全？ | 配置secret-key加密通信 |
| SSO和OAuth2区别？ | SSO多系统统一登录，OAuth2第三方授权 |
