# OAuth2-Server 完整搭建示例

## 依赖

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-oauth2</artifactId>
    <version>1.45.0</version>
</dependency>
```

## application.yml

```yaml
server:
  port: 8000

sa-token:
  token-name: satoken
  oauth2-server:
    enable-authorization-code: true
    enable-implicit: true
    enable-password: true
    enable-client-credentials: true
    access-token-timeout: 7200
    refresh-token-timeout: 2592000
    client-token-timeout: 7200
```

## DataLoader 实现

```java
@Component
public class SaOAuth2DataLoaderImpl implements SaOAuth2DataLoader {

    @Override
    public SaClientModel getClientModel(String clientId) {
        if ("app1".equals(clientId)) {
            return new SaClientModel()
                .setClientId("app1")
                .setClientSecret("secret1")
                .setAllowUrl("*")
                .setContractScope("userinfo,openid")
                .setIsCode(true);
        }
        return null;
    }

    @Override
    public Object getLoginIdByAccessToken(String accessToken) {
        return SaOAuth2Util.getLoginIdByAccessToken(accessToken);
    }
}
```

## Server Controller

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

## 授权码模式测试

1. 用户访问: `http://localhost:8000/oauth2/authorize?response_type=code&client_id=app1&redirect_uri=http://localhost:8080/callback&scope=userinfo`
2. 用户登录确认授权
3. 回调地址收到 code
4. 用 code 换 token: `POST /oauth2/token?grant_type=authorization_code&client_id=app1&client_secret=secret1&code={code}`
5. 使用 token 访问资源: `GET /userinfo?access_token={token}`

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-server.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-server.md)（294行）
