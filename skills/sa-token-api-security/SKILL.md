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

## 参考文档

| 主题 | 文件 | 来源 |
|------|------|------|
| API参数签名(防篡改防重放) | references/api-sign.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md) |
| API Key(部分授权管理) | references/api-key.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md) |
| 临时Token(短效链接) | references/temp-token.md | [GitHub](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md) |
