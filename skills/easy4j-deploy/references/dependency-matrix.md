# 依赖矩阵与 Jackson 3.x 迁移对照

## 目录
1. [三分支依赖矩阵](#三分支依赖矩阵)
2. [JDK 天花板详表](#jdk-天花板详表)
3. [Jackson 3.x 迁移 API 对照](#jackson-3x-迁移-api-对照)
4. [版本查询方法](#版本查询方法)

## 三分支依赖矩阵

| 依赖 | 1.0.x (JDK 8) | 2.0.x (JDK 17) | 3.0.x (JDK 21) |
|------|---------------|----------------|----------------|
| okhttp3 | 4.12.0 | 4.12.0 | 5.4.0 |
| jackson-bom | 2.18.9 | 2.22.1 | 3.2.1（tools.jackson） |
| jackson-annotations | 2.18.9 | 2.22 | 2.22（仍属 com.fasterxml，由 BOM 管理） |
| commons-exec | 1.6.0 | 1.6.0 | 1.6.0 |
| Java-WebSocket | 1.6.0 | 1.6.0 | 1.6.0 |
| slf4j-api | 2.0.18 | 2.0.18 | 2.0.18 |
| lombok | 1.18.46 | 1.18.46 | 1.18.46 |
| junit-jupiter | 5.11.4 | 5.11.4 | 5.11.4 |
| okhttp3-extension | 1.0.x.{日期} | 2.0.x.{日期} | 3.0.x.{日期} |

注意：`jackson-annotations` 的版本号经常没有 patch 位（`2.22` 而非 `2.22.1`），手工指定容易 404。import BOM 后由 BOM 统一对齐，**不要**再手工声明 annotations 版本。

## JDK 天花板详表

| 组件 | JDK 8 上限 | 突破点 | 说明 |
|------|-----------|--------|------|
| jackson-databind/core | 2.18.9 | 2.19.0 要求 JDK 11 | 2.18.x 是最后兼容 JDK 8 的版本线 |
| okhttp | 4.12.0 | 5.x 要求 JDK 11 | 3.0.x（JDK 21）可用 5.4.0 |
| junit-jupiter | 5.11.4 | 6.0.0 要求 JDK 17 | 2.0.x（JDK 17）理论可用 6.x，但阿里云镜像可能缺 6.x，需先验证 |
| caffeine | 2.9.3 | 3.x 要求 JDK 11 | okhttp3-extension 1.0.x 线用 2.9.3 |
| checker-qual | 3.55.1 | 4.x 要求 JDK 11 | 随 caffeine 联动 |

升级流程：查 Maven Central 最新稳定版 → OSV 查 CVE → 检查该版本 JDK 要求 → 检查阿里云镜像 3 个模块齐全 → 升级 + 全量测试。

## Jackson 3.x 迁移 API 对照

Jackson 3.x（3.2.1+）是 **API 级破坏变更**，不只是包名替换：

| Jackson 2.x | Jackson 3.x | 说明 |
|-------------|-------------|------|
| `com.fasterxml.jackson:jackson-bom` | `tools.jackson:jackson-bom` | BOM groupId 变了 |
| `com.fasterxml.jackson.core:*` | `tools.jackson.core:*`（databind/core） | 包名变了 |
| `com.fasterxml.jackson.databind:*` | `tools.jackson.databind:*` | 包名变了 |
| `com.fasterxml.jackson.annotation.*` | **不变**（仍 com.fasterxml，版本 2.22 由 BOM 管理） | — |
| `JsonProcessingException` | `tools.jackson.core.JacksonException` | 类改名；构造器 protected 不可直接 new |
| `JsonSerializer<T>` | `ValueSerializer<T>` | |
| `JsonDeserializer<T>` | `ValueDeserializer<T>` | |
| `SerializerProvider` | `SerializationContext` | |
| `new ObjectMapper().configure(Feature, false)` | `JsonMapper.builder().disable(Feature).build()` | configure() 已移除 |
| `new ObjectMapper()` | `new JsonMapper()` | |
| `gen.writeObject(obj)`（序列化器内） | `ctxt.writeValue(gen, obj)`（SerializationContext 提供） | JsonGenerator.writeObject 移除 |
| `JsonNode.fieldNames()`（Iterator） | `propertyNames()`（Collection） | 返回类型也变了 |
| catch `IOException`（Jackson 调用） | catch `JacksonException` | Jackson 不再抛 IOException |
| `JsonParseException` / `JsonMappingException` | 已移除，统一 catch `JacksonException` | 两类异常在 3.x 合并 |
| `TextNode` | `StringNode` | 改名 |
| `JsonNode.fields()` | `properties()` | 返回 Set&lt;Entry&gt;，遍历方式适配 |
| jsr310（jackson-datatype-jsr310） | 已合并进 databind | 3.0 起依赖与 JavaTimeModule 注册可删 |
| 尾随 token 解析 | `FAIL_ON_TRAILING_TOKENS` **默认启用** | 2.x 默认关；宽解析场景需 `.disable(FAIL_ON_TRAILING_TOKENS)` |
| `MapperBuilder.visibility(...)` | `changeDefaultVisibility(vc -> vc.withVisibility(...))` | visibility() 已移除 |
| `setDefaultPropertyInclusion/setTimeZone/setDateFormat` | `changeDefaultPropertyInclusion(UnaryOperator)` / `defaultTimeZone` / `defaultDateFormat` | setter 链全部改 builder 方法 |
| `ObjectMapper.propertyNamingStrategy(...)` | builder `propertyNamingStrategy(...)` | 可变 setter 移除，仅 builder 配置 |

自定义序列化器中抛异常：`JacksonException`/`DatabindException` 构造器均 protected，用 `IllegalStateException` 或 `ctxt` 提供的工厂方法替代。

## 版本查询方法

```bash
# Maven Central 某组件全部版本（取最高纯 semver）
curl -s "https://repo1.maven.org/maven2/<groupPath>/<artifact>/maven-metadata.xml" \
  | python3 -c "
import sys, re
vs = re.findall(r'<version>([^<]+)</version>', sys.stdin.read())
print([v for v in vs if re.match(r'^\d+\.\d+(\.\d+)?$', v)][-1])"

# 验证阿里云镜像有某版本（3 个 jackson 模块都要查）
curl -s -o /dev/null -w '%{http_code}\n' \
  "https://maven.aliyun.com/repository/central/<groupPath>/<artifact>/<v>/<artifact>-<v>.pom"

# OSV 查某版本 CVE（必须用 groupId:artifactId 冒号格式）
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"package":{"name":"com.fasterxml.jackson.core:jackson-databind","ecosystem":"Maven"},"version":"2.18.9"}' \
  https://api.osv.dev/v1/query
```
