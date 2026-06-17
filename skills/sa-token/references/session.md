# Session 会话

## 1. Session 是什么

Session 是会话中专业的数据缓存组件，通过 Session 可以很方便的缓存高频读写数据，提高程序性能。

```java
// 在登录时缓存 user 对象
StpUtil.getSession().set("user", user);

// 在任意处使用这个 user 对象
SysUser user = (SysUser) StpUtil.getSession().get("user");
```

## 2. 三种 Session 模型

| 类型 | 作用域 | 获取方式 | 说明 |
|------|--------|----------|------|
| **Account-Session** | 按账号id共享 | `StpUtil.getSession()` | PC和APP登录同一账号，共享此Session |
| **Token-Session** | 按token隔离 | `StpUtil.getTokenSession()` | 不同设备端即使同一账号也独立隔离 |
| **Custom-Session** | 按自定义key | `SaSessionCustomUtil.getSessionById(key)` | 按任意key分配，如商品Session |

### Account-Session 详解

Sa-Token Session 是 HttpSession 的升级版：
1. 只在调用 `StpUtil.login(id)` 登录会话时才会产生 Session，不会为每个陌生会话都产生 Session，节省性能
2. 登录时产生的 Session 是分配给账号 id 的，而不是分配给指定客户端的。PC、APP 登录同一账号得到同一个 Session，两端可轻松同步数据
3. Sa-Token 支持 Cookie、Header、body 三个途径提交 Token，不限于 Cookie
4. 由于不强依赖 Cookie，只要将 Token 存储到不同地方，便可做到一个客户端同时登录多个账号

### Token-Session 详解

两个设备登录同一账号，但它们的 token 不同。Sa-Token 为每个 token 分配不同的 Token-Session，实现独立数据读写。

### Custom-Session 详解

不依赖特定的账号id或token，而是依赖于你提供的 SessionId。只要两个自定义 Session 的 Id 一致，它们就是同一个 Session。

### Session 模型结构图

假设三个客户端登录同一账号，且配置了不共享 token：
```
                    Account-Session(同一份)
                    ┌─────────────────────┐
                    │      user数据        │
                    └─────────────────────┘
                    ↙          ↓          ↘
            Token-Session  Token-Session  Token-Session
            (PC端token)   (APP端token)   (小程序token)
```

## 3. Account-Session API

```java
StpUtil.getSession();                               // 当前账号(必须登录)
StpUtil.getSession(true);                           // 不存在则新建
StpUtil.getSessionByLoginId(10001);                 // 指定账号
StpUtil.getSessionByLoginId(10001, true);            // 指定账号，无则新建
StpUtil.getSessionBySessionId("xxxx-xxxx");         // 通过SessionId获取
```

## 4. Token-Session API

```java
StpUtil.getTokenSession();                          // 当前Token(需登录)
StpUtil.getTokenSessionByToken(token);              // 指定Token
StpUtil.getAnonTokenSession();                      // 匿名Token-Session(未登录可用)
```

## 5. Custom-Session API

```java
SaSessionCustomUtil.isExists("goods-10001");        // 是否存在
SaSessionCustomUtil.getSessionById("goods-10001");  // 获取(无则新建)
SaSessionCustomUtil.getSessionById("goods-10001", false); // 获取(无则返回null)
SaSessionCustomUtil.deleteSessionById("goods-10001"); // 删除
```

自定义Session有效期默认使用 `SaManager.getConfig().getTimeout()`，可修改：
```java
session.updateTimeout(1000);  // 参数说明和全局有效期保持一致
```

## 6. SaSession 通用操作

```java
// 写值
session.set("name", "zhang");
session.setDefaultValue("name", "zhang");         // 无值才写入

// 取值
session.get("name");
session.get("name", "<defaultValue>");            // 指定默认值
session.get("name", () -> { return ...; });       // 无值执行方法并缓存结果

// 数据类型转换
session.getInt("age");
session.getLong("age");
session.getString("name");
session.getDouble("result");
session.getFloat("result");
session.getModel("key", Student.class);           // 指定转换类型
session.getModel("key", Student.class, <defaultValue>);

// 其他操作
session.has("key");                               // 是否有key
session.delete('name');                           // 删值
session.clear();                                  // 清空所有值
session.keys();                                   // 获取所有key(Set<String>)

// Session本身信息
session.getId();                                  // Session的id
session.getCreateTime();                          // 创建时间戳
session.getDataMap();                             // 底层数据对象(如更新需调用update())
session.update();                                 // 从持久库更新
session.logout();                                 // 注销Session
```

## 7. ⚠️ SaSession vs HttpSession

```java
@PostMapping("/resetPoints")
public void reset(HttpSession session) {
    session.setAttribute("name", 66);
    System.out.println(StpUtil.getSession().get("name")); // null!
}
```

**要点：**
1. `SaSession` 与 `HttpSession` 没有任何关系，在 HttpSession 上写入的值，在 SaSession 中无法取出
2. `HttpSession` 并未被框架接管，使用 Sa-Token 时请在任何情况下均使用 `SaSession`，不要使用 `HttpSession`

## 8. 未登录场景下获取 Token-Session

默认只有登录后才能通过 `StpUtil.getTokenSession()` 获取 Token-Session。两种免登录方式：

1. 全局配置 `tokenSessionCheckLogin: false`
2. 使用匿名 Token-Session
```java
StpUtil.getAnonTokenSession();
```

注意：如果前端没有提交 Token，或者提交的 Token 是无效的，框架将会随机一个新的 Token 值来创建 Token-Session 对象，此 Token 值可以通过 `StpUtil.getTokenValue()` 获取到。

## 9. 三大作用域

Sa-Token 数据存储有三大作用域：

### SaStorage - 请求作用域
存储的数据只在一次请求内有效，请求结束后数据自动清除。无需登录。

```java
SaStorage storage = SaHolder.getStorage();
storage.get("key");    // 取值
storage.set("key", "value");  // 写值
storage.delete("key");  // 删值
```

### SaSession - 会话作用域
存储的数据在一次会话范围内有效。必须登录后才能使用。

```java
SaSession session = StpUtil.getSession();
session.get("key");
session.set("key", "value");
session.delete("key");
```

### SaApplication - 全局作用域
存储的数据在全局范围内有效，应用关闭后数据自动清除。无需登录。

```java
SaApplication application = SaHolder.getApplication();
application.get("key");
application.set("key", "value");
application.delete("key");
```

---

> 来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/session.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/session.md)（182行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/session-model.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/session-model.md)（110行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/three-scope.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/three-scope.md)（42行）
