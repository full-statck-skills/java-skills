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

## 适用场景

当用户需要以下场景时，激活此技能：
- **JWT无状态认证** — 将登录信息编码到Token中，减少Redis查询，适合高并发场景
- **分布式Session共享** — 多实例部署时需要共享会话数据
- **Redis缓存隔离** — 将Sa-Token的Redis与业务Redis物理分开
- **Service层注解鉴权** — 在Service层（非Controller）使用@SaCheckLogin等注解
- **快速搭建登录页面** — 开发环境或内管系统零代码登录页
- **模板引擎鉴权标签** — Thymeleaf/Freemarker页面中控制按钮显隐

## Workflow

Step 1. **确定集成需求** — 选择JWT/Redis/AOP/模板等模块
Step 2. **引入依赖** — 添加对应Maven/Gradle依赖
Step 3. **配置参数** — 配置jwt-secret-key/Redis连接/Alone-Redis等
Step 4. **注入实现** — 注入StpLogic、注册过滤器、配置模板引擎
Step 5. **验证测试** — 确认集成生效，测试核心功能是否正常

## Capability Boundaries

### ✅ Strong Suits
1. **JWT集成** — Simple/Mixin/Stateless三种模式选择
2. **Redis持久化** — JDK序列化/JSON序列化两种方式
3. **Alone-Redis独立Redis** — 认证缓存与业务缓存物理隔离
4. **AOP注解鉴权** — 在Service层使用@SaCheckLogin等注解
5. **SpEL表达式** — @SaCheckEL使用Spring表达式
6. **Quick-Login快速登录** — 零代码注入登录页面
7. **JSON序列化扩展** — Jackson/Fastjson/Fastjson2/Snack3/Snack4
8. **模板引擎集成** — Thymeleaf/Freemarker自定义标签
9. **RPC集成** — Dubbo/Dubbo3/gRPC上下文传播

### ⚠️ Requirements
1. JWT需要配置 `jwt-secret-key`
2. Redis需要配置 `spring.redis` 连接信息
3. AOP注解与拦截器注解不能同时使用

### ❌ Out of Scope
1. 基础登录/权限/注解鉴权 → **sa-token**
2. SSO → **sa-token-sso**
3. OAuth2.0 → **sa-token-oauth2**
4. 微服务鉴权 → **sa-token-micro**

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| JWT三模式(Simple/Mixin/Stateless) | references/jwt-extend.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md) |
| Redis持久化+Alone-Redis | references/dao-extend.md | [dao-extend](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/dao-extend.md)、[integ-redis](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/integ-redis.md) |

## FAQ

**Q: JWT三种模式怎么选？**
A: Simple模式推荐（功能完整：踢人、封禁、会话管理都支持）。需要无状态选Stateless（但踢人/封禁不可用）。Mixin介于两者之间。

**Q: Redis两种序列化方式选哪个？**
A: 推荐RedisTemplate JSON序列化（数据可读，方便排查）。JDK序列化兼容性更好但数据是乱码。

**Q: Alone-Redis和普通Redis有什么区别？**
A: Alone-Redis使用独立的Redis连接和数据库，与业务Redis完全隔离，保证认证缓存不受业务影响。

**Q: AOP注解鉴权和拦截器鉴权能同时用吗？**
A: 不能同时使用。AOP用于Service层，拦截器用于Controller层，选择一种即可。

**Q: Quick-Login适合生产环境吗？**
A: 适合小系统或内部管理系统。生产环境建议自定义登录页面。

**Q: 模板引擎标签支持哪些功能？**
A: 支持 `sa:login`（登录校验）、`sa:hasRole`（角色判断）、`sa:hasPermission`（权限判断）等标签。

## Gotchas

1. **Simple模式 `is-share` 恒等于false** — 与Extra数据不兼容，无法共用token
2. **Mixin模式 `is-concurrent` 必须为true** — 否则踢人下线API不可用
3. **JWT集成后Token变为JWT格式** — 不再是uuid格式，内容可解码查看
4. **Alone-Redis有独立的配置前缀 `sa-token-alone-redis`** — 不是 `spring.redis`
5. **Redis JSON序列化后Session数据在Redis中可读** — 可在Redis客户端中直接查看
6. **AOP注解和拦截器注解不能混用** — 选了AOP就不能再用拦截器
7. **Quick-Login默认账号密码 sa/123456** — 生产环境务必修改
8. **Dubbo集成自动处理上下文传播** — 无需额外代码，引入依赖即可

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
