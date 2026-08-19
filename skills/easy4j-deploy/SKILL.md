---
name: easy4j-deploy
description: easy4j 组织标准发布流程与多分支 Maven 发布规范。适用于 io.github.easy4j 仓库（如 openclaw-java-sdk、okhttp3-extension 及其他 easy-4-java 组织组件）的以下场景：(1) SDK 三分支正式版发布（标准流程：创建 tag → 发布 Maven Central → bump SNAPSHOT，支持子智能体并行编排），(1b) xxx-spring-boot-starter 十分支发布（依赖 SDK 先转正式版 + tag + Central + bump），(2) 发布阿里云私有库 SNAPSHOT，(3) 三分支（feature/1.0.x JDK 8、feature/2.0.x JDK 17、feature/3.0.x JDK 21）源码同步，(4) 发布前 CVE 扫描与依赖升级（Jackson BOM 版本控制规则、JDK 依赖天花板），(5) 发布故障排查（409 冲突、Central 拒绝 SNAPSHOT 依赖、argLine 问题）。触发词：发布、上线、deploy、release、发版、发布正式版、同步分支、版本号升级。
---

# easy4j-deploy

easy4j 组织的「单源码、三 JDK 线、月度日期版本」发布体系。

## 1. 分支模型（铁律）

### 1.1 SDK 仓库（feature/X.0.x，3 分支）

| 分支 | JDK | 定位 |
|------|-----|------|
| `feature/1.0.x` | 8 | 老项目兼容线 |
| `feature/2.0.x` | 17 | 主线 |
| `feature/3.0.x` | 21 | 新特性线 |

**源码一致性铁律**：三分支的源码、测试、README 逐字节一致；唯一允许的差异是 `pom.xml`（JDK 版本 + 依赖版本）。`.gitignore`、`maven-wrapper.properties` 等工具文件允许漂移。

**同步方法**：在源分支 commit 后，用 `git checkout <source> -- src/ README.md`（不含 pom.xml）到目标分支，再手工校正 pom 中分支特有版本（java.version、okhttp3/jackson 等依赖版本、artifact 自身版本号）。

### 1.2 Starter 仓库（xxx-spring-boot-starter，10 分支）

分支对应 Spring Boot 版本线：`2.3.x、2.7.x、3.0.x、3.1.x、3.2.x、3.3.x、3.4.x、3.5.x、4.0.x、4.1.x`（分支名以仓库实际为准——openclaw-spring-boot-starter 为裸版本号分支；若仓库带 `feature/` 前缀则相应调整。执行前先 `git branch --list` 枚举确认）。Starter 源码在各分支间保持一致，pom 差异 = Spring Boot parent 版本 + JDK + 依赖的 SDK 线版本。

## 2. 版本号规范

- 格式：`{major}.0.x.{yyyyMMdd}`（正式版），加 `-SNAPSHOT` 后缀为开发版
- 日期后缀按月推进：发布 `20260630` → 分支立即升 `20260730-SNAPSHOT`（+1 个月，取月末）
- Tag 名 = 正式版本号（如 `2.0.x.20260630`），打在 release commit 上

## 3. SDK 发布流程（三分支正式版）

### 3.1 发布规则（必守原文）

1. **创建 3 个 tag**：`/tags/1.0.x.{日期}`、`/tags/2.0.x.{日期}`、`/tags/3.0.x.{日期}`
   - 分支快照 `1.0.x.{日期}-SNAPSHOT` → 发布正式版本号 `1.0.x.{日期}`（三分支同理）
2. **基于 3 个 tag 发布 Maven 中心仓库**
3. **更新 3 个分支（feature/1.0.x、feature/2.0.x、feature/3.0.x）的版本号**：
   - `X.0.x.{本月日期}-SNAPSHOT` → `X.0.x.{下月日期}-SNAPSHOT`（如 `20260630-SNAPSHOT` → `20260730-SNAPSHOT`）
4. **Jackson 依赖版本控制**：见 5.1 BOM 规则

日期参数由用户发布指令给出；未给出时从当前分支 SNAPSHOT 版本推导（本月日期即当前日期后缀，下月日期 = +1 个月取月末）。

### 3.2 编排：子智能体并行执行

用户要求"发布 3 个分支正式版"时：

1. **主线程先跑门禁**（第 6 节）：CVE 扫描 × 3 分支、测试 × 3 分支、一致性 diff——任一失败先修复
2. **获得用户明确授权**（发布不可逆）
3. **用 Agent 工具派 3 个子智能体并行**，每分支一个。Central 校验耗时 5~20 分钟/分支，并行可把总时长压缩到最慢一个分支
4. 子智能体提示词必须**自包含**：仓库绝对路径、分支名、发布日期、下月日期、JDK 路径、完整命令序列、失败时的中止条件（不得自行重试 deploy）。可直接让子智能体执行 `scripts/release-sdk.sh`（SDK）或 `scripts/release-starter.sh`（starter）
5. 三个子智能体全部成功后，主线程汇总报告（版本/tag/URL 矩阵）

### 3.3 单分支执行序列（子智能体或脚本执行）

```
修改代码 → commit 到对应分支（如有待发布改动）
→ 在分支去 SNAPSHOT：X.0.x.{日期}-SNAPSHOT → X.0.x.{日期}
→ mvn clean deploy -P release -DskipTests        （发布 Maven Central，JDK 须匹配分支）
→ 推 tag：git tag -a X.0.x.{日期} && git push origin X.0.x.{日期}
→ bump SNAPSHOT：X.0.x.{下月日期}-SNAPSHOT
→ 推分支：git push origin feature/X.0.x
```

详细命令：

```bash
# 去 SNAPSHOT
mvn versions:set -DnewVersion={major}.0.x.{日期} -DgenerateBackupPoms=false
git add pom.xml && git commit -m "chore(release): bump version to {major}.0.x.{日期}"

# 发布 Maven Central（JDK 必须与分支匹配）
JAVA_HOME=<分支对应JDK> mvn clean deploy -P release -DskipTests

# 打 tag 并推送
git tag -a {major}.0.x.{日期} -m "Release {major}.0.x.{日期}"
git push origin {major}.0.x.{日期}

# bump 到下月 SNAPSHOT
mvn versions:set -DnewVersion={major}.0.x.{下月日期}-SNAPSHOT -DgenerateBackupPoms=false
git add pom.xml && git commit -m "chore: bump version to {major}.0.x.{下月日期}-SNAPSHOT"
git push origin feature/{major}.0.x
```

**JDK 解析**（发布脚本自动执行，无需配置绝对路径）：
- 优先级：`EASY4J_JDK_HOME` 环境变量 → macOS `/usr/libexec/java_home -v <8|17|21>` → 解析失败中止并提示
- 也可在外层直接 `export JAVA_HOME` 指定匹配版本

一键脚本：`scripts/release-sdk.sh feature/2.0.x 20260630 20260730`（即上述序列；内置分支白名单与 starter 仓库守卫，执行前须向用户确认）。

发布通道：
- **Maven Central**：release profile 用 `central-publishing-maven-plugin`（`publishingServerId=central`，settings.xml 已有凭证），GPG 签名自动执行。`nexus-staging` 已废弃（oss.sonatype.org 已死，报 404）
- **阿里云 SNAPSHOT**：`mvn clean deploy -Dmaven.test.skip=true` 直发 `2624322-snapshot-3eoov3`，无需 release profile

### 3.4 Jackson 依赖版本控制（发布规则第 4 条）

见 [5.1 Jackson BOM 规则](#51-jackson-bom-规则发布规则第-4-条)。

## 4. Starter 发布流程（xxx-spring-boot-starter，10 分支正式版）

适用于 `xxx-spring-boot-starter` 仓库（如 openclaw-spring-boot-starter）。**必须在对应 SDK 正式版发布完成之后执行**。

### 4.1 前置条件：依赖 SDK / extension 先转正式版

starter 各分支 pom 中依赖的 `xxx-java-sdk` / `xxx-extension` 版本属性，发布前从 SNAPSHOT 更新为正式版（Maven Central 拒绝 SNAPSHOT 传递依赖，此步不可跳过）：

- `1.0.x.{日期}-SNAPSHOT` → `1.0.x.{日期}`（供 2.3.x / 2.7.x，JDK 8）
- `2.0.x.{日期}-SNAPSHOT` → `2.0.x.{日期}`（供 3.x 线，JDK 17）
- `3.0.x.{日期}-SNAPSHOT` → `3.0.x.{日期}`（供 4.0.x / 4.1.x）

依赖线与 starter 分支的实际对应以 pom 中 `<xxx-java-sdk.version>` 当前值为准（由 JDK 天花板决定）。发布后 bump 自身 SNAPSHOT 时，**依赖保持正式版**，下个集成周期再按需切回 SNAPSHOT。

### 4.2 发布规则（必守原文）

1. **创建 10 个 tag**：`/tags/2.3.x.{日期}`、`/tags/2.7.x.{日期}`、`/tags/3.0.x.{日期}`、`/tags/3.1.x.{日期}`、`/tags/3.2.x.{日期}`、`/tags/3.3.x.{日期}`、`/tags/3.4.x.{日期}`、`/tags/3.5.x.{日期}`、`/tags/4.0.x.{日期}`、`/tags/4.1.x.{日期}`
   - 各分支快照 `X.Y.x.{日期}-SNAPSHOT` → 发布正式版本号 `X.Y.x.{日期}`
2. **基于 10 个 tag 发布 Maven 中心仓库**
3. **更新 10 个分支的版本号**：`X.Y.x.{本月日期}-SNAPSHOT` → `X.Y.x.{下月日期}-SNAPSHOT`（如 `2.7.x.20260630-SNAPSHOT` → `2.7.x.20260730-SNAPSHOT`）

### 4.3 Starter 分支 × JDK × Spring Boot 矩阵

| 分支 | Spring Boot | 自身 java.version | 构建 JDK | 依赖 SDK 线（典型） |
|------|-------------|------------------|---------|------------------|
| 2.3.x | 2.3.12.RELEASE | 1.8 | 8 | 1.0.x |
| 2.7.x | 2.7.18 | 1.8 | 8 | 1.0.x |
| 3.0.x | 3.0.13 | 17 | 17 | 2.0.x |
| 3.1.x | 3.1.12 | 17 | 17 | 2.0.x |
| 3.2.x | 3.2.12 | 17 | 17 | 2.0.x |
| 3.3.x | 3.3.13 | 17 | 17 | 2.0.x |
| 3.4.x | 3.4.13 | 17 | 17 | 2.0.x |
| 3.5.x | 3.5.9 | 17 | 17 | 2.0.x |
| 4.0.x | 4.0.x | 17 | **21**（见下） | 3.0.x |
| 4.1.x | 4.1.x | 17 | **21**（见下） | 3.0.x |

⚠️ **关键坑**：starter 自身 `java.version=17` 但依赖 SDK 3.0.x（Java 21 字节码）时，**构建必须用 JDK 21**，否则编译报「无法访问 io.github.easy4j.xxx」。构建 JDK 取 `max(自身 java.version, SDK 依赖线字节码版本)`。

### 4.4 编排：10 个子智能体并行 + 发布前漏洞检查

同 3.2 模式，但发布前需逐分支做 **CVE 扫描，在对应 JDK 允许的情况下修复漏洞**（starter 的传递依赖多来自 Spring Boot parent，重点扫自身 properties 声明的依赖与 SDK 线版本）。之后派 10 个子智能体并行，每分支执行序列：

```
依赖转正式版（pom 属性去 -SNAPSHOT）→ commit
→ 去 SNAPSHOT（自身版本 X.Y.x.{日期}）
→ mvn clean deploy -P release -DskipTests   （JDK 按 4.3 矩阵）
→ 推 tag：git tag -a X.Y.x.{日期} && git push origin X.Y.x.{日期}
→ bump 自身 SNAPSHOT：X.Y.x.{下月日期}-SNAPSHOT（依赖保持正式版）
→ 推分支
```

一键脚本：`scripts/release-starter.sh 2.7.x 20260630 20260730 <starter仓库路径>`（自动处理依赖转正式版；JDK 取 max(自身 java.version, 全部依赖线)；内置分支白名单与仓库类型守卫）。

## 5. 依赖管理规范

### 5.1 Jackson BOM 规则（发布规则第 4 条）

三分支的 Jackson 版本控制方式（**依赖 Jackson 的仓库必守**）：

1. properties 中定义 `jackson-bom.version`
2. dependencyManagement 中依赖（import）对应 BOM
3. dependencies 中直接使用对应组件（**不带 version**）

| 分支 | properties | dependencyManagement import |
|------|-----------|---------------------------|
| 1.0.x | `jackson-bom.version=2.18.9` | `com.fasterxml.jackson:jackson-bom:${jackson-bom.version}` |
| 2.0.x | `jackson-bom.version=2.22.1` | `com.fasterxml.jackson:jackson-bom:${jackson-bom.version}` |
| 3.0.x | `jackson-bom.version=3.2.1` | `tools.jackson:jackson-bom:${jackson-bom.version}`（groupId 已换！） |

### 5.2 JDK 依赖天花板

| 组件 | JDK 8 上限 | 原因 |
|------|-----------|------|
| jackson | 2.18.9 | 2.19+ 要求 JDK 11+ |
| okhttp | 4.12.0 | 5.x 要求 JDK 11+ |
| junit-jupiter | 5.11.4 | 6.x 要求 JDK 17+ |
| commons-exec / slf4j / lombok | 1.6.0 / 2.0.18 / 1.18.46 | 全线通用 |

升级原则：**在对应 JDK 允许的范围内升到最高无 CVE 版本**。完整矩阵、Jackson 3.x 迁移 API 对照表见 [references/dependency-matrix.md](references/dependency-matrix.md)。

### 5.3 自家组件对齐

组织内组件（如 okhttp3-extension）按同样规则发三线版本 `1.0.x / 2.0.x / 3.0.x.{日期}`，与 SDK 分支一一对应。被依赖方必须**先发正式版**——Maven Central 拒绝任何 SNAPSHOT 传递依赖。

## 6. 发布前门禁

1. **CVE 扫描**：`scripts/cve-scan.sh <分支> <仓库路径>`（OSV API，扫 pom 全部依赖；SDK × 3 分支，starter × 10 分支）。发现 CVE 在 JDK 天花板内升级修复后重扫
2. **测试**：三分支测试全绿。surefire 被 jacoco 的 `${argLine}` 卡死时加 `-DargLine=""`；pom 硬编码 `skipTests=false` 时用 `-Dmaven.test.skip=true`（`-DskipTests` 无效）
3. **分支一致性**：`git diff feature/2.0.x feature/{1,3}.0.x --stat` 应只剩 pom.xml

## 7. 坐标规范

| 项目 | 值 |
|------|-----|
| groupId | `io.github.easy4j` |
| Java 包 | `io.github.easy4j.*`（与 groupId 对齐） |
| 仓库 URL | `github.com/easy-4-java/{artifactId}` |
| developer | 保留 `hiwepy / hiwepy@gmail.com`（个人身份不随组织迁移） |

## 8. 排障速查

| 症状 | 处理 |
|------|------|
| 阿里云 deploy 409 | release 仓库有残留版本，需控制台手动删该版本目录（API 不支持 DELETE） |
| Central 报 "Dependencies to SNAPSHOT versions not allowed" | 传递依赖含 SNAPSHOT，先发依赖正式版或解耦该依赖 |
| nexus-staging 连 oss.sonatype.org 404 | 已废弃，release profile 换 `central-publishing-maven-plugin` |
| BOM import 后报 `version is missing` | dm 中残留无版本 jackson 条目会**遮蔽** BOM——把 dm 中纯版本管理的 jackson 条目**整体删除**（不能只删 version 行），dependencies 无版本引用由 BOM 供版 |
| fork VM `${argLine}` 崩溃 | 加 `-DargLine=""` |
| JDK 编译报 "不支持发行版本" | pom 被其他分支污染，`git checkout origin/<branch> -- pom.xml` 恢复后重改版本 |
| JDK 8 找不到 `Map.of` | JDK 9+ API，改 `HashMap` 手工 put |
| 阿里云镜像缺新版 jackson 模块 | 3 个模块（databind/core/annotations）都要验证存在；annotations 版本号常无 patch（如 `2.22` 非 `2.22.1`），用 BOM 可免手工对齐 |

完整案例见 [references/troubleshooting.md](references/troubleshooting.md)。

## 9. 附带脚本

| 脚本 | 适用仓库 | 用途 |
|------|---------|------|
| `scripts/cve-scan.sh <分支> [仓库路径]` | 通用 | 扫 pom 全依赖的 OSV CVE（含 jackson 双坐标防漏报） |
| `scripts/release-sdk.sh <feature/X.0.x> <发布日期> <下月日期> [仓库路径]` | SDK（3 分支） | 去 SNAPSHOT → deploy → tag → bump → push；JDK 按分支白名单固定 |
| `scripts/release-starter.sh <X.Y.x> <发布日期> <下月日期> [仓库路径]` | Starter（10 分支） | 多一步依赖转正式版；JDK 自动推断 max(自身版本, 依赖线) |

两个 release 脚本均带：分支白名单（拒绝未知分支）、仓库类型守卫（SDK/starter 互斥，防混跑）、`DRY_RUN=1` 演练模式、`EASY4J_JDK_HOME` 覆盖。

发布是不可逆对外操作：执行 `release.sh` 或 Central deploy 前**必须获得用户明确确认**。
