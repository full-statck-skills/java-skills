---
name: sa-token-micro
description: |
  Sa-Token 微服务鉴权技能。覆盖 Same-Token 内部服务外网隔离机制、SpringCloud Gateway 网关统一鉴权(Reactor响应式)、Feign/Dubbo/gRPC 内部RPC调用鉴权、分布式Session会话方案(Redis Session中心/JWT无状态)、Reactor/WebFlux框架集成、SpringBoot3/4依赖适配。
  当用户需要微服务架构下的服务间认证、网关Token转发与校验、内部服务外网隔离、分布式会话共享时使用。
  基础登录认证请先使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token 微服务鉴权

基于 `sa-token-doc/micro/` 全部 4 个文档。基础认证使用 `sa-token` 技能。

## 架构

```
客户端 → Gateway(校验登录+注入Same-Token) → 子服务(校验Same-Token)
                                                 ↕ Feign(携带Same-Token)
                                              其他子服务(校验Same-Token)
```

## 参考文档

| 文件 | 说明 | 来源 |
|------|------|------|
| [gateway-auth.md](references/gateway-auth.md) | 网关统一鉴权+分布式Session | [gateway-auth](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/gateway-auth.md)、[dcs-session](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/dcs-session.md) |
| [same-token.md](references/same-token.md) | Same-Token隔离+依赖引入 | [same-token](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/same-token.md)(277行)、[import-intro](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/import-intro.md) |
