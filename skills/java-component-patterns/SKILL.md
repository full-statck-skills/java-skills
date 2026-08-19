---
name: java-component-patterns
description: |
  Java 组件（SDK/工具库，非 Spring Boot starter）封装规范。无 parent 独立 POM 结构、licenses/scm/developers 元数据三段、三段式 properties（基础/Dependency versions/Plugin versions 自然排序）、Jackson BOM 统一版本管理、maven.compiler.release 的 API 安全用法、多 JDK 分支模型（feature/{line} → JDK 8/17/21）、组件间同线依赖、tag 发布与 SNAPSHOT 滚动、JaCoCo 90% 门禁、pom.xml 4 空格缩进格式化。
  纠正 LLM：给独立组件加 spring-boot-starter-parent、java.version 写 8（应写 1.8）、properties 不分类不排序、漏 licenses/scm/developers 导致 Central 被拒、跨线依赖内部组件（1.0.x 依赖 2.0.x）、忘记无 parent 需自管全部插件版本、Jackson 依赖在 dm 中放无 version 条目遮蔽 BOM、License URL 用 http（应用 https）。
  触发词：组件封装、SDK 开发、无 parent pom、独立库、java component、多 JDK 分支、xxx-java-sdk 模板、jackson-bom、Jackson 版本管理。
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
| 2 | `java.version` 写 `8` | 写 `1.8`（maven-compiler-plugin 3.15.0 + JDK8 组合下 `--release 8` 有问题；`1.8` 全版本兼容） |
| 3 | 用 source/target 而非 release | `maven.compiler.release=${java.version}`（API 安全） |
| 4 | 漏 licenses/scm/developers | Central 发布必需；每段配中文注释 |
| 5 | 跨线依赖内部组件 | 同线原则：feature/1.0.x → 依赖 1.0.x 线 |
| 6 | 分支间源码漂移 | src/测试/README 逐字节一致；仅 pom 差异 |
| 7 | 本地用 JDK 26 编译 release 8 | `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| 8 | XML 注释里写 `--xxx` | XML 注释内禁止双连字符（not well-formed） |
| 9 | 以为 Maven 4 下必须改 model | M4 兼容 4.0.0 零改动；session scope 等新特性才升级 4.1.0（仅 M4 可构建）；可移除 flatten（原生 consumer POM） |
| 10 | Jackson 依赖在 dependencyManagement 里写无 version 的条目 | 无 version 的 dm 条目会遮蔽 BOM import，导致 `dependencies.dependency.version is missing`；必须整体删除 dm 条目（不能只删 version 行），让 BOM 生效 |
| 11 | Jackson 每个模块单独写 version | 用 BOM 统一管理：properties 定义 `jackson-bom.version`，dependencyManagement 中 `import com.fasterxml.jackson:jackson-bom:${jackson-bom.version}`（2.x）或 `import tools.jackson:jackson-bom:${jackson-bom.version}`（3.x）；dependencies 中不写 version |
| 12 | License URL 用 `http://` | Apache License URL 必须用 `https://www.apache.org/licenses/LICENSE-2.0.txt`（http 会被 Central 拒绝） |
| 13 | pom.xml 缩进不一致 | 统一 4 空格缩进，XML 标签对齐，properties 三段式分组 |

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

### Jackson BOM 版本管理

组件依赖 Jackson 时，**必须用 BOM 统一管理**，禁止每个模块单独写 version：

```
properties:   jackson-bom.version = {版本}
dependencyManagement:
  <dependency>
    <groupId>com.fasterxml.jackson</groupId>     ← 2.x
    <artifactId>jackson-bom</artifactId>
    <version>${jackson-bom.version}</version>
    <type>pom</type>
    <scope>import</scope>
  </dependency>
dependencies:  jackson-databind / jackson-dataformat-xml 等（不写 version）
```

| 分支 | jackson-bom.version | groupId |
|------|---------------------|---------|
| 1.0.x | 2.18.9 | com.fasterxml.jackson |
| 2.0.x | 2.22.1 | com.fasterxml.jackson |
| 3.0.x | 3.2.1 | **tools.jackson** |

**⚠ 铁律**：dependencyManagement 中**禁止放无 version 的 Jackson 条目**——会遮蔽 BOM import，导致 `dependencies.dependency.version is missing`。必须整体删除 dm 条目。

### 与 starter 的关键差异

| 维度 | 组件（本 skill） | starter |
|------|-----------------|---------|
| parent | **无** | spring-boot-starter-parent |
| 编译 | **release** | source/target |
| 依赖 | 可依赖内部组件线 | 依赖组件 + SB 四件套 |
| 三件套 | Client门面+Config+能力域分包 | AutoConfiguration+Properties+Template |
| 发布顺序 | **底层先发** → starter 后发 | 依赖组件已发布 |

### 分支模型速查

| feature/{line} | JDK | java.version | Jackson BOM |
|----------------|-----|--------------|-------------|
| 1.0.x | 8 | 1.8 | 2.18.9 (com.fasterxml.jackson) |
| 2.0.x | 17 | 17 | 2.22.1 (com.fasterxml.jackson) |
| 3.0.x ~ 3.5.x | 21 | 21 | 3.2.1 (tools.jackson) |

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
| [examples/maven4-migration.md](examples/maven4-migration.md) | 迁 Maven 4 时：自管插件对照、移除 flatten（consumer POM 原生替代）、三分支验证、4.1.0 session scope 升级判断 |
| [assets/pom-template.xml](assets/pom-template.xml) | Maven 3 / model 4.0.0 模板（M3/M4 双轨，XML 校验通过） |
| [assets/pom-template-maven4.xml](assets/pom-template-maven4.xml) | Maven 4 / model 4.1.0 模板（enforcer [4.0.0,)、session scope 示例、无 flatten） |

## 质量门禁

- JaCoCo：BUNDLE LINE ≥ 0.90，haltOnFailure=true
- 测试：JUnit 5（junit-jupiter）+ AssertJ
- Javadoc：英语；类级 summary + @author/@since；方法级 @param/@return
