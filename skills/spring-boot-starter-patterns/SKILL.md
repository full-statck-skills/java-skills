---
name: spring-boot-starter-patterns
description: |
  Spring Boot Starter 开发规范（组织无关）。标准 POM 结构（元素顺序铁律、properties 三段式分类+自然排序、licenses/scm/developers 元数据三段、完整 build/profiles）、十分支版本矩阵（2.3.x~4.1.x ↔ Spring Boot 2.3.12~4.1.0 ↔ JDK 8/17/21）、十 tag 发布工作流（tag → Maven Central → SNAPSHOT 月度滚动）、JDK 兼容规则、JaCoCo 90% 覆盖率门禁。
  纠正 LLM：properties 不分类不排序、漏 licenses/scm/developers 导致 Central 发布被拒、java.version 写 1.8 触发编译失败、surefire argLine 丢 ${argLine} 导致 JaCoCo 失效、把 okhttp 等通用库当默认依赖复制。
  触发词：starter 开发、pom 标准化、分支版本矩阵、tag 发布、版本滚动、多 Spring Boot 版本适配、新建 xxx-spring-boot-starter。
license: Apache-2.0
---

# Spring Boot Starter 开发规范

> 权威模板：`openclaw-spring-boot-starter/pom.xml`（2.7.x，commit b091ee4）  
> 组织扩展：文末 §6；完整模板：[assets/pom-template.xml](assets/pom-template.xml)

## Capability Boundaries

### ✅ Strong Suits
1. **POM 结构铁律** — 元素顺序 + properties 三段式 + 元数据三段 + 完整 build/profiles
2. **十分支矩阵** — 一份源码适配 Spring Boot 2.3~4.1 十条线
3. **发布工作流** — tag → Central → SNAPSHOT 滚动 → parent 版本核对
4. **质量门禁** — JaCoCo BUNDLE LINE ≥ 90% haltOnFailure
5. **JDK 兼容规则** — java.version=8 禁 1.8、JDK 21 全线编译

### ❌ Out of Scope
- 纯 Java 组件/SDK（无 Spring 依赖）→ 用 `java-component-patterns`
- 组件自身的业务逻辑实现 → 仅约束工程结构

## LLM 最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | properties 平铺不分类不排序 | 三段式：基础→Third-Party→Maven Plugin，段内自然排序 |
| 2 | 删除 licenses/scm/developers | **保留并标准化**（Central 发布必需），每段配中文注释 |
| 3 | `java.version` 写 `1.8` | 写 `8`（compiler 3.15.0 对 `--release 1.8` 报错） |
| 4 | surefire argLine 丢 `${argLine}` | 必须 `${argLine} -Xmx1024m -Dfile.encoding=UTF-8`（JaCoCo 注入点） |
| 5 | 把 okhttp/commons-io 当默认依赖 | 只有被集成组件是业务依赖；SB 四件套+被集成组件+lombok(按需)+test |
| 6 | 项目无 lombok 却保留 annotationProcessorPaths | 无 lombok → 连同 compiler 注解路径块一起删 |
| 7 | jacoco check 不设 haltOnFailure | `<haltOnFailure>true` + BUNDLE LINE ≥ 0.90 |
| 8 | 用 JDK 26 编译 target 8 | `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |

## 核心速查

### 元素顺序（铁律）
```
parent → 坐标 → name/description/url
→ licenses → scm → developers      （Central 必需元数据）
→ properties（三段式） → dependencyManagement → dependencies
→ distributionManagement → build（pluginManagement+plugins）→ profiles
```

### properties 三段式
```
① 基础（自然排序）: java.version / maven.compiler.source+target / 两 encoding
② <!-- Third-Party Dependencies --> : 被集成组件版本
③ <!-- Maven Plugin Dependencies --> : 完整 22 插件版本
```

### 十分支矩阵（2.1 完整表见 references/version-matrix.md）
| 分支 | SB parent | JDK |
|------|-----------|-----|
| 2.3.x | 2.3.12.RELEASE | 8 |
| 2.7.x | 2.7.18 | 8 |
| 3.0.x~3.5.x | 3.0.13/3.1.12/3.2.12/3.3.13/3.4.13/3.5.16 | 17 |
| 4.0.x / 4.1.x | 4.0.7 / 4.1.0 | 21 |

版本格式：`{line}.x.{yyyyMMdd}-SNAPSHOT` ↔ tag `{line}.x.{yyyyMMdd}`；月度滚动 20260630→20260730。

### 源码/测试三件套
- 源码：`XxxAutoConfiguration` + `XxxProperties`(@ConfigurationProperties) + `XxxTemplate`
- 测试：`XxxAutoConfigurationTest`(ApplicationContextRunner) + `XxxPropertiesTest` + 模板测试

## 新建/核对清单（8 步）

复制 assets/pom-template.xml → 替换占位符 → 按分支矩阵填 parent/java.version → 核对 properties 三段式 → 源码三件套 → 测试三件套 → `mvn clean verify` 通过 → 十分支创建。完整演练与逐项勾选清单见 [examples/create-new-starter.md](examples/create-new-starter.md)。

## References（按需加载）

| 文件 | 何时读 |
|------|--------|
| [references/pom-structure.md](references/pom-structure.md) | 写/改 pom 时：元素顺序详解、三段式全量示例、build 11 插件配置表、profiles 完整结构 |
| [references/version-matrix.md](references/version-matrix.md) | 分支/发版时：十分支全表、tag 发布 4 步、SNAPSHOT 滚动映射、SB parent 核对、JDK 兼容规则表 |
| [examples/create-new-starter.md](examples/create-new-starter.md) | 从零新建 starter 的 8 步完整演练（含验收标准） |
| [assets/pom-template.xml](assets/pom-template.xml) | 直接复制使用的带占位符模板（XML 校验通过） |

## 何时用本 skill vs java-component-patterns

```
要发布的东西是什么?
├── xxx-spring-boot-starter（整合某组件到 Spring Boot）→ 本 skill
└── 独立 Java 库/SDK（无 Spring 依赖，无 parent）→ java-component-patterns
依赖顺序: 组件先发正式版 → starter 再发
```

## easy4j 组织扩展

- groupId `io.github.easy4j`；仓库 packages.aliyun.com（release `2624322-release-6F6h6R` / snapshot `2624322-snapshot-3EoOv3`）
- 内部 SDK 线 1:1 映射：starter 2.3.x←SDK feature/1.0.x … starter 4.1.x←feature/4.1.x
- @author：`<a href="https://github.com/loong10k">Loong Wan</a>`；英语 Javadoc
- 范式参照：okhttp3（测试）/ openclaw（注释与 POM 权威）/ hermes（简洁测试）
