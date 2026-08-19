# 示例：从零新建 xxx-spring-boot-starter

以「mycache-spring-boot-starter（整合 fictional mycache-client）」为例，8 步完成。

## Step 1：复制模板

```bash
cp skills/.../spring-boot-starter-patterns/assets/pom-template.xml mycache-spring-boot-starter/pom.xml
```

替换占位符：`{GROUP_ID}`=io.github.myorg、`{ARTIFACT}`=mycache、`{DESCRIPTION}`=MyCache client、`{ORG}`=myorg、`{DEV_*}`=开发者信息、`{EXTERNAL_GROUP/ARTIFACT/VERSION}`=com.fictional:mycache-client:1.2.0。

## Step 2：按目标分支填矩阵值

以 3.5.x 分支为例（查 version-matrix.md §1）：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.5.16</version>          <!-- 3.5.x 线 -->
    <relativePath/>
</parent>
<version>3.5.x.20260630-SNAPSHOT</version>
...
<java.version>17</java.version>        <!-- 3.5.x → JDK 17；写 17 不写别的 -->
```

## Step 3：核对 properties 三段式

- 第一段基础属性自然排序 ✓
- 第二段只留 `<mycache-client.version>1.2.0</mycache-client.version>`
- 第三段完整 22 插件属性（模板已带）

## Step 4：源码三件套

```
src/main/java/io/github/myorg/mycache/spring/boot/
├── MyCacheAutoConfiguration.java    @AutoConfiguration + @EnableConfigurationProperties
├── MyCacheProperties.java           @ConfigurationProperties("mycache")
└── MyCacheTemplate.java             门面：get/put/evict 委托 client
```

```java
@AutoConfiguration
@EnableConfigurationProperties(MyCacheProperties.class)
public class MyCacheAutoConfiguration {
    @Bean @ConditionalOnMissingBean
    public MyCacheTemplate myCacheTemplate(MyCacheProperties props) {
        return new MyCacheTemplate(MyCacheClient.create(props.toConfig()));
    }
}
```

## Step 5：测试三件套

```
src/test/java/.../
├── MyCacheAutoConfigurationTest.java   ApplicationContextRunner：enabled/disabled/bean 注入
├── MyCachePropertiesTest.java          默认值 + getter/setter 往返
└── MyCacheTemplateTest.java            mock client 验证委托
```

## Step 6：验收构建

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)   # 或按分支 JDK
mvn clean verify
# 期望：BUILD SUCCESS + All coverage checks have been met（≥90%）
```

## Step 7：十分支创建

```bash
for b in 2.3.x 2.7.x 3.0.x 3.1.x 3.2.x 3.3.x 3.4.x 3.5.x 4.0.x 4.1.x; do
  git checkout -b $b
  # 按 version-matrix.md §1 改 parent.version / java.version / 自身版本
  git commit -am "chore: branch $b" && git push -u origin $b
done
```

## Step 8：核对清单

- [ ] 元素顺序：parent→坐标→lic/scm/dev→properties→dm→deps→dist→build→profiles
- [ ] properties 三段式 + 自然排序
- [ ] licenses/scm/developers 存在且带段落注释
- [ ] java.version ∈ {8,17,21}（无 1.8）
- [ ] surefire argLine 含 `${argLine}`
- [ ] jacoco check 0.90 + haltOnFailure
- [ ] 无 lombok 时 annotationProcessorPaths 已删
- [ ] mvn clean verify 通过
