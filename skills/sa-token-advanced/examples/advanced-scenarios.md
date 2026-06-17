# 二级认证 + 账号封禁 + 密码加密 + 侦听器 综合示例

> 来源: 官方 demo `SafeAuthController` + `DisableController` + `SwitchToController` + `SecureController` + `HttpBasicController` + `MySaTokenListener`

## 1. 二级认证(删除仓库+获取秘钥)

```java
@RestController
@RequestMapping("/safe/")
public class SafeAuthController {

    // 1) 尝试删除仓库(需二级认证): GET /safe/deleteProject
    @RequestMapping("deleteProject")
    public SaResult deleteProject(String projectId) {
        if(!StpUtil.isSafe()) {
            return SaResult.error("仓库删除失败，请完成二级认证后再次访问");
        }
        // 通过二级认证，执行业务逻辑
        return SaResult.ok("仓库删除成功");
    }

    // 2) 密码验证开启二级认证: GET /safe/openSafe?password=123456
    @RequestMapping("openSafe")
    public SaResult openSafe(String password) {
        if("123456".equals(password)) {
            StpUtil.openSafe(120);   // 120秒有效
            return SaResult.ok("二级认证成功");
        }
        return SaResult.error("二级认证失败");
    }

    // 3) 获取应用秘钥(指定业务类型): GET /safe/getClientSecret
    @RequestMapping("getClientSecret")
    public SaResult getClientSecret() {
        StpUtil.checkSafe("client");   // 检查client业务的二级认证
        return SaResult.data("aaaa-bbbb-cccc-dddd-eeee");
    }

    // 4) 手势密码开启client二级认证: GET /safe/openClientSafe?gesture=35789
    @RequestMapping("openClientSafe")
    public SaResult openClientSafe(String gesture) {
        if("35789".equals(gesture)) {
            StpUtil.openSafe("client", 600);  // 10分钟有效
            return SaResult.ok("二级认证成功");
        }
        return SaResult.error("二级认证失败");
    }

    // 5) 查询二级认证状态: GET /safe/isClientSafe
    @RequestMapping("isClientSafe")
    public SaResult isClientSafe() {
        return SaResult.ok("是否已完成client二级认证：" + StpUtil.isSafe("client"));
    }

    // 6) 手动关闭二级认证: GET /safe/closeSafe
    @RequestMapping("closeSafe")
    public SaResult closeSafe() {
        StpUtil.closeSafe();
        return SaResult.ok();
    }
}
```

## 2. 账号封禁(登录前封禁检查)

```java
@RestController
@RequestMapping("/disable/")
public class DisableController {

    // 登录(先检查封禁): GET /disable/login?userId=10001
    @RequestMapping("login")
    public SaResult login(long userId) {
        StpUtil.checkDisable(userId);    // 检查是否被封禁
        StpUtil.login(userId);           // 检查通过后登录
        return SaResult.ok("账号登录成功");
    }

    // 封禁: GET /disable/disable?userId=10001
    @RequestMapping("disable")
    public SaResult disable(long userId) {
        StpUtil.disable(userId, 86400);  // 封禁1天
        return SaResult.ok("账号 " + userId + " 封禁成功");
    }

    // 解封: GET /disable/untieDisable?userId=10001
    @RequestMapping("untieDisable")
    public SaResult untieDisable(long userId) {
        StpUtil.untieDisable(userId);
        return SaResult.ok("账号 " + userId + " 解封成功");
    }

    // 注销: GET /disable/logout
    @RequestMapping("logout")
    public SaResult logout() {
        StpUtil.logout();
        return SaResult.ok("账号退出成功");
    }
}
```

## 3. 身份切换(模拟他人)

```java
@RestController
@RequestMapping("/SwitchTo/")
public class SwitchToController {

    // 方式1-直接切换: GET /SwitchTo/switchTo?userId=10044
    @RequestMapping("switchTo")
    public SaResult switchTo(long userId) {
        StpUtil.switchTo(userId);
        System.out.println("临时切换到: " + StpUtil.getLoginId());  // 10044
        StpUtil.endSwitch();
        System.out.println("切换结束: " + StpUtil.getLoginId());   // 原账号
        return SaResult.ok();
    }

    // 方式2-Lambda切换(推荐): GET /SwitchTo/switchTo2?userId=10044
    @RequestMapping("switchTo2")
    public SaResult switchTo2(long userId) {
        System.out.println("切换前: " + StpUtil.getLoginId());
        StpUtil.switchTo(userId, () -> {
            System.out.println("是否在切换中: " + StpUtil.isSwitch()); // true
            System.out.println("当前身份: " + StpUtil.getLoginId());   // 10044
        });
        System.out.println("切换后: " + StpUtil.getLoginId());       // 原账号
        return SaResult.ok();
    }
}
```

## 4. 密码加密工具

```java
@RestController
@RequestMapping("/secure/")
public class SecureController {

    // 摘要加密: GET /secure/digest
    @RequestMapping("digest")
    public SaResult digest() {
        System.out.println("MD5:   " + SaSecureUtil.md5("123456"));
        System.out.println("SHA1:  " + SaSecureUtil.sha1("123456"));
        System.out.println("SHA256:" + SaSecureUtil.sha256("123456"));
        return SaResult.ok();
    }

    // AES加解密: GET /secure/aes
    @RequestMapping("aes")
    public SaResult aes() {
        String key = "123456";
        String text = "Sa-Token 一个轻量级java权限认证框架";
        String ciphertext = SaSecureUtil.aesEncrypt(key, text);
        System.out.println("AES加密: " + ciphertext);
        String plaintext = SaSecureUtil.aesDecrypt(key, ciphertext);
        System.out.println("AES解密: " + plaintext);
        return SaResult.ok();
    }

    // Base64编解码: GET /secure/base64
    @RequestMapping("base64")
    public SaResult base64() {
        String text = "Sa-Token 一个轻量级java权限认证框架";
        String encoded = SaBase64Util.encode(text);
        String decoded = SaBase64Util.decode(encoded);
        System.out.println("Base64编码: " + encoded);
        System.out.println("Base64解码: " + decoded);
        return SaResult.ok();
    }
}
```

## 5. Http Basic 认证

```java
@RestController
@RequestMapping("/basic/")
public class HttpBasicController {

    // 资源接口(需HttpBasic校验): GET /basic/getInfo
    // 浏览器会弹出账号密码输入框
    @RequestMapping("getInfo")
    public SaResult login() {
        SaHttpBasicUtil.check("sa:123456");   // 校验账号密码
        String data = "这是通过 Http Basic 校验后才返回的数据";
        return SaResult.data(data);
    }
}
```

## 6. 同端互斥登录

```java
@RestController
@RequestMapping("/mutex/")
public class MutexLoginController {

    // 按设备类型登录: GET /mutex/doLogin?userId=10001&device=PC
    @RequestMapping("doLogin")
    public SaResult doLogin(long userId, String device) {
        StpUtil.login(userId, device);    // 同设备类型互斥
        return SaResult.ok("登录成功");
    }

    // 查询状态: GET /mutex/isLogin
    @RequestMapping("isLogin")
    public SaResult isLogin() {
        boolean isLogin = StpUtil.isLogin();
        String device = StpUtil.getLoginDeviceType();
        return SaResult.ok("是否登录:" + isLogin + ", 设备:" + device);
    }
}
```

## 7. 全局侦听器

```java
@Component  // 注册侦听器
public class MySaTokenListener implements SaTokenListener {

    @Override public void doLogin(String loginType, Object loginId, String tokenValue,
                                  SaLoginParameter loginParameter) {
        System.out.println("用户登录: " + loginId);
    }

    @Override public void doLogout(String loginType, Object loginId, String tokenValue) {
        System.out.println("用户注销: " + loginId);
    }

    @Override public void doKickout(String loginType, Object loginId, String tokenValue) {
        System.out.println("用户被踢下线: " + loginId);
    }

    @Override public void doReplaced(String loginType, Object loginId, String tokenValue) {
        System.out.println("用户被顶下线: " + loginId);
    }

    @Override public void doDisable(String loginType, Object loginId, String service,
                                    int level, long disableTime) {
        System.out.println("账号被封禁: " + loginId + ", 服务: " + service);
    }

    @Override public void doUntieDisable(String loginType, Object loginId, String service) {
        System.out.println("账号解封: " + loginId);
    }

    @Override public void doOpenSafe(String loginType, String tokenValue,
                                     String service, long safeTime) {
        System.out.println("二级认证开启: " + service);
    }

    @Override public void doCloseSafe(String loginType, String tokenValue, String service) {
        System.out.println("二级认证关闭: " + service);
    }

    @Override public void doCreateSession(String id) { /* Session创建 */ }
    @Override public void doLogoutSession(String id) { /* Session销毁 */ }
    @Override public void doRenewTimeout(String loginType, Object loginId,
                                         String tokenValue, long timeout) {
        System.out.println("Token续期: " + loginId);
    }
}
```

---

> 来源:
> - [SafeAuthController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/SafeAuthController.java)
> - [DisableController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/DisableController.java)
> - [SwitchToController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/SwitchToController.java)
> - [SecureController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/up/SecureController.java)
> - [MySaTokenListener.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/satoken/MySaTokenListener.java)
