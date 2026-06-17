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

## 四种授权模式

| 模式 | 适用场景 | 说明 |
|------|----------|------|
| **授权码(Authorization Code)** | 有后端的Web应用 | 最常用，安全性最高 |
| **隐式(Implicit)** | 纯前端应用 | 已不推荐使用 |
| **密码(Password)** | 信任的客户端 | 自家APP使用 |
| **客户端凭证(Client Credentials)** | 服务间调用 | 无需用户授权 |

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| Server搭建+DataLoader | references/oauth2-server.md | [oauth2-server](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-server.md)、[oauth2-apidoc](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-apidoc.md) |
| DataLoader+域名校验+自定义 | references/oauth2-data-loader.md | [data-loader](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-data-loader.md)、[check-domain](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-check-domain.md) |
| Scope权限自定义与分级 | references/oauth2-scope.md | [custom-scope](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-custom-scope.md)、[scope-level](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-scope-level.md) |
