---
name: sa-token-integration
description: |
  Sa-Token 集成扩展技能。覆盖 JWT 集成(Simple/Mixin/Stateless三种模式对比表)、Redis持久化(JDK序列化/JSON序列化)、Alone-Redis独立Redis(鉴权缓存与业务缓存隔离)、AOP注解鉴权(Service层使用注解)、SpEL表达式注解(@SaCheckEL)、Quick-Login快速登录(零代码登录页)、JSON序列化扩展(Jackson/Fastjson/Fastjson2/Snack3)、模板引擎集成(Thymeleaf/Freemarker标签方言)、RPC集成(Dubbo/Dubbo3/gRPC上下文传播)。
  当用户需要集成JWT实现无状态认证、配置Redis分布式会话、缓存隔离、Service层注解鉴权、快速搭建登录页面时使用。
  基础登录认证请先使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token 集成扩展

基于 `sa-token-doc/plugin/` 集成类文档。

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| JWT三模式(Simple/Mixin/Stateless) | references/jwt-extend.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md) |
| Redis持久化+Alone-Redis | references/dao-extend.md | [dao-extend](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/dao-extend.md)、[integ-redis](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/integ-redis.md) |
