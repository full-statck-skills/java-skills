# Token 有效期详解

## 双策略配置

```yaml
sa-token:
  # token 有效期（单位：秒），默认30天，-1代表永不过期
  timeout: 2592000
  # token 最低活跃频率（单位：秒），-1代表不限制，永不冻结
  active-timeout: -1
```

## 银行比喻

| 策略 | 比喻 | 说明 |
|------|------|------|
| **timeout** | 银行卡最长有效期（3年） | 到期后卡被删除，需重新办卡 |
| **active-timeout** | 必须每月来银行一次 | 超过1月不来，卡被冻结（但不删除） |

两者可以同时配置，只要其中一个有效期超出了范围，Token 就不可用。

## timeout（绝对过期详解）

1. `timeout` 代表 Token 的长久有效期，单位/秒。配置为 2592000(30天)，30天后 Token 必定过期。
2. v1.29.0+ 新增续期方法：`StpUtil.renewTimeout(100)`
3. `timeout` 配置为 -1 后，代表永久有效，不会过期。

## active-timeout（相对过期详解）

1. `active-timeout` 代表最低活跃频率，单位/秒。配置为 1800(30分钟)，代表用户如果30分钟无操作，Token 会被冻结（但不会删除）。
2. 30分钟内用户有操作，则会再次续签30分钟。用户一直操作则一直续签。
3. `active-timeout` 配置为 -1 后，代表永久有效。

## active-timeout 自动续签

Sa-Token 在登录时开始计时，每次直接或间接调用 `getLoginId()`、`getTokenSession()` 时进行一次冻结检查与续签操作：
- 无操作时间太长，Token 已被冻结 → 抛出 `NotLoginException`（场景值=-6 `TOKEN_FREEZE`）
- 在有效期内通过检查 → Token 成功续签

### 支持自动续签的方法

**登录校验类：**
- `StpUtil.checkLogin()`
- `StpUtil.getLoginId()`
- `StpUtil.getLoginIdAsInt()`、`AsString()`、`AsLong()`

**Session类：**
- `StpUtil.getSession()`
- `StpUtil.getTokenSession()`

**角色认证类：**
- `StpUtil.getRoleList()`
- `StpUtil.hasRole()`、`hasRoleAnd()`、`hasRoleOr()`
- `StpUtil.checkRole()`、`checkRoleAnd()`、`checkRoleOr()`

**权限认证类：**
- `StpUtil.getPermissionList()`
- `StpUtil.hasPermission()`、`hasPermissionAnd()`、`hasPermissionOr()`
- `StpUtil.checkPermission()`、`checkPermissionAnd()`、`checkPermissionOr()`

**二级认证类：**
- `StpUtil.openSafe()`、`isSafe()`、`checkSafe()`、`getSafeTime()`、`closeSafe()`

**注解：**
- `@SaCheckLogin`、`@SaCheckRole`、`@SaCheckPermission`、`@SaCheckSafe`

## 手动续签 active-timeout

```java
// 先检查是否已被冻结
StpUtil.checkActiveTimeout();

// 续签：将最后操作时间更新为当前时间戳
StpUtil.updateLastActiveToNow();

// 为指定 Token 续签
StpUtil.stpLogic.updateLastActiveToNow(tokenValue);
```

关闭自动续签：`sa-token.auto-renew: false`

## timeout 手动续期

```java
// 对当前 Token 续期100秒
StpUtil.renewTimeout(100);

// 对指定 Token 续期
StpUtil.renewTimeout(token, 100);
```

## StpUtil 有效期相关方法

```java
StpUtil.getTokenActiveTimeout();         // 距离冻结剩余时间(秒)
StpUtil.getTokenLastActiveTime();        // Token最后活跃时间
StpUtil.checkActiveTimeout();            // 检查是否冻结
StpUtil.updateLastActiveToNow();         // 续签
StpUtil.getTokenTimeout();               // Token剩余有效时间(秒)
StpUtil.getTokenTimeout(token);          // 指定Token剩余时间
StpUtil.getSessionTimeout();             // Account-Session剩余时间
StpUtil.getTokenSessionTimeout();        // Token-Session剩余时间
StpUtil.renewTimeout(timeout);           // 续期
StpUtil.renewTimeout(token, timeout);    // 指定Token续期
```

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/token-timeout.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/token-timeout.md)（131行）
