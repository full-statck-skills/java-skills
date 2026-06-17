# Sa-Token 统一异常处理 + Session使用 示例

## 全局异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    // 拦截：未登录异常
    @ExceptionHandler(NotLoginException.class)
    public SaResult handlerNotLogin(NotLoginException e) {
        // 根据不同场景返回不同提示
        String msg;
        if (e.getType().equals(NotLoginException.NOT_TOKEN)) {
            msg = "请先登录";
        } else if (e.getType().equals(NotLoginException.INVALID_TOKEN)) {
            msg = "token无效";
        } else if (e.getType().equals(NotLoginException.TOKEN_TIMEOUT)) {
            msg = "登录已过期，请重新登录";
        } else if (e.getType().equals(NotLoginException.BE_REPLACED)) {
            msg = "账号在其他设备登录";
        } else if (e.getType().equals(NotLoginException.KICK_OUT)) {
            msg = "已被踢下线";
        } else {
            msg = "未登录";
        }
        return SaResult.error(msg);
    }

    // 拦截：权限不足异常
    @ExceptionHandler({NotPermissionException.class, NotRoleException.class})
    public SaResult handlerNotPermission() {
        return SaResult.error("权限不足，请联系管理员");
    }

    // 拦截：所有异常
    @ExceptionHandler(Exception.class)
    public SaResult handlerException(Exception e) {
        e.printStackTrace();
        return SaResult.error("系统异常：" + e.getMessage());
    }
}
```

## Session 使用示例

```java
@RestController
@RequestMapping("/session/")
public class SessionController {

    // 存储数据到Session: GET /session/setData?key=name&value=zhang
    @RequestMapping("setData")
    public SaResult setData(String key, String value) {
        StpUtil.getSession().set(key, value);
        return SaResult.ok("写入成功");
    }

    // 从Session读取数据: GET /session/getData?key=name
    @RequestMapping("getData")
    public SaResult getData(String key) {
        Object value = StpUtil.getSession().get(key);
        return SaResult.data(value);
    }

    // 从Token-Session读取（不同端数据隔离）
    @RequestMapping("getTokenData")
    public SaResult getTokenData(String key) {
        Object value = StpUtil.getTokenSession().get(key);
        return SaResult.data(value);
    }

    // 自定义Session
    @RequestMapping("customSession")
    public SaResult customSession(String key) {
        SaSessionCustomUtil.getSessionById("goods-10001").set("price", 99.9);
        Object price = SaSessionCustomUtil.getSessionById("goods-10001").get("price");
        return SaResult.data("价格：" + price);
    }
}
```

---

> 配套配置参考：
> - [references/not-login-scene.md](../references/not-login-scene.md)
> - [references/session.md](../references/session.md)
