---
name: spring-boot-starter-patterns
description: 通用 Spring Boot Starter 开发规范（组织无关）：标准 POM 结构模板（三段式 properties 分类 + 自然排序）、十分支版本矩阵（2.3.x~4.1.x 对应 Spring Boot 2.3.12~4.1.0 与 JDK 8/17/21）、多线发布工作流（tag → 仓库发布 → SNAPSHOT 滚动）、JDK 兼容性规则（java.version 用 8 不用 1.8、maven-compiler-plugin 3.15.0 行为差异）、JaCoCo 90% 覆盖率门禁。适用于任何组织创建新 starter、标准化已有 starter 的 pom.xml、核对分支版本矩阵、执行 tag 发布与版本滚动；文末附 easy4j 组织扩展（阿里云仓库、SDK 线映射、@author 规范）。触发词：starter 开发、pom 标准化、分支版本、tag 发布、版本滚动、spring boot starter 模板、多 spring boot 版本适配。
---

# spring-boot-starter-patterns

「标准 POM 结构 + 十分支版本矩阵 + 月度日期版本」的 Spring Boot Starter 开发体系。**组织无关的通用规范**；easy4j 组织扩展见 §7。

## 1. POM 结构模板（铁律）

### 1.1 元素顺序（严格遵守）

```
<project>
├── <modelVersion>4.0.0</modelVersion>
├── <parent>                          # spring-boot-starter-parent（版本按分支矩阵）
├── 坐标                               # groupId / artifactId / version / packaging
├── <name> / <description> / <url>    # name 用 ${project.groupId}:${project.artifactId}
├── <licenses>                        # 开源协议（Apache 2.0）；发布 Central 必需（见 1.1b）
├── <scm>                             # 源码仓库信息；发布 Central 必需（见 1.1b）
├── <developers>                      # 开发者信息；发布 Central 必需（见 1.1b）
├── <properties>                      # 三段式分类（见 1.2）
├── <dependencyManagement>            # BOM 导入 + 版本管理
├── <dependencies>                    # 实际依赖（带 <!-- For Xxx --> 注释）
├── <distributionManagement>          # 完整：release + snapshot 双仓库（按组织填写）
├── <build>                           # 完整：pluginManagement + plugins（见 1.3）
└── <profiles>                        # 完整：disable-javadoc-doclint + release（见 1.4）
```

### 1.1b 项目元数据三段（licenses / scm / developers）

发布 Maven Central 的**必需元数据**，每段配一行中文注释说明，scm/developers 用 `${project.artifactId}` 参数化（参照 openclaw-java-sdk/pom.xml）：

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

`{ORG}` 按项目实际 GitHub 组织替换。标准化已有 pom 时**保留原值**（developer 可能不同），仅补齐缺失段落与注释。distributionManagement 与 build 之前同样加段落注释：`<!-- 制品发布仓库配置（distributionManagement） -->`、`<!-- 构建配置（Build） -->`。

### 1.2 properties 三段式分类 + 自然排序

```xml
<properties>
    <!-- ═══ 第一段：基础属性（自然排序）═══ -->
    <java.version>8</java.version>                     <!-- 按分支矩阵；用 8 不用 1.8 -->
    <maven.compiler.source>${java.version}</maven.compiler.source>
    <maven.compiler.target>${java.version}</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

    <!-- ═══ 第二段：Third-Party Dependencies（自然排序）═══ -->
    <!-- 此处只放「本 starter 集成的第三方组件」版本，例如： -->
    <!-- <redisson.version>3.27.0</redisson.version>      -->
    <!-- <okhttp.version>4.12.0</okhttp.version>          -->

    <!-- ═══ 第三段：Maven Plugin Dependencies（自然排序）═══ -->
    <maven-central-publishing-plugin.version>0.11.0</maven-central-publishing-plugin.version>
    <maven-compiler-plugin.version>3.15.0</maven-compiler-plugin.version>
    <maven-deploy-plugin.version>3.1.4</maven-deploy-plugin.version>
    <maven-enforcer-plugin.version>3.6.3</maven-enforcer-plugin.version>
    <maven-gpg-plugin.version>3.2.8</maven-gpg-plugin.version>
    <maven-jacoco-plugin.version>0.8.15</maven-jacoco-plugin.version>
    <maven-jar-plugin.version>3.5.0</maven-jar-plugin.version>
    <maven-javadoc-plugin.version>3.11.2</maven-javadoc-plugin.version>
    <maven-nexus-staging-plugin.version>1.7.0</maven-nexus-staging-plugin.version>
    <maven-release-plugin.version>3.3.1</maven-release-plugin.version>
    <maven-resources-plugin.version>3.5.0</maven-resources-plugin.version>
    <maven-source-plugin.version>3.4.0</maven-source-plugin.version>
    <maven-surefire-plugin.version>3.5.2</maven-surefire-plugin.version>
    <!-- 其余插件版本按需增删：antrun/clean/dependency/failsafe/help/install/invoker/shade/war -->
</properties>
```

**第二段规则**：只包含被集成的外部组件（即 starter 封装的目标库）及其直接必需依赖。不要把 okhttp、slf4j 等通用库默认写入——除非本 starter 确实依赖它们。

### 1.3 build 完整结构

**pluginManagement**（核心 11 插件，带版本+完整配置）：

| # | 插件 | 关键配置 |
|---|------|---------|
| 1 | maven-compiler-plugin | source/target + encoding + maxmem 512M + `annotationProcessorPaths`（lombok；**项目无 lombok 则删**） |
| 2 | maven-enforcer-plugin | requireMavenVersion + requireJavaVersion（CDATA 消息） |
| 3 | maven-gpg-plugin | sign-artifacts @ verify |
| 4 | maven-resources-plugin | encoding |
| 5 | maven-release-plugin | tagNameFormat v@{version} + releaseProfiles release |
| 6 | maven-source-plugin | jar-no-fork |
| 7 | maven-surefire-plugin | `skip=false` + `skipTests=false` + **`argLine ${argLine} -Xmx1024m -Dfile.encoding=UTF-8`**（`${argLine}` 为 JaCoCo agent 注入点，不可省）+ includes `**/*Test.java` `**/*_Test.java` + exclude `**/TestBean.java` |
| 8 | maven-jar-plugin | skipIfEmpty + manifest 双 entries |
| 9 | maven-javadoc-plugin | charset/encoding/docencoding + attach-javadocs @ package |
| 10 | nexus-staging-maven-plugin | ossrh + autoReleaseAfterClose（Sonatype Nexus 发布用） |
| 11 | central-publishing-maven-plugin | `publishingServerId central`（Maven Central 新门户） |

> 发布渠道二选一或并存：传统 OSSRH（nexus-staging）或 Central Portal（central-publishing）。只用其一时可只保留对应插件。

**plugins**（9 个引用 + jacoco）：

1. `jacoco-maven-plugin`（唯一带完整内联配置）：prepare-agent → report @ verify → **check @ verify（BUNDLE LINE COVEREDRATIO ≥ 0.90，haltOnFailure=true）**
2. enforcer / compiler / resources / surefire / jar / source / install / deploy（裸引用，配置走 pluginManagement）

### 1.4 profiles 完整结构

- `disable-javadoc-doclint`：jdk [1.8,) 激活，`additionalparam -Xdoclint:none`
- `release`：按序引用 enforcer→compiler→resources→surefire→jar→source→javadoc→install→gpg→deploy→release→nexus-staging→central-publishing

### 1.5 dependencies 组成（通用骨架）

任何 starter 的依赖分四组：

```xml
<dependencies>
    <!-- ① Spring Boot 必需（四件套，所有 starter 一致） -->
    spring-boot-starter / spring-boot-autoconfigure /
    spring-boot-configuration-processor(optional) / spring-boot-starter-test(test)

    <!-- ② 被集成的外部组件（本 starter 的存在意义）-->
    <!-- 例：<groupId>com.squareup.okhttp3</groupId><artifactId>okhttp</artifactId> -->
    <!-- 例：<groupId>org.redisson</groupId><artifactId>redisson</artifactId> -->

    <!-- ③ 编译期工具（按需）-->
    lombok(provided) —— 用则保留，不用则连同 compiler 的 annotationProcessorPaths 一起删

    <!-- ④ 测试增强（按需）-->
    junit-jupiter(test) / slf4j-simple(test) 等
</dependencies>
```

**反模式**：把 okhttp、commons-io 等当作"默认依赖"复制进每个 starter。它们只是「② 被集成组件」的示例。

### 1.6 distributionManagement

按组织实际填写 release + snapshot 双仓库（形态固定：`<repository>` + `<snapshotRepository>`，enabled 开关互斥，snapshot 侧 `uniqueVersion=true`）。示例见 pom-template.xml。

## 2. 十分支版本矩阵

一条源码适配十个 Spring Boot 版本线：

| 分支 | Spring Boot parent | JDK | starter 版本（快照→正式） |
|------|-------------------|-----|-------------------------|
| 2.3.x | 2.3.12.RELEASE | 8 | 2.3.x.{yyyyMMdd}-SNAPSHOT → 2.3.x.{yyyyMMdd} |
| 2.7.x | 2.7.18 | 8 | 2.7.x.{yyyyMMdd}-SNAPSHOT → 2.7.x.{yyyyMMdd} |
| 3.0.x | 3.0.13 | 17 | 3.0.x.{yyyyMMdd}-SNAPSHOT → 3.0.x.{yyyyMMdd} |
| 3.1.x | 3.1.12 | 17 | 3.1.x.{yyyyMMdd}-SNAPSHOT → 3.1.x.{yyyyMMdd} |
| 3.2.x | 3.2.12 | 17 | 3.2.x.{yyyyMMdd}-SNAPSHOT → 3.2.x.{yyyyMMdd} |
| 3.3.x | 3.3.13 | 17 | 3.3.x.{yyyyMMdd}-SNAPSHOT → 3.3.x.{yyyyMMdd} |
| 3.4.x | 3.4.13 | 17 | 3.4.x.{yyyyMMdd}-SNAPSHOT → 3.4.x.{yyyyMMdd} |
| 3.5.x | 3.5.16 | 17 | 3.5.x.{yyyyMMdd}-SNAPSHOT → 3.5.x.{yyyyMMdd} |
| 4.0.x | 4.0.7 | 21 | 4.0.x.{yyyyMMdd}-SNAPSHOT → 4.0.x.{yyyyMMdd} |
| 4.1.x | 4.1.0 | 21 | 4.1.x.{yyyyMMdd}-SNAPSHOT → 4.1.x.{yyyyMMdd} |

- 分支间源码/测试保持一致；pom 差异 = Spring Boot parent + JDK + （依赖的内部组件线版本）
- 版本格式：`{line}.x.{yyyyMMdd}`（正式），加 `-SNAPSHOT` 为开发版；月度滚动如 `20260630` → `20260730`

## 3. 十 tag 发布工作流

### 步骤 1：创建 10 个 tag

```bash
git checkout 2.3.x && git tag 2.3.x.20260630
# … 依次 3.0.x ~ 4.1.x（tag 名 = 目标正式版本号）
git push origin --tags
```

前置：分支 pom `<version>` 已去 `-SNAPSHOT`（`mvn versions:set -DremoveSnapshot`）；依赖的内部组件同名正式版已发布。

### 步骤 2：发布制品仓库

```bash
git checkout 2.3.x.20260630
mvn clean deploy -P release   # source + javadoc + gpg + 发布插件
# … 依次 10 个 tag
```

依赖顺序：内部组件先行（starter 2.3.x ← 内部线 1.0.x…按组织映射），再发 starter。

### 步骤 3：滚动更新 10 个分支 SNAPSHOT

```bash
# 各分支：20260630-SNAPSHOT → 20260730-SNAPSHOT（含自身版本与内部依赖版本）
git checkout 2.3.x
mvn versions:set -DnewVersion=2.3.x.20260730-SNAPSHOT
# 同步更新内部组件依赖 <xxx.version> 为对应线 20260730-SNAPSHOT
git commit -am "chore: bump to 20260730-SNAPSHOT" && git push
```

### 步骤 4：核对 10 个分支 Spring Boot 版本

按 §2 矩阵逐分支校验 `<parent><version>`；不一致用 `mvn versions:update-parent -DparentVersion=[目标]` 修正。

## 4. JDK 兼容性规则（踩坑记录）

| 规则 | 原因 |
|------|------|
| `java.version` 用 `8`，禁用 `1.8` | maven-compiler-plugin 3.15.0 对 `--release 1.8` 报「不支持发行版 1.8」；`8` 全兼容 |
| 本地编译统一 JDK 21 | JDK 21 支持 target 8-21；JDK 26 已移除 release 8。`export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| JDK 22+ 默认禁用注解处理 | compiler 加 `<proc>full</proc>` 或显式 annotationProcessorPaths 声明 lombok |
| Spring Boot 4.x + lombok | parent 自带 lombok 1.18.44，`${lombok.version}` 引用即可 |
| JDK 17+ 强封装 | 部分项目 surefire 需追加 `--add-opens` 到 argLine |
| Spring Boot 4.x API 断层 | javax→jakarta、WebSecurityConfigurerAdapter 移除、DataSourceProperties 包迁移——3.x→4.x 迁移工作量最大 |

## 5. 质量门禁

- **JaCoCo**：BUNDLE LINE 覆盖率 ≥ 0.90，`haltOnFailure=true`
- **测试约定**：JUnit 5 + AssertJ；surefire 同时匹配 `*Test.java` 与 `*_Test.java`
- **源码三件套**：`XxxAutoConfiguration` + `XxxProperties`（@ConfigurationProperties）+ `XxxTemplate`
- **测试三件套**：`XxxAutoConfigurationTest`（ApplicationContextRunner）+ `XxxPropertiesTest` + 模板测试

## 6. 新建 starter 检查清单

1. 复制 pom-template.xml，替换 `{GROUP_ID}`/`{ARTIFACT}`/`{LINE}`/外部组件占位
2. 按目标分支填 parent.version / java.version（§2 矩阵）
3. properties 三段式 + 自然排序核对
4. 填写组织 distributionManagement
5. jacoco 90% 门禁就位
6. 源码三件套 + 测试三件套（§5）
7. `mvn clean verify` BUILD SUCCESS + All coverage checks met
8. 十分支创建 + 版本矩阵核对（§2）

## 7. easy4j 组织扩展

通用规范之上，easy4j 组织的额外约定：

- **groupId**：`io.github.easy4j`
- **distributionManagement**：阿里云 packages.aliyun.com（release: `2624322-release-6F6h6R`；snapshot: `2624322-snapshot-3EoOv3`）
- **内部 SDK 线映射**：starter 依赖的内部组件（xxx-java-sdk）分支为 `feature/{line}`，与 starter 线 1:1——starter 2.3.x←SDK feature/1.0.x、starter 2.7.x←feature/2.0.x、starter 3.{0..5}.x←feature/3.{0..5}.x、starter 4.{0,1}.x←feature/4.{0,1}.x
- **@author 规范**：`@author <a href="https://github.com/loong10k">Loong Wan</a>`；英语 Javadoc
- **范式参照**：`okhttp3-spring-boot-starter`（测试）、`openclaw-spring-boot-starter`（注释与 POM 权威模板）、`hermes-spring-boot-starter`（简洁测试）
