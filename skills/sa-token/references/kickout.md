# 踢人下线

踢人下线核心操作：找到指定 loginId 对应的 Token，并设置其失效。

## 三种操作对比

| 操作 | 效果 | Token状态 | 再次访问提示 |
|------|------|-----------|-------------|
| **强制注销** | 等价于对方主动调用了注销方法 | Token无效 | "Token无效" |
| **踢人下线** | 不会清除Token信息，而是将其打上特定标记 | Token已被踢下线 | "Token已被踢下线" |
| **顶人下线** | 登录时顶退旧登录设备（框架内部操作） | Token已被顶下线 | "Token已被顶下线" |

## 强制注销

```java
StpUtil.logout(10001);                    // 强制指定账号注销下线
StpUtil.logout(10001, "PC");              // 强制指定账号指定端注销下线
StpUtil.logoutByTokenValue("token");      // 强制指定 Token 注销下线
```

## 踢人下线

```java
StpUtil.kickout(10001);                    // 将指定账号踢下线
StpUtil.kickout(10001, "PC");              // 将指定账号指定端踢下线
StpUtil.kickoutByTokenValue("token");      // 将指定 Token 踢下线
```

## 顶人下线

"顶人下线"发生在框架登录时顶退旧登录设备，属于框架内部操作：

```java
StpUtil.replaced(10001);                   // 将指定账号顶下线
StpUtil.replaced(10001, "PC");             // 将指定账号指定端顶下线
StpUtil.replacedByTokenValue("token");     // 将指定 Token 顶下线
```

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/kick.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/kick.md)（50行）
