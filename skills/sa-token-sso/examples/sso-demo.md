# SSO 模式三完整搭建示例

## SSO-Server 端配置

### 依赖
```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-sso</artifactId>
    <version>1.45.0</version>
</dependency>
```

### application.yml
```yaml
server:
  port: 9000

sa-token:
  token-name: satoken
  timeout: 2592000
  sso-server:
    ticket-timeout: 300
    allow-url: "*"
    secret-key: mySecretKey
```

### Server 端 Controller
```java
@RestController
public class SsoServerController {

    // SSO-Server 处理所有请求: /sso/auth, /sso/doLogin, /sso/ticket 等
    @RequestMapping("/sso/*")
    public Object ssoRequest() {
        return SaSsoServerProcessor.instance.dister();
    }
}
```

## SSO-Client 端配置

### application.yml
```yaml
server:
  port: 9001

sa-token:
  token-name: satoken
  timeout: 2592000
  sso-client:
    mode: mode3
    server-url: http://localhost:9000
    is-slo: true
    secret-key: mySecretKey
```

### Client 端 Controller
```java
@RestController
public class SsoClientController {

    // SSO-Client 处理所有回调请求
    @RequestMapping("/sso/*")
    public Object ssoRequest() {
        return SaSsoClientProcessor.instance.dister();
    }

    // 登录状态
    @RequestMapping("/isLogin")
    public SaResult isLogin() {
        return SaResult.ok("是否登录：" + StpUtil.isLogin());
    }
}
```

## 认证流程

1. 用户访问 Client `http://localhost:9001/user/info`
2. 检测未登录 → 重定向到 Server `http://localhost:9000/sso/auth`
3. 用户输入账号密码登录
4. Server 生成 ticket → 重定向回 Client 并携带 ticket
5. Client 使用 ticket 向 Server 换取 loginId
6. Client 写入本地 Session → 登录成功

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type3.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type3.md)（311行）
