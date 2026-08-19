# 排障案例集

发布流程中实际踩过的坑与解法。

## 目录
1. [阿里云 409 Conflict](#1-阿里云-409-conflict)
2. [Maven Central 拒绝 SNAPSHOT 依赖](#2-maven-central-拒绝-snapshot-依赖)
3. [nexus-staging 404](#3-nexus-staging-404)
4. [surefire fork VM 崩溃（argLine）](#4-surefire-fork-vm-崩溃argline)
5. [pom 被其他分支污染](#5-pom-被其他分支污染)
6. [JDK 8 语法/依赖兼容](#6-jdk-8-语法依赖兼容)
7. [镜像缺版本](#7-镜像缺版本)
8. [Central 发布卡 20 分钟属正常](#8-central-发布卡-20-分钟属正常)

## 1. 阿里云 409 Conflict

**现象**：`mvn deploy` 到阿里云 release 仓库报 `status code: 409`。

**原因**：该版本之前部分上传过（jar/pom 已在仓库），重新上传被拒。阿里云 Maven 仓库 **API 不支持 DELETE**（返回 405），无法用 curl 清理。

**解法**：到阿里云 Packages 控制台手动删除该版本目录（如 `io/github/easy4j/<artifact>/<version>/`），再重新 deploy。删除前可与用户确认。

## 2. Maven Central 拒绝 SNAPSHOT 依赖

**现象**：central-publishing 上传 bundle 成功，但 deployment 校验失败：
```
Dependencies to SNAPSHOT versions not allowed for dependency: io.github.easy4j:xxx
```

**原因**：Maven Central 的硬规则——正式版制品的传递依赖不允许任何 SNAPSHOT。

**解法**（按优先级）：
1. 先发布依赖组件的正式版（组织内组件走同一套三线发布流程）
2. 临时解耦：把依赖改为 optional / 反射调用 / 内部 String 常量替代（如 SDK 曾用 String 日志级别替代 `HttpLogLevel` 枚举，等依赖正式版发布后再恢复）
3. release pom 中临时移除该依赖，下个版本恢复

## 3. nexus-staging 404

**现象**：`mvn deploy -P release` 报 `Nexus connection problem to URL https://oss.sonatype.org/: 404`。

**原因**：oss.sonatype.org（旧 OSSRH）已停服，nexus-staging-maven-plugin 无法使用。

**解法**：release profile 中把 nexus-staging 替换为：
```xml
<plugin>
    <groupId>org.sonatype.central</groupId>
    <artifactId>central-publishing-maven-plugin</artifactId>
</plugin>
```
pluginManagement 中需有配置：`publishingServerId=central`、`autoPublish=true`。settings.xml 的 `<server><id>central</id>` 已配凭证。注意 release profile 中的插件激活块也要替换（只改 pluginManagement 不生效）。

## 4. surefire fork VM 崩溃（argLine）

**现象**：`ClassNotFoundException: ${argLine}`，fork VM 启动失败。

**原因**：pom 的 surefire 配置引用 `@{argLine}`（jacoco 注入），但 jacoco 未执行时占位符未展开。

**解法**：跑测试加 `-DargLine=""`。另外 pom 常硬编码 `<skipTests>false</skipTests>`，此时 `-DskipTests` 无效，必须用 `-Dmaven.test.skip=true`（跳过编译+执行）。

## 5. pom 被其他分支污染

**现象**：切分支后编译报 `不支持发行版本 1.8`，但 pom 本应是 17。

**原因**：跨分支操作时 `mvn versions:set` 修改了工作区 pom，`git checkout <branch>` 时被未提交改动阻塞（Aborting），实际没切过去；或 pom 被其他分支内容覆盖。

**解法**：
```bash
git status --short            # 发现有 M pom.xml
git checkout -- pom.xml       # 或 git checkout origin/<branch> -- pom.xml
git checkout <branch>
```
三分支操作时，切分支后先 `grep "<java.version>\|<version>" pom.xml | head -3` 验证归属再继续。

## 6. JDK 8 语法/依赖兼容

| 报错 | 解法 |
|------|------|
| 找不到 `Map.of` | JDK 9+ API。`Map<String,Object> m = new HashMap<>(); m.put(k,v);` |
| `Map<String,String>` 传给需要 `Map<String,Object>` 的 API（如 MapPropertySource） | 直接声明为 `Map<String,Object>` |
| Lombok `@Builder` 生成的内部类引用找不到（如 `InputItemBuilder`） | 用全限定 `InputItem.InputItemBuilder`；仍失败检查 annotationProcessorPaths 是否配置了 lombok |
| `okhttp3.extension.logging` 不存在 | okhttp3-extension 依赖缺失，恢复依赖或降级为 String 常量 |

## 7. 镜像缺版本

**现象**：依赖解析失败 `Could not find artifact ... in nexus-central`，且 `-U` 无效。

**原因**：阿里云镜像同步不全。典型案例：jackson 2.22 系列只有 databind/core，annotations 缺 2.22.1（因为 annotations 版本号本就是 `2.22` 无 patch）。

**解法**：
1. 逐一验证依赖的**每个模块**在 `https://maven.aliyun.com/repository/central/...` 返回 200
2. 缺失则降回镜像可用的最高版本（宁可降版本也不要改用户 settings.xml）
3. 长期方案：import BOM，模块版本由 BOM 对齐

## 8. Central 发布卡 20 分钟属正常

central-publishing 的 `waitUntil=published` 会阻塞等待 Sonatype 校验+同步，单分支 5~20 分钟正常。期间输出 `Waiting until Deployment xxx is published`，勿中断。可用后台任务执行并轮询。
