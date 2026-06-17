# NotLoginException 场景值

## 7 种场景值

| 场景值 | 常量 | 含义说明 |
|:-----:|------|---------|
| -1 | `NotLoginException.NOT_TOKEN` | 未能从请求中读取到有效 token |
| -2 | `NotLoginException.INVALID_TOKEN` | 已读取到 token，但是 token 无效 |
| -3 | `NotLoginException.TOKEN_TIMEOUT` | 已读取到 token，但是 token 已经过期 |
| -4 | `NotLoginException.BE_REPLACED` | 已读取到 token，但是 token 已被顶下线 |
| -5 | `NotLoginException.KICK_OUT` | 已读取到 token，但是 token 已被踢下线 |
| -6 | `NotLoginException.TOKEN_FREEZE` | 已读取到 token，但是 token 已被冻结 |
| -7 | `NotLoginException.NO_PREFIX` | 未按照指定前缀提交 token |

## 场景值获取与定制化处理

```java
// 全局异常拦截（拦截项目中的NotLoginException异常）
@ExceptionHandler(NotLoginException.class)
public SaResult handlerNotLoginException(NotLoginException nle) throws Exception {

    // 打印堆栈，以供调试
    nle.printStackTrace();

    // 判断场景值，定制化异常信息
    String message = "";
    if(nle.getType().equals(NotLoginException.NOT_TOKEN)) {
        message = "未能读取到有效 token";
    }
    else if(nle.getType().equals(NotLoginException.INVALID_TOKEN)) {
        message = "token 无效";
    }
    else if(nle.getType().equals(NotLoginException.TOKEN_TIMEOUT)) {
        message = "token 已过期";
    }
    else if(nle.getType().equals(NotLoginException.BE_REPLACED)) {
        message = "token 已被顶下线";
    }
    else if(nle.getType().equals(NotLoginException.KICK_OUT)) {
        message = "token 已被踢下线";
    }
    else if(nle.getType().equals(NotLoginException.TOKEN_FREEZE)) {
        message = "token 已被冻结";
    }
    else if(nle.getType().equals(NotLoginException.NO_PREFIX)) {
        message = "未按照指定前缀提交 token";
    }
    else {
        message = "当前会话未登录";
    }

    return SaResult.error(message);
}
```

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/not-login-scene.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/not-login-scene.md)（68行）
