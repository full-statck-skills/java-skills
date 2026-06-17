# 多账号认证

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/many-account.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/many-account.md)

## 概念

同一项目存在多套账号体系，如 User(普通用户) + Admin(管理员)。

## 方式1：StpUserUtil（内置）

```java
// Admin体系(默认)
StpUtil.login(10001);
StpUtil.checkLogin();

// User体系(内置)
StpUserUtil.login(10001);
StpUserUtil.checkLogin();
StpUserUtil.getPermissionList();
```

## 方式2：StpKit 门面模式（推荐）

```java
public class StpKit {
    public static final StpUtilStpUtil user = new StpUtilStpUtil("user");
    public static final StpUtilStpUtil admin = new StpUtilStpUtil("admin");
}

StpKit.user.login(10001);
StpKit.user.checkPermission("user.add");
StpKit.admin.login(10001);
StpKit.admin.checkPermission("admin.add");
```

## 注解type属性

```java
@SaCheckLogin(type = "user")
@SaCheckPermission(value = "user.add", type = "admin")
```

## 拦截器

```java
SaRouter.match("/user/**").check(r -> StpKit.user.checkLogin());
SaRouter.match("/admin/**").check(r -> StpKit.admin.checkLogin());
```

## 不同配置

```java
SaTokenConfig userConfig = new SaTokenConfig();
userConfig.setTokenName("usertoken");
userConfig.setTimeout(60 * 60 * 24);
StpKit.user.setConfig(userConfig);
```
