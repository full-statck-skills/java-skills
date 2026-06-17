# 登录认证

## 1. 登录流程

一个完整的登录认证包含以下步骤：打开网站/APP → 进入登录页 → 输入账号+密码 → 系统验证 → 登录成功 → 进行业务操作 → 注销退出。

无论用户采用何种登录方式，本质上都是通过提交一定的认证信息，使系统可以定位到 Ta 的唯一标识——userId。

## 2. 开始登录

```java
// 会话登录：参数填写要登录的账号id
// 建议数据类型：long | int | String，不可以传入复杂类型如User、Admin
StpUtil.login(Object userId);
```

只此一句代码，便可以使会话登录成功。Sa-Token 在背后做了大量工作：
1. 检查此账号是否之前已有登录
2. 为账号生成 Token 凭证与 Session 会话
3. 记录 Token 活跃时间
4. 通知全局侦听器，xx 账号登录成功
5. 检查此账号登录数量是否已达上限
6. 将 Token 注入到请求上下文
7. 等等其它工作

关键点：**Sa-Token 为这个账号创建了一个 token 凭证，且通过 Cookie 上下文返回给了前端。**

### 完整登录接口示例

```java
@RequestMapping("doLogin")
public SaResult doLogin(String name, String pwd) {
    // 第一步：比对前端提交的账号名称、密码
    if("zhang".equals(name) && "123456".equals(pwd)) {
        // 第二步：根据账号id，进行登录
        StpUtil.login(10001);
        return SaResult.ok("登录成功");
    }
    return SaResult.error("登录失败");
}
```

> `StpUtil.login(id)` 方法利用了 Cookie 自动注入的特性，省略了手写返回 token 的代码。
> Cookie 可以从后端控制往浏览器中写入 token 值，并在前端每次发起请求时自动提交 token 值。

## 3. 校验是否登录

```java
// 判断当前会话是否已经登录，返回 true=已登录，false=未登录
StpUtil.isLogin();

// 检验当前会话是否已经登录, 如果已登录代码会安全通过，未登录则抛出异常：NotLoginException
StpUtil.checkLogin();
```

### 两种处理方式

方式一：根据是否登录返回不同信息
```java
@RequestMapping("myInfo")
public String myInfo() {
    if(StpUtil.isLogin()) {
        return "我的资料信息...";
    } else {
        return "未登录，请先登录";
    }
}
```

方式二：直接抛出全局异常（配合全局异常处理器）
```java
@RequestMapping("myInfo")
public String myInfo() {
    StpUtil.checkLogin();  // 未登录直接抛 NotLoginException
    return "我的资料信息";
}
```

全局异常处理器：
```java
@RestControllerAdvice
public class GlobalException {
    @ExceptionHandler(NotLoginException.class)
    public SaResult handlerException(NotLoginException e) {
        return SaResult.error(e.getMessage());
    }
}
```

NotLoginException 代表当前会话暂未登录，可能的原因：前端没有提交 token、提交的 token 无效、提交的 token 已过期等。

## 4. 会话查询

```java
StpUtil.getLoginId();                // 获取当前会话账号id, 未登录抛NotLoginException
StpUtil.getLoginIdAsString();        // 获取并转化为String类型
StpUtil.getLoginIdAsInt();           // 获取并转化为int类型
StpUtil.getLoginIdAsLong();          // 获取并转化为long类型
StpUtil.getLoginIdDefaultNull();     // 未登录返回 null
StpUtil.getLoginId(T defaultValue);  // 未登录返回默认值
```

## 5. Token 查询

```java
StpUtil.getTokenValue();            // 获取当前会话的 token 值
StpUtil.getTokenName();             // 获取当前StpLogic的 token 名称
StpUtil.getLoginIdByToken(token);   // 获取指定token对应的账号id，未登录返回null
StpUtil.getTokenTimeout();          // 获取当前会话剩余有效期（秒，-1永久）
StpUtil.getTokenInfo();             // 获取当前会话的 token 信息参数
```

### TokenInfo 参数详解

```json
{
    "tokenName": "satoken",          // token名称
    "tokenValue": "e67b99f1-...",    // token值
    "isLogin": true,                 // 此token是否已经登录
    "loginId": "10001",             // 此token对应的LoginId
    "loginType": "login",           // 账号类型标识
    "tokenTimeout": 2591977,        // token剩余有效期(秒)
    "sessionTimeout": 2591977,      // Account-Session剩余时间(秒)
    "tokenSessionTimeout": -2,      // Token-Session剩余时间(-2=不存在此缓存)
    "tokenActiveTimeout": -1,       // 距离冻结还剩的时间(秒)
    "loginDevice": "DEF"            // 登录设备类型
}
```

## 6. 会话注销

```java
StpUtil.logout();                    // 当前会话注销登录
StpUtil.logout(10001);               // 强制指定账号注销下线
StpUtil.logout(10001, "PC");         // 强制指定账号指定端注销下线
StpUtil.logoutByTokenValue(token);   // 强制指定 Token 注销下线
```

## 7. StpUtil 完整 API 参考

### 常规操作
```java
StpUtil.getStpLogic();                    // 获取底层StpLogic对象
StpUtil.setStpLogic(newStpLogic);         // 安全的重置底层StpLogic引用
StpUtil.getLoginType();                   // 获取账号类型(login/user/admin等)
StpUtil.getTokenName();                   // 获取Token的名称
StpUtil.getTokenValue();                  // 获取本次请求前端提交的Token
StpUtil.getTokenValueNotCut();            // 获取本次请求前端提交的Token(不裁剪前缀)
StpUtil.setTokenValue(tokenValue);        // 在当前会话中写入Token值
StpUtil.setTokenValue(tokenValue, timeout); // 写入Token值并指定Cookie有效期
StpUtil.setTokenValue(tokenValue, loginParameter); // 写入Token值并指定登录参数
```

### 登录相关
```java
StpUtil.login(10001);                                  // 会话登录
StpUtil.login(10001, "APP");                            // 登录并指定设备类型
StpUtil.login(10001, true);                             // 登录并指定是否记住我
StpUtil.login(10001, 86400);                            // 登录并指定token有效期(秒)
StpUtil.login(10001, loginParameter);                   // 登录并指定所有登录参数Model
StpUtil.createLoginSession(10001);                      // 创建登录会话(不注入Token到上下文)
StpUtil.getOrCreateLoginSession(10001);                  // 获取/创建登录会话
```

### 注销相关
```java
StpUtil.logout();                                        // 会话注销
StpUtil.logout(logoutParameter);                         // 根据注销参数
StpUtil.logout(10001);                                   // 根据账号id
StpUtil.logout(10001, "PC");                             // 根据账号id+设备类型
StpUtil.logout(10001, logoutParameter);                  // 根据账号id+注销参数
StpUtil.logoutByTokenValue(token);                       // 指定Token强制注销
StpUtil.logoutByTokenValue(token, logoutParameter);       // 指定Token强制注销(带参数)
StpUtil.kickout(10001);                                  // 踢人下线
StpUtil.kickout(10001, "PC");                            // 踢人下线(指定设备)
StpUtil.kickoutByTokenValue(token);                      // 踢人下线(指定Token)
StpUtil.replaced(10001);                                 // 顶人下线
StpUtil.replaced(10001, "PC");                           // 顶人下线(指定设备)
StpUtil.replacedByTokenValue(token);                     // 顶人下线(指定Token)
```

### 会话查询
```java
StpUtil.isLogin();                                       // 当前会话是否已登录
StpUtil.isLogin(10001);                                  // 指定账号是否已登录
StpUtil.checkLogin();                                    // 校验登录(未登录抛异常)
StpUtil.getLoginId();                                    // 获取当前账号id
StpUtil.getLoginId(defaultValue);                        // 获取当前账号id(可指定默认值)
StpUtil.getLoginIdDefaultNull();                         // 获取当前账号id(未登录返回null)
StpUtil.getLoginIdAsString()/AsInt()/AsLong();           // 类型化获取
StpUtil.getLoginIdByToken(token);                        // 指定Token对应的账号id
StpUtil.getLoginIdByTokenNotThinkFreeze(token);          // 指定Token对应账号id(不考虑冻结)
```

### Token有效期相关
```java
StpUtil.getTokenActiveTimeout();        // 距离冻结剩余时间(秒)
StpUtil.getTokenLastActiveTime();       // Token最后活跃时间
StpUtil.checkActiveTimeout();           // 检查是否冻结(冻结抛异常)
StpUtil.updateLastActiveToNow();        // 续签(更新最后操作时间)
StpUtil.getTokenTimeout();              // Token剩余有效时间(秒)
StpUtil.getTokenTimeout(token);         // 指定Token剩余时间
StpUtil.getSessionTimeout();            // Account-Session剩余时间
StpUtil.getTokenSessionTimeout();       // Token-Session剩余时间
StpUtil.renewTimeout(timeout);          // Token续期
StpUtil.renewTimeout(token, timeout);   // 指定Token续期
```

### 会话管理
```java
StpUtil.searchTokenValue(keyword, start, size, sort);     // 条件查询Token
StpUtil.searchSessionId(keyword, start, size, sort);      // 条件查询SessionId
StpUtil.searchTokenSessionId(keyword, start, size, sort); // 条件查询Token-SessionId
```

## 8. 完整测试 Controller

```java
@RestController
@RequestMapping("/acc/")
public class LoginController {

    // 登录: http://localhost:8081/acc/doLogin?name=zhang&pwd=123456
    @RequestMapping("doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }

    // 登录状态: http://localhost:8081/acc/isLogin
    @RequestMapping("isLogin")
    public SaResult isLogin() {
        return SaResult.ok("是否登录：" + StpUtil.isLogin());
    }

    // Token信息: http://localhost:8081/acc/tokenInfo
    @RequestMapping("tokenInfo")
    public SaResult tokenInfo() {
        return SaResult.data(StpUtil.getTokenInfo());
    }

    // 注销: http://localhost:8081/acc/logout
    @RequestMapping("logout")
    public SaResult logout() {
        StpUtil.logout();
        return SaResult.ok();
    }
}
```

---

> 本文档内容来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/login-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/login-auth.md)（249行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/api/stp-util.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/api/stp-util.md)（234行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/token-info.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/token-info.md)（21行）
