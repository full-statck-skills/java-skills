# 示例：从零封装 mylib-java-sdk 组件

以封装 fictional `com.vendor:vendor-core:2.1.0` 为 `mylib-java-sdk` 为例。

## Step 1：复制模板

```bash
cp skills/.../java-component-patterns/assets/pom-template.xml mylib-java-sdk/pom.xml
```

替换占位符：`{GROUP_ID}`=io.github.myorg、`{ARTIFACT}`=mylib-java-sdk、`{DESCRIPTION}`=Vendor Core integration SDK、`{ORG}`=myorg、`{EXTERNAL_*}`=com.vendor:vendor-core:2.1.0、`{DEV_*}`=开发者信息。

## Step 2：按目标分支填值（feature/3.0.x，JDK 17）

```xml
<version>3.0.x.20260630-SNAPSHOT</version>
...
<java.version>17</java.version>
<maven.compiler.release>${java.version}</maven.compiler.release>
```

注意：**没有 `<parent>`**；lombok 版本必须显式（`${lombok.version}` 无 parent 代管）。

## Step 3：properties 三段式核对

- 第一段：java.version=17 + release + maven.version + encoding
- 第二段：`<vendor-core.version>2.1.0</vendor-core.version>` + lombok/junit/slf4j
- 第三段：完整 17 插件版本

## Step 4：源码三件套

```
src/main/java/io/github/myorg/mylib/
├── MyLibClient.java          门面：封装 vendor-core 的核心操作
├── MyLibConfig.java          连接/超时/认证配置（POJO）
├── http/                     HTTP 能力域
├── cli/                      命令行能力域（若适用）
└── internal/                 内部实现
```

```java
public class MyLibClient implements AutoCloseable {
    private final MyLibConfig config;
    private final VendorConnection conn;

    public MyLibClient(MyLibConfig config) {
        this.config = config;
        this.conn = VendorCore.connect(config.toVendorSettings());
    }

    public String execute(String cmd) { return conn.send(cmd); }

    @Override
    public void close() { conn.shutdown(); }
}
```

## Step 5：测试

```
src/test/java/...
├── MyLibClientTest.java      mock VendorConnection 验证委托/关闭
├── MyLibConfigTest.java      默认值 + 往返
└── http/HttpChannelTest.java 能力域测试
```

## Step 6：验收

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
mvn clean verify
# BUILD SUCCESS + All coverage checks have been met
```

## Step 7：多分支创建

```bash
git checkout -b feature/1.0.x   # java.version=8
git checkout -b feature/2.0.x   # java.version=8 或 17
git checkout -b feature/3.0.x   # java.version=17（当前）
git checkout -b feature/4.1.x   # java.version=21
# 各分支 push；后续同步用 git checkout <src> -- src/ README.md
```

## Step 8：核对清单

- [ ] 无 parent；插件版本 properties 第三段齐全
- [ ] 元素顺序：坐标→lic/scm/dev→properties→dm→deps→dist→build→profiles
- [ ] maven.compiler.release（非 source/target）
- [ ] java.version ∈ {8,17,21}
- [ ] licenses/scm/developers 带段落注释
- [ ] 内部依赖同线（1.0.x←1.0.x）
- [ ] lombok 显式版本
- [ ] mvn clean verify 通过 + jacoco ≥90%
- [ ] 后续：组件发正式版后，starter 才可引用
