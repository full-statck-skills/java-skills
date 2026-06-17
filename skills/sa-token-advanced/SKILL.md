---
name: sa-token-advanced
description: |
  Sa-Token 高级安全特性技能。覆盖二级认证(safe-auth二次验证)、账号封禁(全封禁/分类封禁/阶梯封禁)、模拟他人与身份切换、多账号认证(StpUserUtil/StpKit)、全局侦听器(登录/注销/踢人/封禁/续签事件)、全局过滤器(SaServletFilter/SaReactorFilter)、密码加密(MD5/SHA1/SHA256/AES/RSA/BCrypt/TOTP)、会话查询(终端列表/全局搜索Token)、Http Basic/Digest认证、防火墙(IP黑白名单/频率限制)、自定义鉴权注解、路由鉴权动态化、反向代理URI修复、异步Mock上下文、数据架构Redis键值设计。
  当用户需要实现敏感操作二次验证、账号分级封禁、模拟用户操作、多套账号体系(User/Admin分离)、全局事件监听、密码加密工具时使用。
  基础登录认证请使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token 高级安全特性

基于 `sa-token-doc/up/`深入 + `fun/`高级 + `arch/`架构文档。

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| 二级认证(safe-auth) | references/safe-auth.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/safe-auth.md) |
| 账号封禁(分类+阶梯) | references/disable.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/disable.md) |
| 身份切换(mock-person) | references/mock-person.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mock-person.md) |
| 多账号认证 | references/many-account.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/many-account.md) |
| 密码加密+HttpBasic | references/password-basic.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/password-secure.md) |
| 全局侦听器+全局过滤器 | references/listener-filter.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/global-listener.md) |

## 核心 API 速查

```java
// 二级认证
StpUtil.openSafe("update-password");         // 开启(默认120秒)
StpUtil.checkSafe("update-password");         // 校验
@SaCheckSafe("update-password")               // 注解

// 账号封禁
StpUtil.disable(10001, "comment", 200);       // 分类封禁
StpUtil.disableLevel(10001, "comment", 2, 200); // 阶梯封禁
StpUtil.untieDisable(10001, "comment");       // 解封

// 身份切换
StpUtil.switchTo(10001, () -> { ... });      // Lambda作用域切换

// 多账号
StpUserUtil.login(10001);                     // User体系
StpKit.admin.login(10001);                    // StpKit门面

// 密码加密
SaSecureUtil.md5("123456");
SaSecureUtil.aesEncrypt(key, "data");
SaTotpUtil.generateCode("secret");

// 全局侦听器
SaTokenEventCenter.registerListener(listener);
```

## Gotchas
1. StpInterface 可实现 `isDisabled()` 自定义封禁逻辑
2. 多账号体系可在注解中通过 `type` 属性指定
3. 全局侦听器建议使用 `SaTokenListenerForSimple` 简化实现
