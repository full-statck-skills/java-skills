---
name: java-component-patterns
description: |
  Java 组件（SDK/工具库，非 Spring Boot starter）封装规范。无 parent 独立 POM 结构、licenses/scm/developers 元数据三段、三段式 properties（基础/Dependency versions/Plugin versions 自然排序）、maven.compiler.release 的 API 安全用法、多 JDK 分支模型（feature/{line} → JDK 8/17/21）、组件间同线依赖、tag 发布与 SNAPSHOT 滚动、JaCoCo 90% 门禁。
  纠正 LLM：给独立组件加 spring-boot-starter-parent、java.version 写 1.8 触发 release 编译失败、properties 不分类不排序、漏 licenses/scm/developers 导致 Central 被拒、跨线依赖内部组件（1.0.x 依赖 2.0.x）、忘记无 parent 需自管全部插件版本。
  触发词：组件封装、SDK 开发、无 parent pom、独立库、java component、多 JDK 分支、xxx-java-sdk 模板。
license: Apache-2.0
---

# Java 组件（SDK / 工具库）封装规范

> 权威参照：`openclaw-java-sdk/pom.xml`  
> 完整模板：[assets/pom-template.xml](assets/pom-template.xml)  
> 与 spring-boot-starter-patterns 的区别：**无 parent、不依赖 Spring、面向纯 Java 组件**

## Capability Boundaries

### ✅ Strong Suits
1. **无 parent 独立 POM** — 插件/依赖版本全部自管（这是 properties 必须声明完整插件版本的原因）
2. **maven.compiler.release** — 比 source/target 更安全（--release 语义防误用高版本 JDK API）
3. **元数据三段** — licenses/scm/developers（Central 发布必需）
4. **多 JDK 分支** — feature/{line} 一份源码多 JDK 线，分支间仅 pom 差异
5. **组件间同线依赖** — feature/1.0.x 只依赖其他组件的 1.0.x 线

### ❌ Out of Scope
- Spring Boot starter（整合组件到 SB）→ 用 `spring-boot-starter-patterns`
- Spring 生态强依赖的库 → 应做成 starter

## LLM 最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 给独立组件加 spring-boot-starter-parent | 无 parent；插件版本在 properties 第三段自管 |
| 2 | `java.version` 写 `1.8` | 写 `8`（`--release 1.8` 新 JDK 报错） |
| 3 | 用 source/target 而非 release | `maven.compiler.release=${java.version}`（API 安全） |
| 4 | 漏 licenses/scm/developers | Central 发布必需；每段配中文注释 |
| 5 | 跨线依赖内部组件 | 同线原则：feature/1.0.x → 依赖 1.0.x 线 |
| 6 | 分支间源码漂移 | src/测试/README 逐字节一致；仅 pom 差异 |
| 7 | 本地用 JDK 26 编译 release 8 | `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| 8 | XML 注释里写 `--xxx` | XML 注释内禁止双连字符（not well-formed） |
| 9 | 以为 Maven 4 要改 POM 结构 | model 4.0.0 不变；仅 maven.version 基线与 enforcer 区间需调；可移除 flatten 插件（原生 consumer POM） |

## 核心速查

### 元素顺序（铁律）
```
坐标（无 parent！）→ name/url/description/version/packaging
→ licenses → scm → developers          （Central 必需）
→ properties（三段式）→ dependencyManagement → dependencies
→ distributionManagement → build → profiles
```

### properties 三段式
```
① 基础: java.version / maven.compiler.release / maven.version / encoding
② <!-- Dependency versions --> : 外部依赖 + 内部组件线版本
③ <!-- Maven Plugin versions --> : 完整插件版本（无 parent 全自管）
```

### 与 starter 的关键差异

| 维度 | 组件（本 skill） | starter |
|------|-----------------|---------|
| parent | **无** | spring-boot-starter-parent |
| 编译 | **release** | source/target |
| 依赖 | 可依赖内部组件线 | 依赖组件 + SB 四件套 |
| 三件套 | Client门面+Config+能力域分包 | AutoConfiguration+Properties+Template |
| 发布顺序 | **底层先发** → starter 后发 | 依赖组件已发布 |

### 分支模型速查

| feature/{line} | JDK |
|----------------|-----|
| 1.0.x | 8 |
| 2.0.x | 8 或 17 |
| 3.0.x ~ 3.5.x | 17 |
| 4.0.x / 4.1.x | 21 |

版本：`{line}.x.{yyyyMMdd}` ↔ `-SNAPSHOT`；同步法：`git checkout <src> -- src/ README.md`（不含 pom）。

## 新建/核对清单（8 步）

复制 assets/pom-template.xml → 替换占位符 → 按分支填 version/java.version（无 parent，lombok 显式版本）→ 核对三段式 → 源码三件套（Client/Config/能力域）→ 测试 → `mvn clean verify` → 多分支创建。完整演练见 [examples/create-component.md](examples/create-component.md)。

## References（按需加载）

| 文件 | 何时读 |
|------|--------|
| [references/pom-structure.md](references/pom-structure.md) | 写/改 pom 时：无 parent 结构详解、三段式全量、build 插件配置表、依赖四组 |
| [references/branch-release.md](references/branch-release.md) | 分支/发版时：多 JDK 分支同步法、同线依赖、tag 发布 5 步、滚动更新 |
| [references/maven4.md](references/maven4.md) | 用 Maven 4 构建时：M3/M4 差异、运行 JDK 17+、maven.version 基线、consumer POM（原生替代 flatten）、wrapper 迁移 |
| [examples/create-component.md](examples/create-component.md) | 从零封装组件的 8 步演练 |
| [assets/pom-template.xml](assets/pom-template.xml) | 可直接复制的占位符模板（XML 校验通过） |

## 质量门禁

- JaCoCo：BUNDLE LINE ≥ 0.90，haltOnFailure=true
- 测试：JUnit 5（junit-jupiter）+ AssertJ
- Javadoc：英语；类级 summary + @author/@since；方法级 @param/@return
