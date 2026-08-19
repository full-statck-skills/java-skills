# POM 结构详解（spring-boot-starter-patterns）

> 权威模板：openclaw-spring-boot-starter/pom.xml @2.7.x (b091ee4)；可直接复制的占位符模板见 [assets/pom-template.xml](../assets/pom-template.xml)

## 1. 元素顺序（严格遵守）

```
<project>
├── <modelVersion>4.0.0</modelVersion>
├── <parent>                          # spring-boot-starter-parent（版本按分支矩阵）
├── 坐标                               # groupId / artifactId / version / packaging
├── <name> / <description> / <url>    # name 用 ${project.groupId}:${project.artifactId}
├── <licenses>                        # 开源协议；Central 必需
├── <scm>                             # 源码仓库；Central 必需
├── <developers>                      # 开发者；Central 必需
├── <properties>                      # 三段式（§2）
├── <dependencyManagement>            # BOM 导入 + 版本管理
├── <dependencies>                    # 四组依赖（§4）
├── <distributionManagement>          # release + snapshot 双仓库
├── <build>                           # pluginManagement + plugins（§5）
└── <profiles>                        # doclint + release（§6）
```

## 2. 元数据三段（licenses / scm / developers）

每段配一行中文注释；scm/developers 用 `${project.artifactId}` 参数化：

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

标准化已有 pom 时**保留原值**（developer 可能不同），仅补缺失段落与注释。distributionManagement / build 前加注释：`<!-- 制品发布仓库配置（distributionManagement） -->`、`<!-- 构建配置（Build） -->`。

## 3. properties 三段式 + 自然排序

```xml
<properties>
    <!-- ═══ 第一段：基础属性（自然排序）═══ -->
    <java.version>8</java.version>                     <!-- 按分支矩阵；用 8 禁 1.8 -->
    <maven.compiler.source>${java.version}</maven.compiler.source>
    <maven.compiler.target>${java.version}</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

    <!-- ═══ 第二段：Third-Party Dependencies（自然排序）═══ -->
    <!-- 只放被集成组件及其直接必需依赖版本 -->
    <{component}.version>x.y.z</{component}.version>

    <!-- ═══ 第三段：Maven Plugin Dependencies（自然排序）═══ -->
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

排序按 `sorted()` 字典序（如 `maven-central-publishing` < `maven-clean`，c-e < c-l）。

## 4. dependencies 四组

```
① Spring Boot 必需四件套（所有 starter 一致）
   spring-boot-starter / spring-boot-autoconfigure /
   spring-boot-configuration-processor(optional) / spring-boot-starter-test(test)
② 被集成的外部组件（★ 唯一业务依赖，本 starter 的存在意义）
   例 okhttp / redisson / 自研 SDK
③ 编译期工具（按需）：lombok(provided)
④ 测试增强（按需）：junit-jupiter(test) / slf4j-simple(test)
```

反模式：把 okhttp、commons-io 等通用库复制进每个 starter 当"默认依赖"。

## 5. build 完整结构

### pluginManagement（11 插件，配置全在此）

| # | 插件 | 关键配置 |
|---|------|---------|
| 1 | maven-compiler-plugin | source/target + encoding + maxmem 512M + annotationProcessorPaths（lombok `${lombok.version}`；无 lombok 删） |
| 2 | maven-enforcer-plugin | requireMavenVersion + requireJavaVersion（CDATA 消息） |
| 3 | maven-gpg-plugin | sign-artifacts @ verify |
| 4 | maven-resources-plugin | encoding |
| 5 | maven-release-plugin | tagNameFormat v@{version} + releaseProfiles release |
| 6 | maven-source-plugin | jar-no-fork |
| 7 | maven-surefire-plugin | skip/skipTests=false + **argLine `${argLine} -Xmx1024m -Dfile.encoding=UTF-8`** + includes `**/*Test.java` `**/*_Test.java` + exclude `**/TestBean.java` |
| 8 | maven-jar-plugin | skipIfEmpty + manifest 双 entries |
| 9 | maven-javadoc-plugin | charset/encoding/docencoding + attach-javadocs @ package |
| 10 | nexus-staging-maven-plugin | ossrh + autoReleaseAfterClose（OSSRH 发布） |
| 11 | central-publishing-maven-plugin | publishingServerId central（Central Portal） |

发布渠道二选一或并存；只用其一时删另一个。

### plugins（jacoco 唯一内联完整配置 + 8 裸引用）

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>${maven-jacoco-plugin.version}</version>
    <executions>
        <execution><id>prepare-agent</id><goals><goal>prepare-agent</goal></goals></execution>
        <execution><id>report</id><phase>verify</phase><goals><goal>report</goal></goals></execution>
        <execution>
            <id>check</id><phase>verify</phase><goals><goal>check</goal></goals>
            <configuration>
                <haltOnFailure>true</haltOnFailure>
                <rules><rule><element>BUNDLE</element><limits><limit>
                    <counter>LINE</counter><value>COVEREDRATIO</value><minimum>0.90</minimum>
                </limit></limits></rule></rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

其后：enforcer / compiler / resources / surefire / jar / source / install / deploy 裸引用。

## 6. profiles 完整结构

- `disable-javadoc-doclint`：jdk [1.8,) 激活，`additionalparam -Xdoclint:none`
- `release`：enforcer→compiler→resources→surefire→jar→source→javadoc→install→gpg→deploy→release→nexus-staging→central-publishing

## 7. distributionManagement

```xml
<distributionManagement>
    <repository>
        <id>{release-repo-id}</id><url>{release-repo-url}</url>
        <releases><enabled>true</enabled></releases>
        <snapshots><enabled>false</enabled></snapshots>
    </repository>
    <snapshotRepository>
        <id>{snapshot-repo-id}</id><url>{snapshot-repo-url}</url>
        <releases><enabled>false</enabled></releases>
        <snapshots><enabled>true</enabled></snapshots>
        <uniqueVersion>true</uniqueVersion>
    </snapshotRepository>
</distributionManagement>
```
