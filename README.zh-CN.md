<div align="center">

# java-skills

**Java development best practices and coding conventions**

[![GitHub](https://img.shields.io/badge/github-full--stack--skills%2Fjava-skills-green.svg)](https://github.com/full-stack-skills/java-skills)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-兼容-purple.svg)](https://agentskills.io)

[English](./README.md) | 简体中文

[简介](#-简介) ·
[安装](#-安装) ·
[技能列表](#-技能列表) ·
[支持的智能体](#-支持的智能体) ·
[生态](#-生态)

</div>

---

## 📖 简介

**Java 技能** 是一组 AI 编码智能体技能，属于 [Full Stack Skills](https://github.com/partme-ai/full-stack-skills) 生态，由 [PartMe.AI](https://github.com/partme-ai) 维护。

本包包含 **13 个技能**。每个技能是一个独立的 `SKILL.md` 文件，AI 智能体按需加载。

## 📦 安装

```bash
npx skills add full-stack-skills/java-skills
```

或按需安装特定技能：

```bash
npx skills add full-stack-skills/java-skills --skill <skill-name>
```

## 🎯 技能列表 (13)

| 技能 | 描述 |
|------|------|
| `java-code-comments` | Java 代码注释规范与最佳实践 |
| `java-conventions` | 统一 Java 项目编码规范与注释规范（SLF4J+Lombok 日志、Bean Lombok 注解选择、判空 Objects/Optional、工具类优先级 Spring→Apache Commons→Hutool→Guava、复杂... |
| `java-development-manual` | Java 开发手册与指南 |
| `unirest-java-3` | Unirest 3.x HTTP 客户端，基于 Apache HttpClient，支持 Java 8+，内置 GSON，支持每请求代理、Mock 测试、缓存和连接池调优 |
| `unirest-java-4` | Unirest 4.x HTTP 客户端，基于 java.net.http，支持 Java 11+，SSE、WebSocket、HTTP/2、ProxySelector、Mock 测试、缓存和模块化 JSON 支持 |
| `okhttp3-5.x` | OkHttp 5.x HTTP 客户端，支持 Java/JVM 8+ 和 Android 5+，HTTP/2、透明 GZIP、Fast Fallback、MockWebServer、GraalVM Native Image 支持 |
| `sa-token` | Sa-Token 核心权限认证框架 — 登录认证、权限/角色认证、注解鉴权、路由拦截鉴权、Session 会话管理、框架配置、前后端分离 |
| `sa-token-advanced` | Sa-Token 高级安全特性 — 二级认证、账号封禁(全/分类/阶梯)、身份切换、多账号体系(StpUserUtil/StpKit)、全局侦听器与过滤器、密码加密、Http Basic/Digest |
| `sa-token-sso` | Sa-Token SSO 单点登录 — 三种模式(同域Cookie/跨域重定向/跨域Http ticket)、Server 搭建、Client 接入、单点注销、前后端分离 H5 方案 |
| `sa-token-oauth2` | Sa-Token OAuth2.0 服务端 — 四种授权模式(授权码/隐式/密码/客户端凭证)、Scope 权限控制、OIDC、自定义 grant_type |
| `sa-token-micro` | Sa-Token 微服务鉴权 — Same-Token 内部服务隔离、SpringCloud Gateway 统一鉴权、Feign/Dubbo/gRPC 鉴权、分布式 Session |
| `sa-token-api-security` | Sa-Token API 安全 — API 参数签名(防篡改防重放)、API Key 部分授权管理、临时 Token 短效链接 |
| `sa-token-integration` | Sa-Token 集成扩展 — JWT 三种模式(Simple/Mixin/Stateless)、Redis 持久化、Alone-Redis 缓存隔离、AOP 注解鉴权、Quick-Login 快速登录、模板引擎集成 |

## 🤖 支持的智能体

适用于 [Claude Code](https://code.claude.com)、[Codex](https://developers.openai.com/codex)、[Cursor](https://cursor.com)、[OpenCode](https://opencode.ai)、[Gemini CLI](https://geminicli.com)、[GitHub Copilot](https://github.com/features/copilot)、[Windsurf](https://codeium.com/windsurf) 及 [70+ 其他平台](https://agentskills.io/clients)。

### Claude Code 安装

**方式一：npx skills CLI（推荐）**

```bash
npx skills add full-stack-skills/java-skills
```

**方式二：手动安装**

```bash
git clone https://github.com/full-stack-skills/java-skills.git
cp -r java-skills/skills/* .claude/skills/
```

更多详情请参阅 [Claude Code 技能指南](https://code.claude.com/docs/en/skills) 和 [Agent Skills 规范](https://agentskills.io/)。

## 🌐 生态

| 资源 | 链接 |
|------|------|
| **Full Stack Skills** | [github.com/partme-ai/full-stack-skills](https://github.com/partme-ai/full-stack-skills) |
| **全部技能组** | [github.com/full-stack-skills](https://github.com/full-stack-skills) |
| **Agent Skills 规范** | [agentskills.io](https://agentskills.io) |
| **Skills CLI** | [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) |

## 📄 许可证

Apache 2.0 — 详见 [LICENSE](LICENSE)。
