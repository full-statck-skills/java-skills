# 分支模型与发布工作流（java-component-patterns）

## 1. 多 JDK 分支模型

| 分支 | JDK | java.version | Jackson BOM | 定位 |
|------|-----|--------------|-------------|------|
| feature/1.0.x | 8 | 1.8 | 2.18.9 (com.fasterxml.jackson) | 老线（对应下游 starter 2.3.x 线） |
| feature/2.0.x | 17 | 17 | 2.22.1 (com.fasterxml.jackson) | 对应 starter 2.7.x 线 |
| feature/3.0.x ~ 3.5.x | 21 | 21 | 3.2.1 (tools.jackson) | 主力线群（对应 starter 3.x 线） |

版本格式：`{line}.x.{yyyyMMdd}`（正式）+ `-SNAPSHOT`（开发）。

### 源码一致性铁律

分支间 src/、测试、README **逐字节一致**；唯一差异是 pom.xml（java.version + 依赖版本 + 组件自身版本号）。

### 同步方法

```bash
# 在源分支 commit 后，同步到目标分支（不含 pom）
git checkout feature/2.0.x
git checkout feature/1.0.x -- src/ README.md
# 再手工校正 pom 分支特有值：java.version、依赖版本、自身版本号
git commit -am "sync: from feature/1.0.x"
```

`.gitignore`、`maven-wrapper.properties` 等工具文件允许漂移。

## 2. 组件间依赖规范

- 组件可依赖其他内部组件（如 openclaw-java-sdk → okhttp3-extension）
- 版本在 properties 第二段声明：`<okhttp3-extension.version>1.0.x.20260630-SNAPSHOT</okhttp3-extension.version>`
- **同线原则**：feature/1.0.x 只依赖其他组件的 1.0.x 线
- dependencyManagement 集中声明版本，dependencies 引用

### Jackson BOM 版本管理

组件依赖 Jackson 时，**必须用 BOM 统一管理**，禁止每个模块单独写 version：

```xml
<!-- properties 第二段 -->
<jackson-bom.version>2.18.9</jackson-bom.version>  <!-- 按分支选版本 -->

<!-- dependencyManagement 最前面 -->
<dependency>
    <groupId>com.fasterxml.jackson</groupId>     <!-- 2.x -->
    <artifactId>jackson-bom</artifactId>
    <version>${jackson-bom.version}</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>

<!-- dependencies 中不写 version -->
<dependency>
    <groupId>com.fasterxml.jackson</groupId>
    <artifactId>jackson-databind</artifactId>
</dependency>
```

| 分支 | jackson-bom.version | groupId |
|------|---------------------|---------|
| 1.0.x | 2.18.9 | com.fasterxml.jackson |
| 2.0.x | 2.22.1 | com.fasterxml.jackson |
| 3.0.x | 3.2.1 | **tools.jackson** |

**⚠ 铁律**：dependencyManagement 中**禁止放无 version 的 Jackson 条目**——会遮蔽 BOM import，导致 `dependencies.dependency.version is missing`。必须整体删除 dm 条目（不能只删 version 行）。

## 3. tag 发布工作流（5 步）

### 步骤 1：去 SNAPSHOT

```bash
# 各分支
mvn versions:set -DremoveSnapshot
git commit -am "chore: release {line}.x.20260630"
```

### 步骤 2：打 tag

```bash
git checkout feature/1.0.x && git tag 1.0.x.20260630
git push origin --tags
```

### 步骤 3：发布

```bash
git checkout 1.0.x.20260630
mvn clean deploy -P release    # source + javadoc + gpg + central
```

### 步骤 4：依赖顺序

**被依赖的底层组件先发**：

```
okhttp3-extension（底层） → openclaw-java-sdk（中层） → xxx-spring-boot-starter（上层）
```

### 步骤 5：滚动 SNAPSHOT

```bash
git checkout feature/1.0.x
mvn versions:set -DnewVersion=1.0.x.20260730-SNAPSHOT
# 同步 bump 内部依赖版本到 20260730-SNAPSHOT
git commit -am "chore: bump to 20260730-SNAPSHOT" && git push
```

## 4. JDK 兼容规则

| 规则 | 原因 |
|------|------|
| `java.version` 用 `1.8` 禁 `8` | maven-compiler-plugin 3.15.0 + JDK8 下 `--release 8` 有问题；`1.8` 全版本兼容 |
| 本地编译 JDK 21 | 支持 release 8-21；JDK 26 已移除 release 8 |
| release 优于 source/target | API 安全，防误用高版本 JDK API |
| JDK 22+ 注解处理默认禁用 | compiler 加 `<proc>full</proc>` 或显式 annotationProcessorPaths |
| Lombok ≥ 1.18.30 | JDK 21+ 兼容 |
| XML 注释禁 `--` | 注释内双连字符导致 not well-formed |

## 5. 质量门禁

- JaCoCo：BUNDLE LINE ≥ 0.90，haltOnFailure=true
- 测试：JUnit 5 + AssertJ；surefire 匹配 `*Test.java` / `*_Test.java`
- 源码三件套：`XxxClient`（门面）+ `XxxConfig` + 能力域分包（cli/http 等）
- Javadoc：英语；类级 summary + `<p>` + @author/@since
