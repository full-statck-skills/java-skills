# 踢人下线 + Session会话 + 全局异常 示例

> 来源: 官方 demo `KickoutController` + `SaSessionController` + `GlobalException` + `SearchSessionController`

## 1. 踢人下线

```java
@RestController
@RequestMapping("/kickout/")
public class KickoutController {

    // 强制注销: GET /kickout/logout?userId=10001
    @RequestMapping("logout")
    public SaResult logout(long userId) {
        StpUtil.logout(userId);       // 清除Token，再次访问: "Token无效"
        return SaResult.ok();
    }

    // 踢人下线: GET /kickout/kickout?userId=10001
    @RequestMapping("kickout")
    public SaResult kickout(long userId) {
        StpUtil.kickout(userId);      // 打标记，再次访问: "Token已被踢下线"
        return SaResult.ok();
    }

    // 按Token踢人: GET /kickout/kickoutByTokenValue?tokenValue=xxx
    @RequestMapping("kickoutByTokenValue")
    public SaResult kickoutByTokenValue(String tokenValue) {
        StpUtil.kickoutByTokenValue(tokenValue);
        return SaResult.ok();
    }
}
```

## 2. Session 存储/读取

```java
@RestController
@RequestMapping("/session/")
public class SaSessionController {

    // 存储用户信息到Session: GET /session/setUser?name=zhang&age=18
    @RequestMapping("setUser")
    public SaResult setUser(String name, int age) {
        StpUtil.getSession().set("user", new SysUser(10001, name, age));
        return SaResult.ok("用户信息已存入Session");
    }

    // 读取用户信息: GET /session/getUser
    @RequestMapping("getUser")
    public SaResult getUser() {
        SysUser user = (SysUser) StpUtil.getSession().get("user");
        return SaResult.data(user);
    }

    // Token-Session(不同端隔离): GET /session/setTokenData?key=cart&value=item1
    @RequestMapping("setTokenData")
    public SaResult setTokenData(String key, String value) {
        StpUtil.getTokenSession().set(key, value);
        return SaResult.ok("已存入Token-Session");
    }

    // 读取Token-Session: GET /session/getTokenData?key=cart
    @RequestMapping("getTokenData")
    public SaResult getTokenData(String key) {
        String value = (String) StpUtil.getTokenSession().get(key);
        return SaResult.data(value);
    }

    // 自定义Session: GET /session/customSession
    @RequestMapping("customSession")
    public SaResult customSession() {
        SaSessionCustomUtil.getSessionById("goods-10001").set("price", 99.9);
        Double price = SaSessionCustomUtil.getSessionById("goods-10001").get("price", Double.class);
        return SaResult.data("价格：" + price);
    }
}
```

## 3. 会话查询(分页搜索)

```java
@RestController
@RequestMapping("/search/")
public class SearchSessionController {

    // 模拟登录多个账号: GET /search/login?userId=10001&name=zhang&age=18
    @RequestMapping("login")
    public SaResult login(long userId, String name, int age) {
        StpUtil.login(userId);
        SysUser user = new SysUser(userId, name, age);
        StpUtil.getSession().set("user", user);
        return SaResult.ok("账号登录成功");
    }

    // 分页查询会话: GET /search/getList?start=0&size=10
    @RequestMapping("getList")
    public SaResult getList(int start, int size) {
        List<SaSession> sessionList = new ArrayList<>();
        List<String> sessionIdList = StpUtil.searchSessionId("", start, size, false);
        for (String sessionId : sessionIdList) {
            SaSession session = StpUtil.getSessionBySessionId(sessionId);
            sessionList.add(session);
        }
        return SaResult.data(sessionList);
    }
}
```

## 4. 全局异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotLoginException.class)
    public SaResult handlerNotLogin(NotLoginException e) {
        String msg;
        if (e.getType().equals(NotLoginException.NOT_TOKEN))       msg = "请先登录";
        else if (e.getType().equals(NotLoginException.INVALID_TOKEN)) msg = "token无效";
        else if (e.getType().equals(NotLoginException.TOKEN_TIMEOUT)) msg = "登录已过期";
        else if (e.getType().equals(NotLoginException.BE_REPLACED))  msg = "账号在其他设备登录";
        else if (e.getType().equals(NotLoginException.KICK_OUT))     msg = "已被踢下线";
        else msg = "未登录";
        return SaResult.error(msg);
    }

    @ExceptionHandler({NotPermissionException.class, NotRoleException.class})
    public SaResult handlerNotPermission() {
        return SaResult.error("权限不足，请联系管理员");
    }

    @ExceptionHandler(Exception.class)
    public SaResult handlerException(Exception e) {
        e.printStackTrace();
        return SaResult.error("系统异常：" + e.getMessage());
    }
}
```

---

> 来源:
> - [KickoutController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/use/KickoutController.java)
> - [SaSessionController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/use/SaSessionController.java)
> - [SearchSessionController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/SearchSessionController.java)
