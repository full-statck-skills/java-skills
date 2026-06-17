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

## 三种模式对比

| 模式 | 场景 | 共享Redis | 认证机制 | 适用 |
|------|:----:|:---------:|----------|------|
| **类型1** | 同域名 | ✅ | Cookie共享 | 同父域下的子系统 |
| **类型2** | 不同域名 | ✅ | URL重定向 | 不同域名但共享Redis |
| **类型3** | 完全隔离 | ❌ | HTTP ticket | 不同Redis、不同网络 |

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| SSO-Server搭建+三种模式 | references/sso-server.md | [sso-server](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-server.md)、[sso-type1](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type1.md)、[sso-type2](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type2.md)、[sso-type3](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-type3.md) |
| SSO-Client接入+注销+FAQ | references/sso-client.md | [readme](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/readme.md)、[signout](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/signout.md)、[sso-questions](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-questions.md) |
| 前后端分离SSO(H5) | references/sso-h5.md | [sso-h5](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-h5.md) |
