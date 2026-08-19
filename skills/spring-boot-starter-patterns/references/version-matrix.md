# 版本矩阵与发布工作流（spring-boot-starter-patterns）

## 1. 十分支版本矩阵

| 分支 | Spring Boot parent | JDK | starter 版本（快照→正式） | 依赖 SDK 线 |
|------|-------------------|-----|-------------------------|------------|
| 2.3.x | 2.3.12.RELEASE | 8 | 2.3.x.{d}-SNAPSHOT → 2.3.x.{d} | 1.0.x 线 |
| 2.7.x | 2.7.18 | 8 | 2.7.x.{d}… | 2.0.x 线 |
| 3.0.x | 3.0.13 | 17 | 3.0.x.{d}… | 3.0.x 线 |
| 3.1.x | 3.1.12 | 17 | 3.1.x.{d}… | 3.1.x 线 |
| 3.2.x | 3.2.12 | 17 | 3.2.x.{d}… | 3.2.x 线 |
| 3.3.x | 3.3.13 | 17 | 3.3.x.{d}… | 3.3.x 线 |
| 3.4.x | 3.4.13 | 17 | 3.4.x.{d}… | 3.4.x 线 |
| 3.5.x | 3.5.16 | 17 | 3.5.x.{d}… | 3.5.x 线 |
| 4.0.x | 4.0.7 | 21 | 4.0.x.{d}… | 4.0.x 线 |
| 4.1.x | 4.1.0 | 21 | 4.1.x.{d}… | 4.1.x 线 |

`{d}` = yyyyMMdd（如 20260630）。分支间源码/测试一致；pom 差异 = SB parent + JDK + 内部 SDK 线版本。

## 2. 十 tag 发布工作流

### 步骤 1：创建 10 个 tag

```bash
git checkout 2.3.x && git tag 2.3.x.20260630
# … 依次 2.7.x、3.0.x ~ 4.1.x（tag 名 = 目标正式版本号）
git push origin --tags
```

前置：分支 `<version>` 已去 `-SNAPSHOT`（`mvn versions:set -DremoveSnapshot`）；依赖的 SDK 同名正式版已发布。

### 步骤 2：发布制品仓库

```bash
git checkout 2.3.x.20260630
mvn clean deploy -P release    # source + javadoc + gpg + 发布插件
# … 依次 10 个 tag
```

依赖顺序：内部 SDK 先行（starter 2.3.x ← SDK 1.0.x 线…），再发 starter。

### 步骤 3：滚动更新 10 个分支 SNAPSHOT

```bash
git checkout 2.3.x
mvn versions:set -DnewVersion=2.3.x.20260730-SNAPSHOT
# 同步更新 <xxx-sdk.version> 为对应线 20260730-SNAPSHOT
git commit -am "chore: bump to 20260730-SNAPSHOT" && git push
# … 依次 10 个分支
```

滚动映射（当期 20260630 → 20260730）：每条线 `{line}.x.20260630-SNAPSHOT → {line}.x.20260730-SNAPSHOT`，SDK 依赖同步。

### 步骤 4：核对 10 个分支 Spring Boot 版本

按 §1 矩阵逐分支校验 `<parent><version>`；不一致用 `mvn versions:update-parent -DparentVersion=[目标]` 修正后提交。

## 3. JDK 兼容性规则（踩坑记录）

| 规则 | 原因 |
|------|------|
| `java.version` 用 `8`，禁 `1.8` | compiler 3.15.0 对 `--release 1.8` 报「不支持发行版本 1.8」；`8` 全兼容 |
| 本地编译统一 JDK 21 | 支持 target 8-21；JDK 26 已移除 release 8。`export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| JDK 22+ 默认禁用注解处理 | compiler 加 `<proc>full</proc>` 或显式 annotationProcessorPaths |
| SB 4.x + lombok | parent 自带 1.18.44，`${lombok.version}` 引用 |
| JDK 17+ 强封装 | 部分项目 surefire 需追加 `--add-opens` |
| SB 4.x API 断层 | javax→jakarta、WebSecurityConfigurerAdapter 移除、DataSourceProperties 包迁移——3.x→4.x 迁移工作量最大 |

## 4. 质量门禁

- JaCoCo：BUNDLE LINE ≥ 0.90，haltOnFailure=true（verify 阶段强制）
- 测试：JUnit 5 + AssertJ；surefire 同匹配 `*Test.java` 与 `*_Test.java`
- Javadoc：`@author <a href="...">Name</a>`（组织规范）；英语；类级+方法级
