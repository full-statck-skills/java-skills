---
name: spring-boot-starter-patterns
description: easy4j 组织 Spring Boot Starter 开发规范：标准 POM 结构模板（三段式 properties 分类 + 自然排序）、十分支版本矩阵（2.3.x~4.1.x 对应 Spring Boot 2.3.12~4.1.0 与 JDK 8/17/21）、十 tag 发布工作流（tag → Maven Central → SNAPSHOT 滚动）、JDK 兼容性规则（java.version 用 8 不用 1.8、maven-compiler-plugin 3.15.0 行为差异）、JaCoCo 90% 覆盖率门禁与中央发布插件配置。适用于创建新 starter、标准化已有 starter 的 pom.xml、核对分支版本矩阵、执行 tag 发布与版本滚动。触发词：starter 开发、pom 标准化、分支版本、tag 发布、版本滚动、spring boot starter 模板。
---

# spring-boot-starter-patterns

easy4j 组织 Spring Boot Starter 的「标准 POM 结构 + 十分支版本矩阵 + 月度日期版本」开发体系。

权威模板：`openclaw-spring-boot-starter/pom.xml`（2.7.x 分支，用户手动调整版）。

## 1. POM 结构模板（铁律）

### 1.1 元素顺序（严格遵守）

```
<project>
├── <modelVersion>4.0.0</modelVersion>
├── <parent>                          # spring-boot-starter-parent（版本按分支矩阵）
├── 坐标                               # groupId / artifactId / version / packaging
├── <name> / <description> / <url>    # name 用 ${project.groupId}:${project.artifactId}
├── <properties>                      # 三段式分类（见 1.2）
├── <dependencyManagement>            # BOM 导入 + 版本管理
├── <dependencies>                    # 实际依赖（带 <!-- For Xxx --> 注释）
├── <distributionManagement>          # 完整：release + snapshot 双仓库
├── <build>                           # 完整：pluginManagement + plugins（见 1.3）
└── <profiles>                        # 完整：disable-javadoc-doclint + release（见 1.4）
```

不包含：`licenses`、`scm`、`developers`、`repositories`（模板未采用；如需发布 Maven Central 的元数据在 release profile 中处理）。

### 1.2 properties 三段式分类 + 自然排序

```xml
<properties>
    <!-- 第一段：基础属性（自然排序） -->
    <java.version>8</java.version>                     <!-- 按分支矩阵；用 8 不用 1.8 -->
    <maven.compiler.source>${java.version}</maven.compiler.source>
    <maven.compiler.target>${java.version}</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <!-- 第二段：Third-Party Dependencies（自然排序） -->
    <commons-io.version>2.22.0</commons-io.version>
    <openclaw-java-sdk.version>1.0.x.20260630-SNAPSHOT</openclaw-java-sdk.version>
    <okhttp.version>4.12.0</okhttp.version>
    <slf4j.version>2.0.18</slf4j.version>
    <!-- 第三段：Maven Plugin Dependencies（自然排序） -->
    <maven-antrun-plugin.version>3.1.0</maven-antrun-plugin.version>
    <maven-central-publishing-plugin.version>0.11.0</maven-central-publishing-plugin.version>
    <maven-clean-plugin.version>3.5.0</maven-clean-plugin.version>
    <maven-compiler-plugin.version>3.15.0</maven-compiler-plugin.version>
    <maven-dependency-plugin.version>3.8.0</maven-dependency-plugin.version>
    <maven-deploy-plugin.version>3.1.4</maven-deploy-plugin.version>
    <maven-enforcer-plugin.version>3.6.3</maven-enforcer-plugin.version>
    <maven-failsafe-plugin.version>3.0.0</maven-failsafe-plugin.version>
    <maven-gpg-plugin.version>3.2.8</maven-gpg-plugin.version>
    <maven-help-plugin.version>3.5.0</maven-help-plugin.version>
    <maven-install-plugin.version>3.1.4</maven-install-plugin.version>
    <maven-invoker-plugin.version>3.8.0</maven-invoker-plugin.version>
    <maven-jacoco-plugin.version>0.8.15</maven-jacoco-plugin.version>
    <maven-jar-plugin.version>3.5.0</maven-jar-plugin.version>
    <maven-javadoc-plugin.version>3.11.2</maven-javadoc-plugin.version>
    <maven-nexus-staging-plugin.version>1.7.0</maven-nexus-staging-plugin.version>
    <maven-release-plugin.version>3.3.1</maven-release-plugin.version>
    <maven-resources-plugin.version>3.5.0</maven-resources-plugin.version>
    <maven-shade-plugin.version>3.6.0</maven-shade-plugin.version>
    <maven-source-plugin.version>3.4.0</maven-source-plugin.version>
    <maven-surefire-plugin.version>3.5.2</maven-surefire-plugin.version>
    <maven-war-plugin.version>3.4.0</maven-war-plugin.version>
</properties>
```

排序规则：`maven-central-publishing` 排在 `maven-clean` 前（按 c-e-n < c-l 字典序）；实际执行 `sorted()` 自然排序即可。

### 1.3 build 完整结构

**pluginManagement**（11 个插件，带版本+完整配置）：
1. `maven-compiler-plugin` — source/target + encoding + maxmem 512M + `annotationProcessorPaths`（lombok，若项目无 lombok 依赖则删除该块）
2. `maven-enforcer-plugin` — requireMavenVersion + requireJavaVersion（CDATA 消息）
3. `maven-gpg-plugin` — sign-artifacts @ verify
4. `maven-resources-plugin` — encoding
5. `maven-release-plugin` — tagNameFormat v@{version} + releaseProfiles release
6. `maven-source-plugin` — jar-no-fork
7. `maven-surefire-plugin` — `skip=false` + `skipTests=false` + `argLine ${argLine} -Xmx1024m -Dfile.encoding=UTF-8`（`${argLine}` 为 JaCoCo agent 注入点，不可省略）+ includes `**/*Test.java` 和 `**/*_Test.java` + exclude `**/TestBean.java`
8. `maven-jar-plugin` — skipIfEmpty + manifest 双 entries
9. `maven-javadoc-plugin` — charset/encoding/docencoding + attach-javadocs @ package
10. `nexus-staging-maven-plugin` — ossrh + autoReleaseAfterClose
11. `central-publishing-maven-plugin`（org.sonatype.central）— `publishingServerId central`

**plugins**（9 个引用 + jacoco）：
1. `jacoco-maven-plugin`（唯一带完整配置的）：prepare-agent → report @ verify → **check @ verify（BUNDLE LINE COVEREDRATIO ≥ 0.90，haltOnFailure=true）**
2. enforcer / compiler / resources / surefire / jar / source / install / deploy（裸引用，配置全部走 pluginManagement）

### 1.4 profiles 完整结构

- `disable-javadoc-doclint`：jdk [1.8,) 激活，`additionalparam -Xdoclint:none`
- `release`：按序引用 enforcer/compiler/resources/surefire/jar/source/javadoc/install/gpg/deploy/release/nexus-staging/**central-publishing**

### 1.5 distributionManagement

- release 仓库：`2624322-release-6F6h6R` @ packages.aliyun.com
- snapshot 仓库：`2624322-snapshot-3EoOv3` @ packages.aliyun.com，uniqueVersion=true

## 2. 十分支版本矩阵

### 2.1 分支 ↔ Spring Boot ↔ JDK ↔ starter 版本 ↔ SDK 版本

| 分支 | Spring Boot parent | JDK | starter 版本（快照→正式） | 依赖 SDK 版本 |
|------|-------------------|-----|-------------------------|--------------|
| 2.3.x | 2.3.12.RELEASE | 8 | 2.3.x.20260630-SNAPSHOT → 2.3.x.20260630 | 1.0.x 线 |
| 2.7.x | 2.7.18 | 8 | 2.7.x.20260630-SNAPSHOT → 2.7.x.20260630 | 2.0.x 线 |
| 3.0.x | 3.0.13 | 17 | 3.0.x.20260630-SNAPSHOT → 3.0.x.20260630 | 3.0.x 线 |
| 3.1.x | 3.1.12 | 17 | 3.1.x.20260630-SNAPSHOT → 3.1.x.20260630 | 3.1.x 线 |
| 3.2.x | 3.2.12 | 17 | 3.2.x.20260630-SNAPSHOT → 3.2.x.20260630 | 3.2.x 线 |
| 3.3.x | 3.3.13 | 17 | 3.3.x.20260630-SNAPSHOT → 3.3.x.20260630 | 3.3.x 线 |
| 3.4.x | 3.4.13 | 17 | 3.4.x.20260630-SNAPSHOT → 3.4.x.20260630 | 3.4.x 线 |
| 3.5.x | 3.5.16 | 17 | 3.5.x.20260630-SNAPSHOT → 3.5.x.20260630 | 3.5.x 线 |
| 4.0.x | 4.0.7 | 21 | 4.0.x.20260630-SNAPSHOT → 4.0.x.20260630 | 4.0.x 线 |
| 4.1.x | 4.1.0 | 21 | 4.1.x.20260630-SNAPSHOT → 4.1.x.20260630 | 4.1.x 线 |

SDK 仓库（xxx-java-sdk）分支为 `feature/{line}`（feature/1.0.x ~ feature/4.1.x），其 Spring Boot 兼容线与 starter 一一对应（feature/1.0.x ↔ starter 2.3.x 线，feature/2.0.x ↔ starter 2.7.x 线，依次类推）。

### 2.2 版本号格式

- 快照：`{line}.x.{yyyyMMdd}-SNAPSHOT`（如 `2.7.x.20260630-SNAPSHOT`）
- 正式：`{line}.x.{yyyyMMdd}`（如 `2.7.x.20260630`）
- 月度滚动：`20260630-SNAPSHOT` → tag `20260630` → 分支 bump 到 `20260730-SNAPSHOT`

## 3. 十 tag 发布工作流

### 步骤 1：创建 10 个 tag

```bash
# 在各分支上打对应 tag（tag 名 = 目标正式版本号）
git checkout 2.3.x  && git tag 2.3.x.20260630
git checkout 2.7.x  && git tag 2.7.x.20260630
git checkout 3.0.x  && git tag 3.0.x.20260630
git checkout 3.1.x  && git tag 3.1.x.20260630
git checkout 3.2.x  && git tag 3.2.x.20260630
git checkout 3.3.x  && git tag 3.3.x.20260630
git checkout 3.4.x  && git tag 3.4.x.20260630
git checkout 3.5.x  && git tag 3.5.x.20260630
git checkout 4.0.x  && git tag 4.0.x.20260630
git checkout 4.1.x  && git tag 4.1.x.20260630
git push origin --tags
```

tag 前置条件：该分支 pom 的 `<version>` 已从 `-SNAPSHOT` 去除（`mvn versions:set -DremoveSnapshot` 或手工），且依赖的 SDK 同名正式版已发布到 Central。

### 步骤 2：发布 Maven Central

```bash
# 在各 tag 上执行（central-publishing-maven-plugin 已配置）
git checkout 2.3.x.20260630
mvn clean deploy -P release    # release profile：source + javadoc + gpg + central-publishing
# … 依次 10 个 tag
```

顺序依赖：starter 发布前，其依赖的 SDK 线正式版必须先行发布（starter 2.3.x ← SDK 1.0.x；starter 3.0.x ← SDK 3.0.x 线 …）。

### 步骤 3：滚动更新 10 个分支的 SNAPSHOT

```bash
# 各分支：20260630-SNAPSHOT → 20260730-SNAPSHOT（含 pom 自身版本与 SDK 依赖版本）
git checkout 2.3.x && mvn versions:set -DnewVersion=2.3.x.20260730-SNAPSHOT
# 同时更新 <xxx-java-sdk.version>1.0.x.20260730-SNAPSHOT</xxx-java-sdk.version>
git commit -am "chore: bump to 20260730-SNAPSHOT" && git push
# … 依次 10 个分支（1.0→2.0→…→4.1 逐线递增）
```

完整滚动映射（当前周期 20260630 → 20260730）：

| 分支 | 版本更新 | SDK 依赖更新 |
|------|---------|-------------|
| 2.3.x | 1.0.x.20260630-SNAPSHOT → 1.0.x.20260730-SNAPSHOT | 同左 |
| 2.7.x | 2.0.x.20260630-SNAPSHOT → 2.0.x.20260730-SNAPSHOT | 同左 |
| 3.0.x ~ 3.5.x | 3.{0..5}.x.20260630-SNAPSHOT → 3.{0..5}.x.20260730-SNAPSHOT | 同左 |
| 4.0.x / 4.1.x | 4.{0,1}.x.20260630-SNAPSHOT → 4.{0,1}.x.20260730-SNAPSHOT | 同左 |

### 步骤 4：核对 10 个分支的 Spring Boot 版本

按 2.1 矩阵逐分支校验 `<parent><version>`：

| feature 分支（SDK 仓库） | Spring Boot |
|------------------------|-------------|
| feature/1.0.x | 2.3.12.RELEASE |
| feature/2.0.x | 2.7.18 |
| feature/3.0.x | 3.0.13 |
| feature/3.1.x | 3.1.12 |
| feature/3.2.x | 3.2.12 |
| feature/3.3.x | 3.3.13 |
| feature/4.0.x | 4.0.7 |
| feature/3.4.x | 3.4.13 |
| feature/3.5.x | 3.5.16 |
| feature/4.1.x | 4.1.0 |

发现不一致：`mvn versions:update-parent -DparentVersion=[目标]` 或手工修正后提交。

## 4. JDK 兼容性规则（踩坑记录）

| 规则 | 原因 |
|------|------|
| `java.version` 用 `8`，禁用 `1.8` | maven-compiler-plugin 3.15.0 对 `--release 1.8` 报「不支持发行版本 1.8」；`8` 全兼容 |
| JDK 21 编译 target 8-21 全支持 | JDK 26 已移除 release 8；本地编译统一 `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| JDK 22+ 默认禁用注解处理 | 需在 compiler 配置加 `<proc>full</proc>`（或依赖 annotationProcessorPaths 显式声明 lombok） |
| Spring Boot 4.x JDK 21 + lombok | parent 自带 lombok 1.18.44，`${lombok.version}` 引用即可 |
| JDK 17+ 强封装 | surefire 部分项目需追加 `--add-opens` 到 argLine |

## 5. 质量门禁

- **JaCoCo**：BUNDLE 级 LINE 覆盖率 ≥ 0.90，`haltOnFailure=true`（verify 阶段强制）
- **测试约定**：JUnit 5 + AssertJ；surefire includes 同时匹配 `*Test.java` 与 `*_Test.java`
- **Javadoc**：`@author <a href="https://github.com/loong10k">Loong Wan</a>`；英语注释；类级（summary + `<p>` + @author/@since）+ 方法级（@param/@return）
- **代码结构参照**：`okhttp3-spring-boot-starter`（测试范式）、`openclaw-spring-boot-starter`（注释范式）、`hermes-spring-boot-starter`（简洁测试）

## 6. 新建 starter 检查清单

1. 依 1.1-1.5 模板生成 pom.xml（按目标分支填 parent/java.version/坐标）
2. 十分支矩阵：创建 2.3.x ~ 4.1.x 分支并按 2.1 填版本
3. properties 三段式 + 自然排序核对
4. jacoco check 90% 门禁就位
5. 源码三件套：`XxxAutoConfiguration` + `XxxProperties`（@ConfigurationProperties）+ `XxxTemplate`
6. 测试三件套：`XxxAutoConfigurationTest`（ApplicationContextRunner）+ `XxxPropertiesTest` + 模板测试
7. `mvn clean verify` BUILD SUCCESS + All coverage checks met
