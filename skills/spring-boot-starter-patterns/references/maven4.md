# Maven 4 适配指南

> 适用：spring-boot-starter-patterns 与 java-component-patterns 共用的 Maven 4 双轨支持。POM model 沿用 4.0.0，**现有模板 XML 结构不变**；差异在运行时要求、基线声明与发布产物。

## 1. Maven 3 vs Maven 4 关键差异

| 维度 | Maven 3.9.x | Maven 4.x |
|------|-------------|-----------|
| **运行时 JDK** | 8+ | **17+**（硬性要求；即使编译 release 8） |
| POM model | 4.0.0 | 4.0.0（不变） |
| 发布产物 | 原始 POM（构建配置泄漏给消费者） | **Consumer POM**（自动 flattened，更干净） |
| flatten 插件 | 需要 maven-flatten-plugin 手动扁平化 | 原生替代（多数场景可移除 flatten） |
| 增量构建 | 无（全量） | Build Consumer（可选加速） |
| extensions 声明 | `.mvn/extensions.xml` 冗长 | 简化 `{g:a:v}` |
| wrapper | mvnw（3.x distributionUrl） | mvnw（distributionUrl 指向 4.x） |
| 并行构建 | `-T` 显式 | 更智能的 Reactor 调度 |

## 2. 对本模板的实际影响

### 2.1 插件版本——已全部 Maven 4 兼容 ✅

| 插件 | 模板版本 | Maven 4 兼容基线 |
|------|---------|-----------------|
| maven-compiler-plugin | 3.15.0 | ≥3.13 |
| maven-surefire-plugin | 3.5.2 | ≥3.2 |
| jacoco-maven-plugin | 0.8.15 | ≥0.8.11 |
| maven-enforcer-plugin | 3.6.3 | ≥3.4（新规则 API） |
| central-publishing | 0.11.0 | ≥0.6 |
| maven-source/jar/javadoc/release | 模板版本 | 均兼容 |

**结论：模板无需改插件版本即可在 Maven 4 下构建。**

### 2.2 maven.version 基线（唯一必改项）

Maven 3 项目（现状）：

```xml
<maven.version>3.0</maven.version>          <!-- 或 3.6.3 -->
<!-- enforcer: [${maven.version}.0,) 允许 4.x 通过 -->
```

Maven 4 项目（强制 4.x）：

```xml
<maven.version>4.0</maven.version>
<!-- enforcer requireMavenVersion: [4.0.0,) -->
```

双轨兼容（推荐过渡期）：

```xml
<maven.version>3.6.3</maven.version>
<!-- enforcer 用区间显式放行两代：
<requireMavenVersion><version>[3.6.3,4.0),[4.0.0,)</version></requireMavenVersion>
-->
```

> ⚠️ enforcer 的 `version` 支持区间集合 `[3.6.3,4.0),[4.0.0,)`；简单 `${maven.version}.0` 展开只覆盖单代。

### 2.3 JDK 运行矩阵（含 Maven 4）

| 构建 | 运行 JDK | 可编译 release | 说明 |
|------|---------|--------------|------|
| Maven 3.9 + JDK 21 | 21 | 8–21 | **当前标准**（skill §JDK 规则） |
| Maven 4 + JDK 21 | 21 | 8–21 | ✅ 推荐：release 8 老分支照常 |
| Maven 4 + JDK 17 | 17 | 8–17 | Maven 4 最低运行环境 |
| Maven 3.9 + JDK 8 | 8 | 8 | 老环境；compiler 3.15 需注意 |

要点：**Maven 4 不改变 target 矩阵**——2.3.x 线（release 8）依旧可用 Maven 4 构建，只是构建器自身跑在 JDK 17+ 上。

## 3. Wrapper 迁移

`.mvn/wrapper/maven-wrapper.properties`：

```properties
# Maven 3
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.zip

# Maven 4
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/4.0.0-rc/apache-maven-4.0.0-rc-bin.zip
```

团队统一：`./mvnw clean verify`（wrapper 锁版本，避免本地 mvn 差异）。

`.mvn/maven.config`（每行一个参数，Maven 3/4 通用）：

```
-T
1C
```

## 4. Consumer POM（发布变化）

- Maven 4 `install/deploy` 自动生成消费 POM：剥掉构建插件配置、profile 等构建态，只留依赖与元数据
- 收益：下游依赖者看到的 POM 干净；分发体积与歧义减小
- 迁移：
  - 曾用 `maven-flatten-plugin` 的项目 → Maven 4 下**可移除**（原生覆盖）
  - `<scm><tag>HEAD</tag>` 等 CI Friendly 版本场景 → 原生 `revision`/`sha1`/`changelist` 属性在 consumer POM 中正确解析
- 验证发布产物：

```bash
mvn deploy -P release
# 检查仓库中的 *.pom 是否已是扁平化形态（无 build/pluginManagement）
```

## 5. CI 双轨示例

```yaml
# GitHub Actions
strategy:
  matrix:
    maven: [3.9.16, 4.0.0]
steps:
  - uses: actions/setup-java@v4
    with: { java-version: '21', distribution: temurin }
  - uses: stCarolas/setup-maven@v5
    with: { maven-version: ${{ matrix.maven }} }
  - run: mvn clean verify
```

## 6. 迁移检查清单

- [ ] 本地/CI JDK ≥ 17（Maven 4 硬要求）
- [ ] `maven.version` 属性与 enforcer 区间按目标代调整（§2.2）
- [ ] wrapper distributionUrl 切 4.x（或团队统一 mvnw）
- [ ] 移除 maven-flatten-plugin（若曾用；原生 consumer POM 替代）
- [ ] `mvn clean verify` 在 Maven 4 下通过（插件版本已兼容，一般零改动）
- [ ] `mvn deploy -P release` 后检查 Central 上的 consumer POM 形态
- [ ] 特殊 core extensions → 迁到 `.mvn/extensions.xml` 简化格式
