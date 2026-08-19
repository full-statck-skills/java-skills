# POM 结构详解（java-component-patterns）

> 权威参照：openclaw-java-sdk/pom.xml；占位符模板见 [assets/pom-template.xml](../assets/pom-template.xml)

## 1. 元素顺序（严格遵守，无 parent）

```
<project>
├── <modelVersion>4.0.0</modelVersion>
├── 坐标（无 <parent>！）             # groupId / artifactId / name / url / description / version / packaging
├── <licenses> / <scm> / <developers>  # Central 必需元数据（§2）
├── <properties>                      # 三段式（§3）
├── <dependencyManagement>            # 外部依赖 + 内部组件线（§4）
├── <dependencies>                    # 四组依赖（§5）
├── <distributionManagement>          # release + snapshot 双仓库
├── <build>                           # pluginManagement + plugins（§6）
└── <profiles>                        # doclint + release（§7）
```

## 2. 元数据三段（与 starter 模板一致）

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
            <roles><role>developer</role></roles>
            <timezone>+8</timezone>
        </developer>
    </developers>
```

## 3. properties 三段式 + 自然排序

```xml
<properties>
    <!-- ═══ 第一段：基础属性（自然排序）═══ -->
    <java.version>1.8</java.version>                          <!-- 1.8/17/21；1.8 全版本兼容（maven-compiler-plugin 3.15.0 + JDK8 下 8 有问题） -->
    <maven.compiler.release>${java.version}</maven.compiler.release>
    <maven.version>3.0</maven.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

    <!-- ═══ 第二段：Dependency versions（自然排序）═══ -->
    <jackson-bom.version>2.18.9</jackson-bom.version>              ← BOM 统一管理（1.0.x: 2.18.9, 2.0.x: 2.22.1, 3.0.x: 3.2.1）
    <okhttp3.version>4.12.0</okhttp3.version>
    <okhttp3-extension.version>1.0.x.20260630-SNAPSHOT</okhttp3-extension.version>  <!-- 内部组件线 -->
    <lombok.version>1.18.46</lombok.version>
    <junit.version>5.11.4</junit.version>
    <slf4j.version>2.0.18</slf4j.version>

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

注释标签用英文（`Dependency versions` / `Maven Plugin versions`，参照 SDK）。

**release vs source/target**：`--release` 同时约束 API，防止误用高版本 JDK API，组件库首选；`java.version` 写 `1.8`（全版本兼容，maven-compiler-plugin 3.15.0 + JDK8 下 `8` 有问题）。

## 4. dependencyManagement

集中声明：**Jackson BOM** + 被集成外部库 + 内部组件线 + 测试库版本：

```xml
<dependencyManagement>
    <dependencies>
        <!-- ★ Jackson BOM（有 Jackson 依赖时必加，置于最前面）★ -->
        <!-- 2.x: com.fasterxml.jackson:jackson-bom -->
        <!-- 3.x: tools.jackson:jackson-bom -->
        <dependency>
            <groupId>com.fasterxml.jackson</groupId>
            <artifactId>jackson-bom</artifactId>
            <version>${jackson-bom.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>{EXTERNAL_GROUP}</groupId>
            <artifactId>{EXTERNAL_ARTIFACT}</artifactId>
            <version>{EXTERNAL_VERSION}</version>
        </dependency>
        <!-- 内部组件（同线）：
        <dependency>
            <groupId>{GROUP_ID}</groupId>
            <artifactId>{INTERNAL_ARTIFACT}</artifactId>
            <version>${{INTERNAL_ARTIFACT}.version}</version>
        </dependency>
        -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Jackson BOM 关键规则

| 规则 | 说明 |
|------|------|
| properties 定义 `jackson-bom.version` | 1.0.x → `2.18.9`，2.0.x → `2.22.1`，3.0.x → `3.2.1` |
| BOM import 置于 dm 最前面 | `<type>pom</type><scope>import</scope>` |
| dependencies 中不写 version | BOM 自动管理所有 Jackson 模块版本 |
| **禁止 dm 中放无 version 的 Jackson 条目** | 无 version 的 dm 条目会遮蔽 BOM import，导致 `dependencies.dependency.version is missing`；必须整体删除 dm 条目（不能只删 version 行） |
| 3.0.x 用 `tools.jackson:jackson-bom` | groupId 从 `com.fasterxml.jackson` 改为 `tools.jackson` |

## 5. dependencies 四组

```
① 被集成的外部组件（本组件封装的目标）
② 内部组件依赖（同线原则；无则删）
③ 编译期工具：lombok(provided, ${lombok.version} 显式版本——无 parent 无人代管)
④ 日志门面 slf4j-api + 测试 junit-jupiter/assertj-core(test)
```

## 6. build 完整结构

### pluginManagement（无 parent → 版本+配置全自管）

| 插件 | 关键配置 |
|------|---------|
| maven-compiler-plugin | **`release=${java.version}`** + encoding + maxmem 512M + annotationProcessorPaths（lombok 显式 `${lombok.version}`；无则删） |
| maven-enforcer-plugin | requireMavenVersion `[${maven.version}.0,)` + requireJavaVersion `[${java.version}.0,)` |
| maven-gpg-plugin | sign-artifacts @ verify |
| maven-resources-plugin | encoding |
| maven-release-plugin | tagNameFormat v@{version} + releaseProfiles release |
| maven-source-plugin | jar-no-fork |
| maven-surefire-plugin | skip/skipTests=false + **argLine `${argLine} -Xmx1024m -Dfile.encoding=UTF-8`** + includes `**/*Test.java` `**/*_Test.java` |
| maven-jar-plugin | skipIfEmpty + manifest 双 entries |
| maven-javadoc-plugin | charset/encoding/docencoding + attach-javadocs @ package |
| maven-install / deploy-plugin | 基础配置 |
| nexus-staging-maven-plugin | ossrh + autoReleaseAfterClose |
| central-publishing-maven-plugin | publishingServerId central |

### plugins

jacoco（唯一内联完整配置：prepare-agent → report → **check BUNDLE LINE ≥0.90 haltOnFailure**）+ enforcer/compiler/resources/surefire/jar/source/install/deploy 裸引用。

## 7. profiles

- `disable-javadoc-doclint`：jdk [1.8,)，`additionalparam -Xdoclint:none`
- `release`：全插件引用链 enforcer→…→central-publishing
