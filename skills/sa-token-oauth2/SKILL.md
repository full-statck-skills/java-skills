---
name: sa-token-oauth2
description: |
  Sa-Token OAuth2.0 服务端技能。覆盖四种授权模式：授权码模式(Authorization Code)、隐式模式(Implicit)、密码模式(Password)、客户端凭证模式(Client Credentials)。
  完整 OAuth2-Server 搭建、SaOAuth2DataLoader 数据加载器、Scope 权限自定义与分级、OIDC 协议、OpenId/UnionId、自定义 grant_type、自定义登录授权页、注解校验 Access-Token、与登录会话互通、Scope level 等级控制、自定义API路由。
  当用户需要搭建OAuth2.0认证服务器、开发开放平台、实现第三方应用授权时使用。
  基础登录认证请先使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token OAuth2.0 服务端

基于 `sa-token-doc/oauth2/` 全部 17 个文档。基础认证使用 `sa-token` 技能。

## Capability Boundaries

### ✅ Strong Suits
1. **授权码模式(Authorization Code)** — 有后端的Web应用，最常用，安全性最高
2. **隐式模式(Implicit)** — 纯前端应用
3. **密码模式(Password)** — 信任的客户端（自家APP）
4. **客户端凭证模式(Client Credentials)** — 服务间调用，无需用户授权
5. **Scope权限控制** — 自定义Scope+Scope等级划分
6. **OIDC协议** — OpenID Connect身份层
7. **OpenId/UnionId** — 用户唯一标识生成与管理
8. **自定义grant_type** — 扩展授权类型
9. **自定义登录/授权页** — 定制化前端界面
10. **注解校验Access-Token** — @SaCheckAccessToken、@SaCheckClientToken

### ⚠️ Requirements
1. 需要JDK 8+环境
2. OAuth2-Server需要可被Client访问的网络
3. 需实现 SaOAuth2DataLoader 接口提供数据

### ❌ Out of Scope
1. 基础登录/权限认证 → **sa-token**
2. SSO单点登录 → **sa-token-sso**
3. 微服务鉴权 → **sa-token-micro**

## 四种授权模式

| 模式 | 适用场景 | 说明 |
|------|----------|------|
| **授权码(Authorization Code)** | 有后端的Web应用 | 最常用，安全性最高 |
| **隐式(Implicit)** | 纯前端应用 | 已不推荐使用 |
| **密码(Password)** | 信任的客户端 | 自家APP使用 |
| **客户端凭证(Client Credentials)** | 服务间调用 | 无需用户授权 |

## 什么时候用哪种模式

- **开发开放平台，给第三方开发者使用** → 授权码模式，标准OAuth2流程
- **自己的前后端分离应用** → 密码模式，简单直接
- **微服务之间调用API** → 客户端凭证模式，无需用户参与
- **纯前端无后端应用（已不推荐）** → 隐式模式

## 工作流

Step 1. **引入依赖** — 添加 `sa-token-oauth2` 依赖
Step 2. **实现DataLoader** — `SaOAuth2DataLoaderImpl` 加载客户端和Scope数据
Step 3. **配置Server端点** — 注册 authorize/token/validate/refresh 接口
Step 4. **配置OAuth2参数** — 设置Token有效期、授权模式等
Step 5. **测试授权流程** — 使用授权码模式验证端到端流程
Step 6. **上线前安全加固** — 开启域名校验、配置回调白名单

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| Server搭建+DataLoader | references/oauth2-server.md | [oauth2-server](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-server.md)、[oauth2-apidoc](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-apidoc.md) |
| DataLoader+域名校验+自定义 | references/oauth2-data-loader.md | [data-loader](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-data-loader.md)、[check-domain](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-check-domain.md) |
| Scope权限自定义与分级 | references/oauth2-scope.md | [custom-scope](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-custom-scope.md)、[scope-level](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-scope-level.md) |

## FAQ

**Q: OAuth2和SSO有什么区别？**
A: OAuth2解决授权问题（第三方应用访问用户数据），SSO解决认证问题（统一登录）。需要第三方授权选OAuth2，仅需统一登录选SSO。也可两者结合使用。

**Q: 四种授权模式选哪种？**
A: 有后端的Web应用选授权码模式（最安全）。自家APP选密码模式。服务间调用选客户端凭证模式。隐式模式已不推荐。

**Q: 如何自定义Scope？**
A: 实现 `SaOAuth2DataLoader.getScope()` 方法，返回 `SaScopeObject` 对象，可设置scope名称、描述、是否默认选中。

**Q: 如何保证OAuth2服务安全？**
A: 1) 配置 `is-check-domain: true` 校验回调域名；2) 配置 `allow-url` 白名单；3) 生产环境关闭 `isAutoMode`；4) 使用HTTPS。

**Q: 支持刷新Token吗？**
A: 支持。`refresh-token-timeout` 默认30天，调用 `/oauth2/refresh` 接口刷新。

**Q: 前后端分离怎么对接OAuth2？**
A: 前端通过URL参数接收code，调用后端 `/oauth2/token` 接口换取AccessToken，保存到本地存储。

## Gotchas

1. **必须实现 SaOAuth2DataLoader** — Server启动后不会自动加载数据，需要自行实现接口
2. **allow-url 必须配置** — 不配置回调URL白名单会导致授权失败
3. **生产环境关闭 isAutoMode** — 自动确认授权模式仅用于开发调试
4. **AccessToken有效期默认2小时** — 可通过 `access-token-timeout` 配置
5. **Scope需要在 DataLoader 和 ClientModel 两端配置** — 只配一端不会生效
6. **隐式模式不推荐生产使用** — AccessToken直接暴露在URL中，有安全风险
7. **OIDC需要额外配置 iss 和 idTokenTimeout** — 不是默认开启就能用
8. **域名校验不通过会返回错误** — 配置 `allow-domains` 时要包含所有合法客户端

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
