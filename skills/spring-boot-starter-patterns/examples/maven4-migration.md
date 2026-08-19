# 示例：mycache-spring-boot-starter 迁移 Maven 4（双轨）

> 前置阅读：[references/maven4.md](../references/maven4.md)。本示例演示十分支 starter 仓库从纯 Maven 3 迁移到 M3/M4 双轨，再按需启用 4.1.0 新特性。

## 场景现状

- 十分支（2.3.x~4.1.x）starter，模板标准 pom（model 4.0.0）
- 本地/CI 用 Maven 3.9.16 + JDK 21
- `mvn clean verify` 142 类似项目已通过；发布走 `-P release`（source+javadoc+gpg+central-publishing）

## Step 1：确认插件兼容（零改动结论）

对照 maven4.md §2.1 矩阵：

| 插件 | 当前版本 | M4 基线 | 结论 |
|------|---------|---------|------|
| maven-compiler-plugin | 3.15.0 | ≥3.13 | ✅ |
| maven-surefire-plugin | 3.5.2 | ≥3.2 | ✅ |
| jacoco | 0.8.15 | ≥0.8.11 | ✅ |
| maven-enforcer | 3.6.3 | ≥3.4 | ✅ |
| central-publishing | 0.11.0 | ≥0.6 | ✅ |

**无需改任何插件版本。**

## Step 2：enforcer 双轨区间（唯一必改）

现状（properties + pluginManagement enforcer）：

```xml
<properties>
    <maven.version>3.0</maven.version>   <!-- 单代检查 -->
</properties>
```

改为双轨：

```xml
<properties>
    <maven.version>3.6.3</maven.version>
</properties>
```

enforcer 的 requireMavenVersion 区间显式放行两代：

```xml
<requireMavenVersion>
    <message>Requires Maven 3.6.3+ (incl. Maven 4).</message>
    <version>[3.6.3,)</version>   <!-- 4.x ≥3.6.3 自然通过；若要排除某代用集合区间 -->
</requireMavenVersion>
```

若要**强制仅 M4**（某分支单轨化）：

```xml
<version>[4.0.0,)</version>
```

## Step 3：wrapper 切 4.x（可选，团队统一）

`.mvn/wrapper/maven-wrapper.properties`：

```diff
- distributionUrl=.../apache-maven-3.9.16-bin.zip
+ distributionUrl=.../apache-maven-4.0.0-rc/apache-maven-4.0.0-rc-bin.zip
```

团队统一 `./mvnw clean verify`（锁定版本，消除本地 mvn 差异）。

## Step 4：本地验证（M4 + JDK 21）

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)   # M4 运行要求 JDK 17+
mvn -version        # Apache Maven 4.x / Java 21
mvn clean verify
# 期望：BUILD SUCCESS + All coverage checks have been met
#      —— release 8 的 2.3.x 分支同样可构建（javac 21 --release 8）
```

常见报错对照：

| 症状 | 处置 |
|------|------|
| `requires JDK 17` | JAVA_HOME 指错（还停在 8）→ 切 21 |
| enforcer `Detected Maven Version... ` | 区间没放行该代 → Step 2 |
| 老 wrapper 脚本不识别 | `mvn wrapper:wrapper -Dmaven=4.0.0` 重新生成 |

## Step 5：验证 Consumer POM 发布产物

```bash
mvn deploy -P release -DaltDeploymentRepository=local::file:///tmp/repo
# 检查 /tmp/repo 中的 *.pom：
#   无 <build>/<pluginManagement>/<profiles>（自动扁平化）
#   依赖与 scm/licenses/developers 完整
```

曾用 maven-flatten-plugin 的 → 本步验证后**移除该插件**（原生替代）。

## Step 6：CI 双轨矩阵

```yaml
strategy:
  matrix:
    maven: ['3.9.16', '4.0.0-rc']
steps:
  - uses: actions/setup-java@v4
    with: { java-version: '21', distribution: temurin }
  - run: mvn -version && mvn clean verify
```

双轨全绿后，可将默认分支（4.1.x）单轨切 M4、老分支保留 M3 兜底。

## Step 7（可选）：某分支启用 model 4.1.0

仅当确实需要 session scope（如「构建期工具依赖不泄漏给消费者」）：

```xml
<project xmlns="http://maven.apache.org/POM/4.1.0" ...>
    <modelVersion>4.1.0</modelVersion>
    ...
    <dependency>
        <groupId>org.example</groupId>
        <artifactId>build-only-tool</artifactId>
        <scope>session</scope>   <!-- M4 新特性；M3 不识别 -->
    </dependency>
```

⚠️ 升级后该分支**仅 Maven 4 可构建**——除非确定放弃 M3 兜底，否则保持 4.0.0。

## 迁移核对清单

- [ ] 插件版本对照矩阵（§2.1）——预期零改动
- [ ] maven.version 基线 + enforcer 区间（双轨或按分支单轨）
- [ ] JAVA_HOME ≥ 17（CI 与本地）
- [ ] wrapper distributionUrl（若统一 mvnw）
- [ ] `mvn clean verify` 在 M4 下通过（含 release 8 老分支）
- [ ] deploy 后 consumer POM 形态验证；移除 flatten（若曾用）
- [ ] CI matrix 双轨全绿
- [ ] model 4.1.0 仅在需要 session scope 时启用（接受单 M4 约束）
