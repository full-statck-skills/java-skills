---
name: java-component-patterns
description: 通用 Java 组件（SDK/工具库，非 Spring Boot starter）封装规范：无 parent 独立 POM 结构、licenses/scm/developers 元数据三段、三段式 properties（基础/Dependency versions/Plugin versions 自然排序）、maven.compiler.release 用法与 JDK 兼容规则、JaCoCo 覆盖率门禁、多分支多 JDK 线模型（feature/1.0.x~4.1.x 对应 JDK 8/17/21）、tag 发布与 SNAPSHOT 滚动、组件间依赖（内部线依赖）规范。适用于从零封装第三方 SDK、标准化已有组件 pom.xml、组件多分支维护与发版。触发词：组件封装、SDK 开发、无 parent pom、独立库、java component、组件模板、多 JDK 分支。
---

# java-component-patterns

「无 parent 独立 POM + 元数据三段 + 多 JDK 分支线」的 Java 组件（SDK / 工具库）封装体系。**组织无关通用规范**；与 spring-boot-starter-patterns 的区别：**不继承 spring-boot-starter-parent、不依赖 Spring**，面向纯 Java 组件。

权威参照：`openclaw-java-sdk/pom.xml`。

## 1. POM 结构模板（铁律）

### 1.1 元素顺序（严格遵守）

```
<project>
├── <modelVersion>4.0.0</modelVersion>
├── 坐标（无 <parent>！）             # groupId / artifactId / name / url / description / version / packaging
├── <licenses>                        # 开源协议（见 1.1b）
├── <scm>                             # 源码仓库信息（见 1.1b）
├── <developers>                      # 开发者信息（见 1.1b）
├── <properties>                      # 三段式分类（见 1.2）
├── <dependencyManagement>            # 依赖版本集中管理（含内部组件线）
├── <dependencies>                    # 实际依赖（带 <!-- For Xxx --> 注释）
├── <distributionManagement>          # 完整：release + snapshot 双仓库（按组织填写）
├── <build>                           # 完整：pluginManagement + plugins（见 1.3）
└── <profiles>                        # 完整：disable-javadoc-doclint + release（见 1.4）
```

与 starter 的两大区别：
1. **无 `<parent>`**——所有插件版本、依赖版本自管（这正是 properties 必须声明完整插件版本的原因）
2. **`maven.compiler.release`** 替代 source/target（见 1.2），更严格的 JDK 目标控制

> 参照 SDK 实际将 build/profiles 排在 properties 之前（历史排版）；新建组件按上方 Maven 官方推荐顺序（properties 在 build 前）。

### 1.1b 项目元数据三段（licenses / scm / developers）

发布 Maven Central 的**必需元数据**，每段配一行中文注释，scm 用 `${project.artifactId}` 参数化：

```xml
    <!-- 开源协议采用 Apache 2.0 协议 -->
    <licenses>
        <license>
            <name>The Apache Software License, Version 2.0</name>
            <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>
        </license>
    </licenses>

    <!-- 源码仓库（SCM）信息 -->
    <scm>
        <connection>scm:git:https://github.com/{ORG}/${project.artifactId}.git</connection>
        <developerConnection>scm:git:https://github.com/{ORG}/${project.artifactId}.git</developerConnection>
        <url>https://github.com/{ORG}/${project.artifactId}</url>
        <tag>${project.artifactId}</tag>
    </scm>

    <!-- 开发者信息 -->
    <developers>
        <developer>
            <name>{DEV_NAME}</name>
            <email>{DEV_EMAIL}</email>
            <url>{DEV_URL}</url>
            <roles>
                <role>developer</role>
            </roles>
            <timezone>+8</timezone>
        </developer>
    </developers>
```

distributionManagement / build 之前同样加段落注释：`<!-- 制品发布仓库配置（distributionManagement） -->`、`<!-- 构建配置（Build） -->`。标准化已有 pom 时**保留原值**，仅补缺失段落与注释。

### 1.2 properties 三段式分类 + 自然排序

```xml
<properties>
    <!-- ═══ 第一段：基础属性（自然排序）═══ -->
    <java.version>8</java.version>                          <!-- 用 8/17/21；禁 1.8 -->
    <maven.compiler.release>${java.version}</maven.compiler.release>
    <maven.version>3.0</maven.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

    <!-- ═══ 第二段：Dependency versions（自然排序）═══ -->
    <!-- 本组件的外部依赖 + 依赖的内部组件线版本 -->
    <jackson.version>2.18.9</jackson.version>
    <okhttp3.version>4.12.0</okhttp3.version>
    <okhttp3-extension.version>1.0.x.20260630-SNAPSHOT</okhttp3-extension.version>
    <slf4j.version>2.0.18</slf4j.version>
    <lombok.version>1.18.46</lombok.version>
    <junit.version>5.11.4</junit.version>

    <!-- ═══ 第三段：Maven Plugin versions（自然排序）═══ -->
    <maven-central-publishing-plugin.version>0.11.0</maven-central-publishing-plugin.version>
    <maven-clean-plugin.version>3.5.0</maven-clean-plugin.version>
    <maven-compiler-plugin.version>3.15.0</maven-compiler-plugin.version>
    <maven-dependency-plugin.version>3.8.1</maven-dependency-plugin.version>
    <maven-deploy-plugin.version>3.1.4</maven-deploy-plugin.version>
    <maven-enforcer-plugin.version>3.6.3</maven-enforcer-plugin.version>
    <maven-gpg-plugin.version>3.2.8</maven-gpg-plugin.version>
    <maven-install-plugin.version>3.1.4</maven-install-plugin.version>
    <maven-jacoco-plugin.version>0.8.15</maven-jacoco-plugin.version>
    <maven-jar-plugin.version>3.5.0</maven-jar-plugin.version>
    <maven-javadoc-plugin.version>3.11.2</maven-javadoc-plugin.version>
    <maven-nexus-staging-plugin.version>1.7.0</maven-nexus-staging-plugin.version>
    <maven-release-plugin.version>3.3.1</maven-release-plugin.version>
    <maven-resources-plugin.version>3.5.0</maven-resources-plugin.version>
    <maven-source-plugin.version>3.4.0</maven-source-plugin.version>
    <maven-surefire-plugin.version>3.5.2</maven-surefire-plugin.version>
</properties>
```

注释标签用英文（`Dependency versions` / `Maven Plugin versions`，参照 SDK），与 starter 模板的中文注释（`Third-Party Dependencies`）均可，段内一律自然排序。

**`maven.compiler.release` vs source/target**：
- `release` 同时约束 API（--release 语义），防止误用高版本 JDK API，**组件库首选**
- ⚠️ `--release 1.8` 在新 JDK 报错只接受 `8`——所以 `java.version` 必须 `8` 而非 `1.8`

### 1.3 build 完整结构

**pluginManagement**（核心插件，带版本+配置，因无 parent 全部自管）：

| 插件 | 关键配置 |
|------|---------|
| maven-compiler-plugin | `release=${java.version}` + encoding + maxmem 512M + annotationProcessorPaths（lombok `${lombok.version}`；无 lombok 则删） |
| maven-enforcer-plugin | requireMavenVersion `[${maven.version}.0,)` + requireJavaVersion `[${java.version}.0,)`（CDATA 消息） |
| maven-gpg-plugin | sign-artifacts @ verify |
| maven-resources-plugin | encoding |
| maven-release-plugin | tagNameFormat v@{version} + releaseProfiles release |
| maven-source-plugin | jar-no-fork |
| maven-surefire-plugin | `skip=false` + `skipTests=false` + **`argLine ${argLine} -Xmx1024m -Dfile.encoding=UTF-8`**（`${argLine}` 为 JaCoCo 注入点）+ includes `**/*Test.java` `**/*_Test.java` |
| maven-jar-plugin | skipIfEmpty + manifest 双 entries |
| maven-javadoc-plugin | charset/encoding/docencoding + attach-javadocs @ package |
| maven-install/deploy-plugin | 裸配置 |
| nexus-staging-maven-plugin | ossrh + autoReleaseAfterClose（OSSRH 发布） |
| central-publishing-maven-plugin | `publishingServerId central`（Central Portal） |

**plugins**：jacoco（唯一内联完整配置：prepare-agent → report @ verify → **check @ verify，BUNDLE LINE ≥ 0.90，haltOnFailure=true**）+ enforcer/compiler/resources/surefire/jar/source/install/deploy 裸引用。

### 1.4 profiles 完整结构

- `disable-javadoc-doclint`：jdk [1.8,) 激活，`additionalparam -Xdoclint:none`
- `release`：enforcer→compiler→resources→surefire→jar→source→javadoc→install→gpg→deploy→release→nexus-staging→central-publishing

## 2. 多 JDK 分支模型

组件按目标 JDK / 依赖线维护多条 `feature/{line}` 分支：

| 分支 | JDK | 定位（按组织矩阵对应下游 starter 线） |
|------|-----|--------------------------------------|
| feature/1.0.x | 8 | 老线（对应 SB 2.3.x 线） |
| feature/2.0.x | 8 或 17 | （对应 SB 2.7.x 线） |
| feature/3.0.x ~ 3.5.x | 17 | 主力线群（对应 SB 3.x 线） |
| feature/4.0.x / 4.1.x | 21 | 新特性线（对应 SB 4.x 线） |

**分支间源码一致性**：src/、测试、README 逐字节一致；唯一差异是 pom.xml（java.version + 依赖版本 + 组件自身版本号）。同步用 `git checkout <source> -- src/ README.md`（不含 pom），再校正 pom 分支特有值。

**版本格式**：`{line}.x.{yyyyMMdd}`（正式）+ `-SNAPSHOT`（开发）；月度滚动 `20260630` → `20260730`。

## 3. 组件间依赖规范

- 组件可依赖**其他内部组件**（如 openclaw-java-sdk → okhttp3-extension），版本用同线 SNAPSHOT：`<okhttp3-extension.version>1.0.x.20260630-SNAPSHOT</okhttp3-extension.version>` 在 properties 第二段
- 依赖线对齐：feature/1.0.x 的组件依赖其他组件的 1.0.x 线（同线原则）
- dependencyManagement 集中声明内部依赖版本，dependencies 引用

## 4. tag 发布工作流

1. **去 SNAPSHOT**：`mvn versions:set -DremoveSnapshot`（各分支）
2. **打 tag**：`git checkout feature/1.0.x && git tag 1.0.x.20260630` → `git push origin --tags`
3. **发布**：`git checkout 1.0.x.20260630 && mvn clean deploy -P release`（source+javadoc+gpg+central）
4. **依赖顺序**：被依赖的底层组件先发（okhttp3-extension → openclaw-java-sdk → starter）
5. **滚动**：`mvn versions:set -DnewVersion={line}.x.20260730-SNAPSHOT` + 内部依赖版本同步 bump → commit + push

## 5. JDK 兼容性规则

| 规则 | 原因 |
|------|------|
| `java.version` 用 `8` 禁 `1.8` | `--release 1.8` 新 JDK 报错；`8` 全兼容 |
| 本地编译 JDK 21 | 支持 release 8-21；JDK 26 已移除 release 8 |
| release 语义防 API 误用 | `maven.compiler.release` 比 source/target 更安全 |
| JDK 22+ 注解处理默认禁用 | compiler 加 `<proc>full</proc>` 或显式 annotationProcessorPaths |
| Lombok 1.18.30+ | JDK 21+ 兼容线 |

## 6. 质量门禁与代码规范

- **JaCoCo**：BUNDLE LINE ≥ 0.90，haltOnFailure=true
- **测试**：JUnit 5（junit-jupiter）+ AssertJ；surefire 匹配 `*Test.java` / `*_Test.java`
- **源码三件套**：`XxxClient`（门面）+ `XxxConfig`（配置）+ 内部分包（cli/http 等按能力域）
- **Javadoc**：英语；类级 summary + `<p>` + @author/@since；方法级 @param/@return

## 7. 新建组件检查清单

1. 无 parent 骨架：坐标 + licenses/scm/developers（§1.1b）
2. properties 三段式（§1.2，release=${java.version}）
3. dependencyManagement（外部依赖 + 内部线依赖）+ dependencies
4. distributionManagement（组织仓库）+ build（§1.3）+ profiles（§1.4）
5. 多分支创建（§2）+ java.version 按线填 8/17/21
6. jacoco 90% 门禁 + 源码三件套 + 测试
7. `mvn clean verify` BUILD SUCCESS
8. 与 starter 的关系：组件（本规范）先行发布 → starter（spring-boot-starter-patterns）依赖集成
