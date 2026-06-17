# 二级认证

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/safe-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/safe-auth.md)

## 概念

敏感操作（如修改密码、删除仓库、支付确认等）需要二次验证身份。用户关闭浏览器后二级认证状态失效。

## API

```java
// 开启二级认证(默认120秒)
StpUtil.openSafe("update-password");
StpUtil.openSafe("update-password", 300);              // 指定300秒
StpUtil.openSafe("update-password", 300, "PC");        // 指定设备类型

// 校验
StpUtil.isSafe("update-password");                      // boolean
StpUtil.isSafe(tokenValue, "update-password");          // 指定token
StpUtil.checkSafe("update-password");                   // 失败抛NotSafeException
StpUtil.getSafeTime("update-password");                 // 剩余有效时间(秒)

// 关闭
StpUtil.closeSafe("update-password");

// 注解方式
@SaCheckSafe("update-password")
public SaResult updatePassword() { return SaResult.ok(); }
```
