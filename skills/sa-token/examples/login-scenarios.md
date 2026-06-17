# 登录认证 - 多种场景示例

> 来源: 官方 demo `com.pj.cases.use.LoginAuthController` + `RememberMeController` + `NotCookieController`

## 场景1：基础登录/注销

```java
@RestController
@RequestMapping("/acc/")
public class LoginAuthController {

    // 登录: GET /acc/doLogin?name=zhang&pwd=123456
    @RequestMapping("doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }

    // 查询登录状态: GET /acc/isLogin
    @RequestMapping("isLogin")
    public SaResult isLogin() {
        return SaResult.ok("是否登录：" + StpUtil.isLogin());
    }

    // 查询Token信息: GET /acc/tokenInfo
    @RequestMapping("tokenInfo")
    public SaResult tokenInfo() {
        return SaResult.data(StpUtil.getTokenInfo());
    }

    // 注销: GET /acc/logout
    @RequestMapping("logout")
    public SaResult logout() {
        StpUtil.logout();
        return SaResult.ok();
    }
}
```

## 场景2：记住我模式登录

```java
@RestController
@RequestMapping("/RememberMe/")
public class RememberMeController {

    // 记住我(持久Cookie): GET /RememberMe/doLogin?name=zhang&pwd=123456
    @RequestMapping("doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001, true);  // true=持久Cookie
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }

    // 不记住我(临时Cookie): GET /RememberMe/doLogin2?name=zhang&pwd=123456
    @RequestMapping("doLogin2")
    public SaResult doLogin2(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001, false);  // false=临时Cookie
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }

    // 七天免登录(自定义有效期): GET /RememberMe/doLogin3?name=zhang&pwd=123456
    @RequestMapping("doLogin3")
    public SaResult doLogin3(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001, 60 * 60 * 24 * 7);  // 7天有效期
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }
}
```

## 场景3：前后端分离(Token返回前端)

```java
@RestController
@RequestMapping("/NotCookie/")
public class NotCookieController {

    // 一体模式: GET /NotCookie/doLogin?name=zhang&pwd=123456
    @RequestMapping("doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            return SaResult.ok();  // Cookie自动注入
        }
        return SaResult.error("登录失败");
    }

    // 分离模式: GET /NotCookie/doLogin2?name=zhang&pwd=123456
    @RequestMapping("doLogin2")
    public SaResult doLogin2(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            SaTokenInfo tokenInfo = StpUtil.getTokenInfo();  // Token返回前端
            return SaResult.data(tokenInfo);
        }
        return SaResult.error("登录失败");
    }
}
```

## 场景4：前端携带Token访问

```js
// uni-app: 登录后存储token
uni.setStorageSync('tokenValue', tokenValue);

// 请求时携带到header
uni.request({
    url: 'https://api.example.com/user/info',
    header: {
        "satoken": uni.getStorageSync('tokenValue')
    },
    success: (res) => { console.log(res.data); }
});

// Vue/Web: 使用localStorage
localStorage.setItem('satoken', tokenValue);
axios.defaults.headers['satoken'] = localStorage.getItem('satoken');
```

## 场景5：StpUtil 完整 API 测试

```java
@RestController
@RequestMapping("/test/")
public class TestController {

    // 登录测试: GET /test/login?userId=10001
    @RequestMapping("login")
    public SaResult login(long userId) {
        // 测试各个登录变体
        StpUtil.login(userId);
        StpUtil.login(userId, "PC");                 // 指定设备
        StpUtil.login(userId, new SaLoginParameter()
            .setDevice("APP")
            .setIsLastingCookie(true)
            .setTimeout(86400));

        StpUtil.getLoginId();                         // 获取当前id
        StpUtil.getTokenValue();                      // 获取token值
        StpUtil.getTokenInfo();                       // 获取token信息
        StpUtil.getTokenTimeout();                    // 剩余有效期

        return SaResult.ok("登录成功");
    }
}
```

---

> 来源:
> - [LoginAuthController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/use/LoginAuthController.java)
> - [RememberMeController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/RememberMeController.java)
> - [NotCookieController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/NotCookieController.java)
