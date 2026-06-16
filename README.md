<div align="center">

# java-skills

**Java development best practices and coding conventions**

[![GitHub](https://img.shields.io/badge/github-full--statck--skills%2Fjava-skills-green.svg)](https://github.com/full-statck-skills/java-skills)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-purple.svg)](https://agentskills.io)

English | [简体中文](./README.zh-CN.md)

[Introduction](#-introduction) ·
[Install](#-install) ·
[Skills](#-skills) ·
[Supported Agents](#-supported-agents) ·
[Ecosystem](#-ecosystem)

</div>

---

## 📖 Introduction

**Java Skills** is a curated collection of Agent Skills for AI coding agents, part of the [Full Stack Skills](https://github.com/partme-ai/full-stack-skills) ecosystem maintained by [PartMe.AI](https://github.com/partme-ai).

This package includes **6 skills**. Each skill is a self-contained `SKILL.md` file that AI agents load on-demand.

## 📦 Install

```bash
npx skills add full-statck-skills/java-skills
```

Or install specific skills:

```bash
npx skills add full-statck-skills/java-skills --skill <skill-name>
```

## 🎯 Skills (6)

| Skill | Description |
|-------|-------------|
| `java-code-comments` | Java code commenting conventions and best practices |
| `java-conventions` | 统一 Java 项目编码规范与注释规范（SLF4J+Lombok 日志、Bean Lombok 注解选择、判空 Objects/Optional、工具类优先级 Spring→Apache Commons→Hutool→Guava、复杂... |
| `java-development-manual` | Java development manual and guidelines |
| `unirest-java-3` | Unirest 3.x HTTP client for Java 8+ with Apache HttpClient, built-in GSON, per-request proxy, mocking, caching, and connection pool tuning |
| `unirest-java-4` | Unirest 4.x HTTP client for Java 11+ with java.net.http, SSE, WebSocket, HTTP/2, ProxySelector, mocking, caching, and modular JSON support |
| `okhttp3-5.x` | OkHttp 5.x HTTP client for Java/JVM 8+ and Android 5+ with HTTP/2, transparent GZIP, Fast Fallback, MockWebServer, and GraalVM Native Image support |

## 🤖 Supported Agents

Works with [Claude Code](https://code.claude.com), [Codex](https://developers.openai.com/codex), [Cursor](https://cursor.com), [OpenCode](https://opencode.ai), [Gemini CLI](https://geminicli.com), [GitHub Copilot](https://github.com/features/copilot), [Windsurf](https://codeium.com/windsurf), and [70+ others](https://agentskills.io/clients).

### Claude Code Installation

**Option 1: npx skills CLI (Recommended)**

```bash
npx skills add full-statck-skills/java-skills
```

**Option 2: Manual Installation**

```bash
git clone https://github.com/full-statck-skills/java-skills.git
cp -r java-skills/skills/* .claude/skills/
```

For more details, see the [Claude Code Skills Guide](https://code.claude.com/docs/en/skills) and [Agent Skills Spec](https://agentskills.io/).

## 🌐 Ecosystem

| Resource | Link |
|----------|------|
| **Full Stack Skills** | [github.com/partme-ai/full-stack-skills](https://github.com/partme-ai/full-stack-skills) |
| **All Skill Groups** | [github.com/full-statck-skills](https://github.com/full-statck-skills) |
| **Agent Skills Spec** | [agentskills.io](https://agentskills.io) |
| **Skills CLI** | [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) |

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE).
