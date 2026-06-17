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

## 适用场景

当用户需要以下场景时，激活此技能：
- **敏感操作二次验证** — 删除仓库/修改密码等操作需要再次确认身份
- **账号违规处罚** — 按服务维度封禁（只禁言不禁购）、按违规等级处罚
- **后台模拟用户** — 客服人员需要临时以用户身份操作
- **多套账号体系** — 系统中同时存在User和Admin两套独立的账号表
- **全局事件记录** — 记录所有用户的登录/注销/踢人/封禁等操作日志
- **密码加密存储** — 用户密码的安全存储与验证

## Workflow

Step 1. **确定需求** — 选择二级认证/封禁/多账号/侦听器等具体功能
Step 2. **编写代码** — 根据API文档实现对应功能
Step 3. **配置注册** — 注册侦听器、配置过滤器、定义多账号体系
Step 4. **测试验证** — 验证功能行为符合预期

## Capability Boundaries

### ✅ Strong Suits
1. **二级认证** — `openSafe()`/`checkSafe()`/@`SaCheckSafe` 敏感操作二次验证
2. **账号封禁** — 全封禁/分类封禁(comment/order/shop)/阶梯封禁(level)
3. **身份切换** — `switchTo()`/`endSwitch()` 模拟其他账号
4. **多账号认证** — StpUserUtil模式 + StpKit门面模式，多套账号体系
5. **全局侦听器** — SaTokenListener接口(登录/注销/踢人/封禁等10+事件)
6. **全局过滤器** — SaServletFilter + SaReactorFilter，统一安全头设置
7. **密码加密** — 5种算法：MD5/SHA/AES/RSA/BCrypt + TOTP验证码
8. **会话查询** — SaTerminalInfo终端列表 + searchTokenValue/TokenSession/Session
9. **Http Basic/Digest** — @SaCheckHttpBasic / @SaCheckHttpDigest
10. **防火墙** — IP黑白名单 + 请求频率限制
11. **自定义注解** — 组合注解/自定义鉴权注解

### ⚠️ Requirements
1. 所有功能都基于 `sa-token-core`，部分功能需要登录后才能使用
2. 全局侦听器需要注册到Spring容器（@Component或手动注册）
3. 多账号认证需要自行定义账号体系名称

### ❌ Out of Scope
1. 基础登录/权限/注解鉴权 → **sa-token**
2. SSO单点登录 → **sa-token-sso**
3. OAuth2.0 服务端 → **sa-token-oauth2**
4. 微服务鉴权 → **sa-token-micro**

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
// === 二级认证 ===
StpUtil.openSafe("update-password");         // 开启(默认120秒)
StpUtil.checkSafe("update-password");         // 校验
@SaCheckSafe("update-password")               // 注解

// === 账号封禁 ===
StpUtil.disable(10001, "comment", 200);       // 分类封禁
StpUtil.disableLevel(10001, "comment", 2, 200); // 阶梯封禁
StpUtil.untieDisable(10001, "comment");       // 解封
@SaCheckDisable("comment")                     // 注解

// === 身份切换 ===
StpUtil.switchTo(10001);                       // 切换到其他账号
StpUtil.switchTo(10001, () -> { ... });        // Lambda作用域切换

// === 多账号 ===
StpUserUtil.login(10001);                     // User体系
StpKit.admin.login(10001);                    // StpKit门面

// === 密码加密 ===
SaSecureUtil.md5("123456");
SaSecureUtil.aesEncrypt(key, "data");
SaSecureUtil.rsaEncryptByPublic(publicKey, text);
SaTotpUtil.generateCode("secret");
SaSecureUtil.bCryptPasswordEncoder("123456");

// === 全局侦听器 ===
SaTokenEventCenter.registerListener(listener);
@Component class MyListener extends SaTokenListenerForSimple { ... }

// === 会话查询 ===
StpUtil.searchTokenValue(keyword, start, size, sort);
StpUtil.searchSessionId(keyword, start, size, sort);
```

## FAQ

**Q: 二级认证和普通登录有什么区别？**
A: 普通登录是第一次身份验证。二级认证是在已经登录的基础上，对敏感操作进行第二次验证（如修改密码、删除仓库）。两者独立。

**Q: 账号封禁的三种级别怎么用？**
A: 简单违规用全封禁。按服务维度违规用分类封禁（如只禁言不禁购）。需要梯度处罚用阶梯封禁（如首次违规level1，多次违规level3）。

**Q: StpUserUtil和StpKit有什么区别？**
A: StpUserUtil是内置的User账号体系。StpKit门面模式可以自定义任意多的账号体系（如User、Admin、Teacher），更加灵活。

**Q: 全局侦听器能监听到哪些事件？**
A: 登录、注销、踢下线、顶下线、封禁、解封、二级认证开启/关闭、Session创建/销毁、Token续期，共11种事件。

**Q: SaServletFilter和SaInterceptor怎么选？**
A: 需要过滤静态资源或设置安全响应头选SaServletFilter。只需要Controller层鉴权选SaInterceptor。两者可以同时使用。

**Q: 如何自定义鉴权注解？**
A: 实现 `SaAnnotationStrategy` 的自定义注解处理器，可以参考官方demo中的 `custom_annotation` 包。

## Gotchas
1. **StpInterface可实现 `isDisabled()` 自定义封禁逻辑** — 默认封禁在内存中，重启丢失
2. **多账号体系可在注解中通过 `type` 属性指定** — 如 `@SaCheckLogin(type = "user")`
3. **全局侦听器建议使用 `SaTokenListenerForSimple` 简化实现** — 只重写需要的方法
4. **二级认证默认有效期120秒** — 可根据业务调整
5. **阶梯封禁的level值越大代表封禁越严重** — `checkDisableLevel(3)` 表示level≥3才阻止
6. **switchTo的Lambda方式比手动endSwitch更安全** — 不会忘记恢复身份
7. **全局过滤器设置安全响应头时要注意浏览器兼容性**
8. **Http Basic认证的账号密码在网络传输中是明文** — 需配合HTTPS使用

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
