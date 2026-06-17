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

## Capability Boundaries

### ✅ Strong Suits
1. **Same-Token机制** — 内部服务外网隔离，防止绕过网关直接访问子服务
2. **网关统一鉴权** — SpringCloud Gateway集中式登录+权限校验
3. **Reactor/WebFlux集成** — 响应式框架适配（SaReactorFilter）
4. **分布式Session** — 基于Redis的分布式会话共享
5. **Feign内部调用鉴权** — RPC调用时携带Same-Token
6. **Dubbo/gRPC集成** — 跨服务上下文传播
7. **Same-Token定时刷新** — 支持新旧Token双轨并行

### ⚠️ Requirements
1. 所有服务需要共享同一个Redis（Same-Token依赖Redis）
2. Gateway需要使用Reactor响应式依赖
3. 子服务需要独立的Sa-Token依赖

### ❌ Out of Scope
1. 基础登录/权限/注解鉴权 → **sa-token**
2. SSO单点登录 → **sa-token-sso**
3. OAuth2.0 → **sa-token-oauth2**
4. 单体应用 → 直接使用 **sa-token** 即可

## 架构

```
客户端 → Gateway(校验登录+注入Same-Token) → 子服务(校验Same-Token)
                                                 ↕ Feign(携带Same-Token)
                                              其他子服务(校验Same-Token)
```

## 工作流

Step 1. **引入依赖** — Gateway用Reactor依赖，子服务用Servlet依赖
Step 2. **配置Redis** — 所有服务连接到同一个Redis
Step 3. **Gateway统一鉴权** — SaReactorFilter集中校验登录和权限
Step 4. **Gateway注入Same-Token** — ForwardAuthFilter添加请求头
Step 5. **子服务校验** — SaServletFilter校验Same-Token
Step 6. **Feign/Dubbo集成** — RPC调用传递Same-Token
Step 7. **定时刷新** — 定期刷新Same-Token以保证高可用

## 参考文档

| 文件 | 说明 | 来源 |
|------|------|------|
| [gateway-auth.md](references/gateway-auth.md) | 网关统一鉴权+分布式Session | [gateway-auth](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/gateway-auth.md)、[dcs-session](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/dcs-session.md) |
| [same-token.md](references/same-token.md) | Same-Token隔离+依赖引入 | [same-token](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/same-token.md)(277行)、[import-intro](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/import-intro.md) |

## FAQ

**Q: Same-Token和OAuth2有什么区别？**
A: Same-Token用于同源系统内部鉴权，简单高效。OAuth2用于开放平台第三方授权。内部用Same-Token，外部用OAuth2。

**Q: Same-Token有效期多久？**
A: 默认86400秒（1天），建议使用定时任务每5分钟刷新一次。刷新时旧Token作为次级Token保留，新旧其一都可通过。

**Q: Gateway和子服务需要不同的依赖？**
A: 是的。Gateway用 `sa-token-reactor-spring-boot-starter`（响应式），子服务用 `sa-token-spring-boot-starter`（Servlet）。

**Q: 分布式Session怎么实现？**
A: 只需引入 `sa-token-redis-template` 依赖并配置公共Redis地址，框架自动将会话数据存储到Redis，所有服务共享。

**Q: Gateway鉴权和子服务鉴权怎么分工？**
A: Gateway做统一登录校验+权限校验，子服务做Same-Token校验防止绕过网关直接访问。

## Gotchas

1. **Gateway必须用Reactor依赖** — 用错Servlet依赖会报错
2. **所有服务必须连同一个Redis** — Same-Token依赖Redis共享
3. **Same-Token默认一天有效期** — 生产环境必须配置定时任务刷新
4. **Feign拦截器需要添加到FeignClient配置中** — 别忘了 `configuration = FeignInterceptor.class`
5. **SaReactorFilter和SaServletFilter不可混用** — Gateway用Reactor，子服务用Servlet
6. **子服务直接暴露在外网时必须配置Same-Token校验** — 否则可绕过网关直接访问
7. **Same-Token刷新时有短暂的双Token并行期** — 旧Token会被保留直到下次刷新
8. **分布式Session的数据是序列化后存储的** — 存储的对象必须实现序列化接口

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
