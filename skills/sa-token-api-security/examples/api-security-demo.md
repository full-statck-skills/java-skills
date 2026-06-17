# API 安全三件套综合示例

## 1. API 参数签名

### A系统（请求端）构建签名
```java
public class ApiSignClient {

    public static String buildSignedUrl() {
        Map<String, Object> paramMap = new LinkedHashMap<>();
        paramMap.put("userId", 10001);
        paramMap.put("money", 1000);
        paramMap.put("remark", "转账");

        // 自动添加nonce(随机字符串)+timestamp(时间戳)并计算sign
        String paramStr = SaSignUtil.addSignParamsAndJoin(paramMap);
        String url = "http://b-system.com/api/addMoney?" + paramStr;
        return url;
    }
}
```

### B系统（接收端）校验签名
```java
@RestController
@RequestMapping("/api/")
public class ApiController {

    @SaCheckSign                          // 注解校验
    @RequestMapping("addMoney")
    public SaResult addMoney(long userId, long money) {
        return SaResult.ok("转账成功");
    }

    @RequestMapping("query")
    public SaResult query() {
        SaSignUtil.checkRequest(SaHolder.getRequest());  // 方法校验
        return SaResult.ok("查询成功");
    }
}
```

## 2. API Key 创建与校验

```java
@RestController
@RequestMapping("/apikey/")
public class ApiKeyController {

    // 创建API Key: GET /apikey/create
    @RequestMapping("create")
    public SaResult create() {
        ApiKeyModel ak = SaApiKeyUtil.createApiKeyModel(10001)
            .setTitle("开发插件")
            .addScope("userinfo", "chat");
        SaApiKeyUtil.saveApiKey(ak);
        return SaResult.data(ak.getApiKey());
    }

    // 校验后访问资源
    @SaCheckApiKey(scope = "userinfo")
    @RequestMapping("userinfo")
    public SaResult userinfo() {
        return SaResult.ok("用户信息");
    }

    // 校验API Key: GET /apikey/check?apiKey=xxx
    @RequestMapping("check")
    public SaResult check(String apiKey) {
        SaApiKeyUtil.checkApiKey(apiKey);
        SaApiKeyUtil.checkApiKeyScope(apiKey, "userinfo");
        return SaResult.ok("API Key有效且具有userinfo权限");
    }
}
```

## 3. 临时 Token

```java
@RestController
@RequestMapping("/temp/")
public class TempTokenController {

    // 生成邀请链接: GET /temp/invite?userId=10014
    @RequestMapping("invite")
    public SaResult invite(Long userId) {
        String token = SaTempUtil.createToken(userId, 600);  // 10分钟有效
        String inviteUrl = "http://example.com/register?token=" + token;
        return SaResult.data(inviteUrl);
    }

    // 通过邀请链接注册: GET /temp/register?token=xxx
    @RequestMapping("register")
    public SaResult register(String token) {
        Long userId = SaTempUtil.parseToken(token, Long.class);
        if (userId == null) {
            return SaResult.error("邀请链接无效或已过期");
        }
        return SaResult.ok("注册成功，邀请人：" + userId);
    }
}
```

---

> 来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md)（591行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md)（283行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md)（120行）
