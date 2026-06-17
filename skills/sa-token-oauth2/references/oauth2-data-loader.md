# DataLoader + 域名校验 + 自定义配置

> 来源：
> - [oauth2-data-loader.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-data-loader.md)（151行）
> - [oauth2-check-domain.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-check-domain.md)（101行）
> - [oauth2-custom-api.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-custom-api.md)（104行）
> - [oauth2-custom-login.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-custom-login.md)（94行）

## SaClientModel 完整配置

```java
SaClientModel client = new SaClientModel()
    .setClientId("client1")
    .setClientSecret("secret1")
    .setAllowUrl("*")                       // 允许回调地址
    .setContractScope("userinfo,openid")    // 签约Scope
    .setIsCode(true)                        // 授权码模式
    .setIsImplicit(true)                    // 隐式模式
    .setIsPassword(true)                    // 密码模式
    .setIsClient(true)                      // 客户端模式
    .setIsAutoMode(true);                   // 自动模式(免确认)
```

## 域名校验

```yaml
sa-token:
  oauth2:
    is-check-domain: true
    allow-domains: client1.com, client2.com
```

## 自定义API路由

```java
SaOAuth2ServerProcessor.instance
    .setAuthorizeApi("/myAuthorize")
    .setTokenApi("/myToken");
```

## 自定义登录页

```java
@RestController
public class CustomLoginController {
    @RequestMapping("/oauth2/doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("admin".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            return SaResult.ok();
        }
        return SaResult.error("登录失败");
    }
}
```
