# OAuth2-Server 搭建

> 来源：
> - [oauth2-server.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-server.md)（294行）
> - [oauth2-apidoc.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-apidoc.md)（350行）
> - [oauth2-at-check.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-at-check.md)（94行）
> - [oauth2-interworking.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-interworking.md)（72行）

## 实现 DataLoader

```java
@Component
public class SaOAuth2DataLoaderImpl implements SaOAuth2DataLoader {
    @Override
    public SaClientModel getClientModel(String clientId) {
        if("client1".equals(clientId)) {
            return new SaClientModel()
                .setClientId("client1")
                .setClientSecret("secret1")
                .setAllowUrl("*")
                .setContractScope("userinfo,openid")
                .setIsCode(true)           // 授权码模式
                .setIsImplicit(false)       // 隐式模式
                .setIsPassword(true)        // 密码模式
                .setIsClient(true);         // 客户端模式
        }
        return null;
    }

    @Override
    public Object getLoginIdByAccessToken(String accessToken) {
        return SaOAuth2Util.getLoginIdByAccessToken(accessToken);
    }
}
```

## Server 端点

```java
@RestController
public class OAuth2ServerController {
    @RequestMapping("/oauth2/authorize")
    public Object authorize() { return SaOAuth2Handle.authorize(); }

    @RequestMapping("/oauth2/token")
    public Object token() { return SaOAuth2Handle.token(); }

    @RequestMapping("/oauth2/validate")
    public Object validate() { return SaOAuth2Handle.validate(); }

    @RequestMapping("/oauth2/refresh")
    public Object refresh() { return SaOAuth2Handle.refresh(); }
}
```

## 注解校验

```java
@SaCheckAccessToken               // 校验AccessToken
@SaCheckClientToken               // 校验ClientToken
@SaCheckOAuth2Scope("userinfo")   // 校验Scope
```

## 配置

```yaml
sa-token:
  oauth2:
    access-token-timeout: 7200
    refresh-token-timeout: 2592000
    client-token-timeout: 7200
    is-oidc: false
    is-code: true
```
