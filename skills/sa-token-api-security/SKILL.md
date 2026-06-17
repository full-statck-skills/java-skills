---
name: sa-token-api-security
description: |
  Sa-Token API 安全防御技能。覆盖 API 参数签名(sa-token-sign)防篡改防重放(timestamp+nonce+sign四步演进)、API Key(sa-token-apikey)部分授权与Scope控制(可吊销/可限权)、临时Token(SaTempUtil内嵌核心包)短效链接邀请。
  API签名支持多应用(多secret-key)模式和多种摘要算法(md5/sha256/sha512)。API Key支持多账号体系、数据库持久化模式。临时Token支持前缀裁剪、反向查询、JWT集成。
  基础登录认证请先使用 sa-token 技能。
license: Apache-2.0
---

# Sa-Token API 安全

基于 `sa-token-doc/plugin/api-sign.md`（591行）+ `api-key.md`（283行）+ `temp-token.md`（120行）。

## Capability Boundaries

### ✅ Strong Suits
1. **API参数签名** — 跨系统接口防篡改、防重放（timestamp+nonce+sign四步演进）
2. **多应用签名模式** — 多套secret-key，不同摘要算法（md5/sha256/sha512）
3. **API Key管理** — 第三方开发者部分授权、Scope权限控制、可吊销
4. **API Key多账号体系** — 不同账号体系独立API Key模板
5. **API Key数据库模式** — 实现DataLoader接口持久化到数据库
6. **临时Token** — 短效链接邀请、非会话式授权
7. **临时Token前缀裁剪** — 按业务线加前缀区分
8. **临时Token反向查询** — 根据value反查所有token

### ⚠️ Requirements
1. API签名需要通信双方协商secret-key
2. API Key默认保存在缓存中（重启丢失），持久化需实现DataLoader
3. 临时Token内嵌核心包，无需额外依赖

### ❌ Out of Scope
1. 基础登录/权限认证 → **sa-token**
2. JWT集成/Redis → **sa-token-integration**
3. 微服务Same-Token → **sa-token-micro**

## 什么时候用哪个功能

| 场景 | 推荐方案 | 原因 |
|------|----------|------|
| 系统A调用系统B的API，防止参数篡改 | API签名 | 轻量级，不需要额外存储 |
| 给第三方开发者提供API访问凭证 | API Key | 可吊销、可控制Scope权限 |
| 生成一个短期的邀请链接 | 临时Token | 无状态、指定过期时间 |
| 需要同时防篡改+身份认证 | API签名+API Key | 两者可同时使用 |

## 工作流

### API签名工作流
Step 1. 引入 `sa-token-sign` 依赖
Step 2. 配置 `secret-key` 和摘要算法
Step 3. 请求端用 `SaSignUtil.addSignParamsAndJoin()` 构建签名的参数
Step 4. 接收端用 `SaSignUtil.checkRequest()` 或 `@SaCheckSign` 校验

### API Key工作流
Step 1. 引入 `sa-token-apikey` 依赖
Step 2. 调用 `SaApiKeyUtil.createApiKeyModel()` 创建API Key
Step 3. 客户端通过请求参数或header提交apikey
Step 4. 服务端用 `@SaCheckApiKey` 注解校验

### 临时Token工作流
Step 1. 调用 `SaTempUtil.createToken()` 创建临时Token
Step 2. 将Token传递给使用者（URL/消息等）
Step 3. 使用者调用 `SaTempUtil.parseToken()` 解析

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| API参数签名(防篡改防重放) | references/api-sign.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md) |
| API Key(部分授权管理) | references/api-key.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md) |
| 临时Token(短效链接) | references/temp-token.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md) |

## FAQ

**Q: API签名和Same-Token有什么区别？**
A: API签名用于参数防篡改防重放（数据完整性），Same-Token用于服务间身份认证（身份验证）。可同时使用。

**Q: API Key和会话Token有什么区别？**
A: API Key是静态的、可吊销的、Scope受限的。会话Token是动态的、登录后自动获取的、拥有账号完整权限。场景不同不能互相替代。

**Q: 临时Token的有效期怎么设？**
A: 创建时通过第二个参数指定（秒），如 `SaTempUtil.createToken("10014", 200)` 表示200秒。

**Q: API Key怎么持久化到数据库？**
A: 实现 `SaApiKeyDataLoader` 接口，框架会先查缓存，缓存不存在时调用DataLoader从数据库加载。

**Q: 临时Token能不能JWT模式？**
A: 可以。引入 `sa-token-temp-jwt` 依赖并配置jwt-secret-key，上层API不变，底层使用JWT内核。

## Gotchas

1. **API签名中secret-key不要硬编码在代码中** — 应配置在配置中心或环境变量
2. **API Key默认保存在缓存中** — 重启后丢失，需要数据库模式请实现DataLoader
3. **临时Token创建时不记录索引（第三个参数=false）** — 默认无法反查value对应的token
4. **API前缀裁剪时指定错误前缀会返回null** — 不是抛出异常
5. **API签名的secret-key泄露后需要立即更换** — 更换后所有使用旧key的请求会失败
6. **多个API Key可以赋予不同的Scope** — 做到最小化授权
7. **临时Token可用于非登录场景的授权** — 比如邮箱验证链接、邀请注册链接
8. **API签名的时间戳差距默认15分钟** — 可根据网络延迟调整

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅供本地开发参考。
