---
name: sa-token-sso
description: |
  Sa-Token SSO 单点登录专项技能。覆盖三种SSO模式完整方案：模式一(同域+同Redis/Cookie共享)、模式二(跨域+同Redis/URL重定向)、模式三(跨域+跨Redis/Http ticket)。
  SSO-Server认证中心搭建、SSO-Client接入、单点注销、自定义登录页面、前后端分离SSO(H5方案)、消息推送、匿名Client、域名校验、NoSdk非Java接入、自定义API路由、平台中心跳转。
  当用户需要多系统统一登录/注销、搭建单点登录认证中心、跨域SSO集成时使用。
  基础登录认证请先使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token SSO 单点登录

基于 `sa-token-doc/sso/` 全部 18 个文档。基础认证使用 `sa-token` 技能。

## Capability Boundaries

### ✅ Strong Suits
1. **SSO模式一（同域+Cookie）** — 同前端域名+同Redis，共享Cookie同步会话
2. **SSO模式二（跨域+重定向）** — 不同前端域名+同Redis，URL重定向传播会话
3. **SSO模式三（跨域+Http ticket）** — 不同Redis+不同网络，Http请求获取ticket
4. **SSO-Server搭建** — 认证中心统一登录/注销
5. **SSO-Client接入** — 应用系统接入SSO
6. **单点注销** — 一处注销所有系统同时下线
7. **前后端分离SSO** — H5方案适配SPA应用
8. **自定义登录页面** — 定制化Server端登录页
9. **域名校验** — 客户端域名白名单
10. **NoSdk/ReSdk** — 非Java项目SSO接入

### ⚠️ Requirements
1. 模式一和模式二需要所有服务共享同一个Redis
2. SSO-Server和SSO-Client需要网络互通
3. 生产环境建议配置 `secret-key` 加密通信

### ❌ Out of Scope
1. 基础登录/权限/注解鉴权 → **sa-token**
2. OAuth2.0 服务端 → **sa-token-oauth2**
3. 微服务鉴权 → **sa-token-micro**

## 三种模式对比

| 模式 | 场景 | 共享Redis | 认证机制 | 适用 |
|------|:----:|:---------:|----------|------|
| **类型1** | 同域名 | ✅ | Cookie共享 | 同父域下的子系统 |
| **类型2** | 不同域名 | ✅ | URL重定向 | 不同域名但共享Redis |
| **类型3** | 完全隔离 | ❌ | HTTP ticket | 不同Redis、不同网络 |

## 什么时候用哪种模式

- **同父域名下的多个子系统**（如 `admin.example.com`、`shop.example.com`）→ 模式一，最简单
- **不同域名但共享Redis基础设施** → 模式二
- **完全独立的服务，不同Redis、不同网络环境** → 模式三
- **不确定选哪个** → 默认选模式三，灵活性最高

## 工作流

Step 1. **确认环境** — 引入 `sa-token-sso` 依赖，确认Redis连接
Step 2. **选择模式** — 根据系统架构选择模式一/二/三
Step 3. **搭建SSO-Server** — 配置认证中心 `/sso/auth` 等端点
Step 4. **接入SSO-Client** — 各应用系统配置认证地址
Step 5. **配置域名校验** — 设置允许的域名白名单
Step 6. **开启单点注销** — 配置 `is-slo: true`
Step 7. **测试验证** — 验证跨系统登录/注销流程

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| SSO-Server搭建+三种模式 | references/sso-server.md | [sso-server](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-server.md)、[sso-type1](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type1.md)、[sso-type2](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type2.md)、[sso-type3](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type3.md) |
| SSO-Client接入+注销+FAQ | references/sso-client.md | [readme](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/readme.md)、[signout](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/signout.md)、[sso-questions](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-questions.md) |
| 前后端分离SSO(H5) | references/sso-h5.md | [sso-h5](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-h5.md) |

## FAQ

**Q: SSO和OAuth2.0的区别是什么？**
A: SSO解决多系统统一登录问题（一个账号登录所有系统）。OAuth2.0解决第三方授权问题（允许第三方应用访问用户数据）。简单场景选SSO，开放平台场景选OAuth2.0。

**Q: 三种SSO模式如何选择？**
A: 同域名用模式一（最简单），跨域但共享Redis用模式二，完全隔离的环境用模式三。不确定时选模式三。

**Q: SSO-Server和SSO-Client必须用同一语言吗？**
A: 模式一和模式二需要（依赖共享Redis的Java SDK），模式三不限语言（通过HTTP交互）。

**Q: 如何保证ticket的安全性？**
A: 1) 配置 `secret-key` 加密通信；2) ticket有效期默认5分钟，较短；3) 配置 `is-check-sign: true` 校验签名。

**Q: SSO支持前后端分离项目吗？**
A: 支持。有专门的H5方案，前端SPA应用通过URL参数传递ticket，后端提供接口换取登录态。

**Q: 单点注销是怎么工作的？**
A: 用户在SSO-Server注销时，Server会向所有已注册的Client发送注销通知，各Client清除本地会话。

## Gotchas

1. **模式三需要配置 ticket-url** — 不能遗漏 `ticket-url` 配置，否则Client无法向Server校验ticket
2. **secret-key 生产环境必须配置** — 调试时可设 `is-check-sign: false`，生产务必开启
3. **域名校验白名单** — 未配置 `allow-domains` 时所有域名均可接入，生产环境需限制
4. **单点注销需双向配置** — Server端 `is-slo: true` + Client端 `reg-logout-call: true`
5. **前后端分离下URL中ticket参数需要前端主动处理** — 后端不会自动重定向
6. **模式一依赖Cookie同域** — 子域名必须在同一父域名下（如 `.example.com`）
7. **Same-Token与SSO不要混淆** — Same-Token用于微服务内部鉴权，SSO用于用户登录态共享

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
