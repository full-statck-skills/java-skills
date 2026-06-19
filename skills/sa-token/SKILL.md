---
name: sa-token
description: |
  Sa-Token 轻量级 Java 权限认证框架核心技能。覆盖登录认证、权限/角色认证、注解鉴权、路由拦截鉴权、Session 会话、踢人下线、Token 有效期策略、框架配置、Token 风格与提交前缀、前后端分离、记住我模式、同端互斥登录、NotLoginException 场景值处理。
  StpUtil 是核心门面工具类，提供 login/checkLogin/logout/isLogin/getLoginId/getTokenValue 等全套鉴权 API。
  当用户需要 Java Web 项目集成权限认证、使用 StpUtil 进行登录/权限校验、配置路由拦截器或注解鉴权时使用。
  不涉及二级认证/封禁/多账号/SSO/OAuth2/微服务/API安全/JWT/Redis 等高级功能，请使用对应专项技能。
license: Apache-2.0
---

# Sa-Token 核心权限认证框架

> 基于 Sa-Token v1.45.0 | 官方文档：https://sa-token.cc | GitHub：https://github.com/dromara/sa-token

Sa-Token 是一个轻量级 Java 权限认证框架，核心包零依赖，提供了完整的鉴权体系。`StpUtil` 是其核心门面工具类。

## Capability Boundaries

### ✅ Strong Suits
1. **登录认证** — `StpUtil.login()` 会话登录、记住我模式、指定设备类型、登录扩展参数
2. **会话校验** — `StpUtil.isLogin()`/`checkLogin()`/`getLoginId()` 全套查询 API
3. **Token 管理** — 获取 token 值/名称/信息、根据 token 反查账号、token 有效期双策略（timeout + active-timeout）
4. **权限/角色认证** — 实现 StpInterface 定义权限加载器、checkPermission/checkRole 系列 API、权限通配符 `*`
5. **注解鉴权** — `@SaCheckLogin`、`@SaCheckPermission`、`@SaCheckRole`、`@SaIgnore`、`@SaCheckOr`
6. **路由拦截鉴权** — SaInterceptor + SaRouter 匹配链、stop/back/free 退出机制、多条件匹配
7. **Session 会话** — Account-Session / Token-Session / Custom-Session 三种模型
8. **踢人下线** — 强制注销、踢下线、顶下线三种操作
9. **框架配置** — application.yml 全配置项、代码配置方式
10. **前后端分离** — Cookie 模式 vs Header 模式，小程序/APP 无 Cookie 适配
11. **Token 自定义** — 6 种内置风格、自定义生成策略、Bearer 提交前缀
12. **同端互斥登录** — 同一设备类型仅允许一个在线

### ❌ Out of Scope（替代方案）
1. 二级认证/账号封禁/模拟他人/多账号 → **sa-token-advanced**
2. SSO 单点登录 → **sa-token-sso**
3. OAuth2.0 服务端 → **sa-token-oauth2**
4. 微服务 Same-Token/网关鉴权 → **sa-token-micro**
5. API 签名/API Key/临时 Token → **sa-token-api-security**
6. JWT 集成/Redis 持久化/模板引擎 → **sa-token-integration**

## 适用场景

当用户需要以下场景时，激活此技能：
- **新项目集成权限认证** — SpringBoot项目引入Sa-Token，配置StpInterface，实现登录/权限校验
- **现有项目添加鉴权** — 为已有接口添加登录校验/权限校验/角色校验
- **配置路由拦截器** — 统一拦截所有请求，按模块划分不同鉴权规则
- **使用注解鉴权** — 使用@SaCheckLogin/@SaCheckPermission等注解
- **前后端分离适配** — 无Cookie环境下Token的传递与校验
- **调试与排错** — 排查NotLoginException各类场景值、Token有效期问题

## Workflow

Step 1. **引入依赖** — 添加 `sa-token-spring-boot-starter` 依赖（根据SpringBoot版本选择）
Step 2. **配置框架** — application.yml 配置 token 名称、有效期、风格等
Step 3. **实现 StpInterface** — 自定义权限加载器，返回权限码和角色集合
Step 4. **登录认证** — 调用 `StpUtil.login(id)` 完成会话登录
Step 5. **权限校验** — 使用 StpUtil 方法或注解进行权限/角色校验
Step 6. **路由拦截** — SaInterceptor + SaRouter 实现全局路由鉴权
Step 7. **集成测试** — 验证登录/注销/权限校验/注解鉴权全流程

## StpUtil 核心 API 速查

```java
// === 登录认证 ===
StpUtil.login(Object loginId);                          // 会话登录
StpUtil.login(10001, "PC");                             // 指定设备类型
StpUtil.login(10001, true);                             // 指定记住我
StpUtil.login(10001, new SaLoginParameter()...);        // 完整参数模式
StpUtil.logout();                                       // 当前会话注销
StpUtil.logout(10001);                                  // 指定账号注销
	StpUtil.logoutByTokenValue(token);                      // 指定Token注销
	StpUtil.logoutByLoginId(10001, "PC");                   // 指定账号+设备注销
	StpUtil.kickout(10001);                                 // 踢人下线
	StpUtil.kickoutByTokenValue(token);                     // 根据Token值踢人
StpUtil.isLogin();                                      // 是否登录(true/false)
StpUtil.checkLogin();                                   // 校验登录(未登录抛NotLoginException)

	// === 会话/Token查询 ===
	StpUtil.getLoginId();                                   // 当前账号id
	StpUtil.getLoginIdAsString()/AsInt()/AsLong();          // 类型化获取
	StpUtil.getLoginIdDefaultNull();                        // 未登录返回null
	StpUtil.getLoginIdByToken(token);                       // 根据token查账号
	StpUtil.getTokenValue();                                // 当前token值
	StpUtil.getTokenValueByLoginId(10001);                  // 获取指定账号的token值
	StpUtil.getTokenListByLoginId(10001);                   // 获取指定账号所有token列表
	StpUtil.getTokenName();                                 // token名称(satoken)
	StpUtil.getTokenTimeout();                              // 剩余有效期(秒)
	StpUtil.getTokenInfo();                                 // 完整TokenInfo
	StpUtil.setTokenValue("xxx-xxx");                       // 手动设置当前会话token值
	StpUtil.renewRefresh();                                // 自动续签token有效期
	StpUtil.getTerminalListByLoginId(10001);                // 获取指定账号所有终端列表

	// === 权限/角色校验 ===
	StpUtil.getPermissionList();                            // 权限码集合
	StpUtil.hasPermission("user.add");                     // boolean
	StpUtil.checkPermission("user.add");                   // 失败抛NotPermissionException
	StpUtil.checkPermissionAnd("add","del","get");          // 全部拥有
	StpUtil.checkPermissionOr("add","del","get");          // 至少一个
	StpUtil.hasRole("admin");                               // boolean
	StpUtil.checkRole("admin");                             // 失败抛NotRoleException
	
	// === Session会话 ===
	StpUtil.getSession();                                   // 当前账号Account-Session
	StpUtil.getSessionByLoginId(10001);                     // 指定账号的Session
	StpUtil.getTokenSession();                              // 当前Token-Session
	StpUtil.getTokenSessionByTokenValue("xxx-xxx");        // 按token值获取Token-Session
	SaSessionCustomUtil.getSessionById("goods-10001");     // Custom-Session
```

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| 登录认证完整指南 | references/login-auth.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/login-auth.md) |
| 权限/角色认证 | references/jur-auth.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/jur-auth.md) |
| 注解鉴权 | references/at-check.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/at-check.md) |
| 路由拦截鉴权 | references/route-check.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/route-check.md) |
| Session 会话 | references/session.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/session.md) |
| 框架配置 | references/config.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/config.md) |
| 踢人下线 | references/kickout.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/kick.md) |
| Token 有效期 | references/token-timeout.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/token-timeout.md) |
| NotLoginException | references/not-login-scene.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/not-login-scene.md) |
| 前后端分离 & 记住我 | references/not-cookie.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/not-cookie.md)、[remember-me](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/remember-me.md) |
| Token 风格 & 前缀 | references/token-style.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-style.md)、[token-prefix](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-prefix.md) |
| 登录参数详解 | references/login-parameter.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/login-parameter.md) |
| 同端互斥登录 | references/mutex-login.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mutex-login.md) |
| 快速入门 | examples/quickstart.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/start/example.md) |

## Gotchas

1. **StpInterface 不会在启动时执行** — 只在调用鉴权方法时触发查询
2. **注解鉴权默认关闭** — 必须手动注册 `SaInterceptor`
3. **SaSession ≠ HttpSession** — 两者无任何关系，不要混淆使用
4. **前端鉴权只是辅助** — 不能替代后端校验
5. **`@SaIgnore` 只对 SaInterceptor 和 AOP 生效** — 自定义拦截器不受影响
6. **`@SaCheckPermission` 默认 AND 模式** — OR 模式需指定 `mode = SaMode.OR`
7. **`StpUtil.logout()` 注销范围可通过 `logout-range` 配置** — 默认只注销当前 token
8. **Cookie 模式默认注入 Cookie** — 关闭可用 `is-read-cookie: false`

## Data Privacy
本技能不收集、存储或传输任何用户数据。
