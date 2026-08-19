# 示例：mylib-java-sdk 迁移 Maven 4（含 flatten 移除与 4.1.0）

> 前置阅读：[references/maven4.md](../references/maven4.md)。组件（无 parent）迁移演练，重点：flatten 原生替代、内部依赖线在 consumer POM 下的形态、session scope 升级判断。

## 场景现状

- 多分支组件（feature/1.0.x~4.1.x，JDK 8/17/21），无 parent，插件版本全自管
- 曾加 maven-flatten-plugin 解决 CI Friendly 版本（`${revision}`）泄漏
- 依赖内部组件线（如 okhttp3-extension 同线 SNAPSHOT）
- 发布 `-P release`（gpg + central-publishing）

## Step 1：插件兼容核对（自管清单逐项）

无 parent → 插件版本全在本仓库 properties 第三段，逐项对照 maven4.md §2.1：

| 插件 | 组件现状 | M4 基线 | 动作 |
|------|---------|---------|------|
| maven-compiler-plugin | 3.15.0 | ≥3.13 | 无 |
| maven-surefire-plugin | 3.5.2 | ≥3.2 | 无 |
| jacoco | 0.8.15 | ≥0.8.11 | 无 |
| maven-enforcer | 3.6.3 | ≥3.4 | 无 |
| central-publishing | 0.11.0 | ≥0.6 | 无 |
| **maven-flatten-plugin** | 旧版 | — | **Step 3 移除** |

## Step 2：enforcer 基线双轨

```xml
<maven.version>3.6.3</maven.version>
...
<requireMavenVersion>
    <version>[3.6.3,)</version>   <!-- M3/M4 双轨 -->
</requireJavaVersion>
    <version>[${java.version}.0,) <!-- 8/17/21 按分支不变 -->
```

注意：`${java.version}` 检查的是**构建 JDK**；Maven 4 自身要求 JDK 17+ 运行——release 8 分支用「M4 + JDK21 运行 + release 8 编译」依旧成立。

## Step 3：移除 flatten（核心收益）

删除：

```xml
<!-- 从 pluginManagement 与 plugins 中整体移除 -->
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>flatten-maven-plugin</artifactId>
    ...
</plugin>
```

Maven 4 原生 consumer POM 覆盖原 flatten 场景：

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
mvn deploy -P release -DaltDeploymentRepository=local::file:///tmp/repo
```

验证 `/tmp/repo/**/mylib-java-sdk-*.pom`：

- [ ] `${revision}` 等 CI Friendly 属性已解析为字面量
- [ ] 无 build/pluginManagement/profiles（构建态剥离）
- [ ] 内部依赖（okhttp3-extension 同线版本）完整保留
- [ ] licenses/scm/developers 完整（Central 要求）

## Step 4：三分支验证矩阵

| 分支 | 构建 | 期望 |
|------|------|------|
| feature/1.0.x（release 8） | M4 + JDK21 运行 | verify ✅ |
| feature/3.5.x（release 17） | M4 + JDK21 | verify ✅ |
| feature/4.1.x（release 21） | M4 + JDK21 | verify ✅ |

```bash
for b in feature/1.0.x feature/2.0.x feature/3.0.x feature/3.5.x feature/4.1.x; do
  git checkout $b -q
  mvn clean verify -q && echo "✅ $b" || echo "❌ $b"
done
```

## Step 5：CI 双轨 + tag 发布演练

```yaml
matrix: { maven: ['3.9.16', '4.0.0-rc'] }   # 双轨
```

发布顺序不变（底层先发）：

```bash
# 组件正式版先行（被 starter 依赖）
mvn versions:set -DremoveSnapshot
git tag 3.0.x.20260630 && git push --tags
git checkout 3.0.x.20260630 && mvn clean deploy -P release
# 然后才轮到 xxx-spring-boot-starter 同名版本
```

## Step 6（可选）：评估 model 4.1.0 升级

判断题：本组件是否需要**构建期专用依赖且不希望泄漏给下游**？

- 是（如构建期注解处理器、内部代码生成器）→ 升级 4.1.0：

```xml
<project xmlns="http://maven.apache.org/POM/4.1.0" ...>
    <modelVersion>4.1.0</modelVersion>
    <dependencies>
        <dependency>
            <groupId>org.example</groupId>
            <artifactId>internal-codegen</artifactId>
            <scope>session</scope>   <!-- 不进 consumer POM、不传递 -->
        </dependency>
    </dependencies>
```

- 否（大多数组件）→ **保持 4.0.0**：M3/M4 双轨 + 下游（含 starter 与终端用户）最大兼容

⚠️ 升 4.1.0 后该分支 M3 报 model 不识别；需同步通知所有下游与 CI。

## 迁移核对清单

- [ ] properties 第三段插件逐项对照 M4 基线（无 parent 全自管）
- [ ] enforcer 双轨区间；java.version 按分支不变
- [ ] 移除 flatten 后 consumer POM 验证（revision 解析/内部依赖/元数据完整）
- [ ] 全分支 M4 verify 通过（含 release 8 老线）
- [ ] CI 双轨矩阵绿
- [ ] tag 发布顺序：组件先发 → starter 后发
- [ ] 4.1.0 升级仅限确需 session scope；否则保持 4.0.0
