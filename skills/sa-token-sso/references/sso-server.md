# SSO-Server 搭建指南

> 来源：
> - [sso-server.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-server.md)（317行）
> - [sso-type1.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type1.md)（287行）
> - [sso-type2.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type2.md)（369行）
> - [sso-type3.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type3.md)（311行）
> - [sso-apidoc.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-apidoc.md)（281行）

## SSO模式一：同域+Cookie

架构：Client1和Client2共用同一父域名(如 `.stp.com`)，共享一个Redis。同域下Cookie自动传递。

**Server端配置：**
```java
@RequestMapping("/sso/*")
public Object ssoRequest() {
    return SaSsoServerProcessor.instance.dister();
}
```

**Client端配置：**
```yaml
sa-token:
  sso:
    mode: mode1
    auth-url: http://sso.stp.com:9000/sso/auth
```

## SSO模式二：跨域+重定向

不同域名但共享同一个Redis，通过URL重定向传递Session。

**Client端配置：**
```yaml
sa-token:
  sso:
    mode: mode2
    auth-url: http://sso.stp.com:9000/sso/auth
```

认证流程：访问Client1→未登录→重定向到Server登录页→用户登录→生成ticket→重定向回Client1→换取Session→登录成功。

## SSO模式三：跨域+跨Redis

不同域名、不同Redis，通过HTTP请求获取ticket。

```yaml
sa-token:
  sso:
    mode: mode3
    auth-url: http://sso.stp.com:9000/sso/auth
    ticket-url: http://sso.stp.com:9000/sso/ticket
```

认证流程：访问Client→未登录→重定向到Server→登录→重定向(带ticket)→Client用ticket通过HTTP向Server换取loginId→写入本地Session。

## Server端API接口

| 路由 | 说明 |
|------|------|
| `/sso/auth` | 认证中心地址 |
| `/sso/doLogin` | 登录接口 |
| `/sso/ticket` | ticket校验接口 |
| `/sso/logout` | 单点注销 |
| `/sso/isLogin` | 是否登录 |

## 配置项

```yaml
sa-token:
  sso:
    mode: mode1             # 模式
    auth-url:               # 授权地址
    ticket-url:             # ticket校验(模式3)
    secret-key: xxxx        # 通信秘钥
    is-check-domain: true   # 域名校验
    allow-domains: *        # 域名白名单
```
