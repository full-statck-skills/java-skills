---
name: jackson-patterns
description: |
  Jackson JSON 序列化技能。覆盖日期格式配置(非ISO-8601)、Null序列化规则(数组→[]/字符串→""/数字→null)、@JsonView分层、ObjectMapper单例规则、TypeReference泛型反序列化、@JsonProperty/@JsonFormat/@JsonIgnore注解原则、与Spring Boot集成。
  当用户处理JSON序列化/反序列化、配置ObjectMapper、解决日期格式或null处理问题时使用。
license: Apache-2.0
---

# Jackson JSON 序列化

> 编码 Jackson 的使用规则。LLM 默认配置 SerializationFeature.WRITE_DATES_AS_TIMESTAMPS=true，但中国开发者期望 yyyy-MM-dd HH:mm:ss。

## Capability Boundaries

### ✅ Strong Suits
1. **日期格式** — yyyy-MM-dd HH:mm:ss(非ISO-8601)，与Spring Boot集成
2. **Null序列化** — 数组→[]/字符串→""/数字→null/布尔→null（规则不一致要明确）
3. **@JsonView** — 同一对象不同场景返回不同字段(列表vs详情)
4. **TypeReference** — 正确反序列化泛型类型(List<User>等)
5. **@JsonProperty/@JsonFormat/@JsonIgnore** — 字段重命名/格式化/忽略

### ❌ Out of Scope
1. Java Bean 映射 → **MapStruct**（编译期生成，Jackon是序列化不是映射）
2. JSON 为API格式，内部对象映射用 MapStruct

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 日期序列化为时间戳 `1702468800000` | 配置 `WRITE_DATES_AS_TIMESTAMPS=false`，格式 `yyyy-MM-dd HH:mm:ss` |
| 2 | null 字段不返回或返回 null | 明确规则：数组→[]、字符串→""、数字→null、布尔→null |
| 3 | 每次 new ObjectMapper() | ObjectMapper 是线程安全的，应用级单例 |
| 4 | `objectMapper.readValue(json, List.class)` | `objectMapper.readValue(json, new TypeReference<List<User>>(){})` |
| 5 | 标准JSON格式不与其他系统对齐 | 带 NullNode/WRITE_BIGDECIMAL_AS_PLAIN 等需要显式配置 |

## 核心规则速查

```java
// ✅ Spring Boot 配置(ObjectMapper全局)
@Configuration
public class JacksonConfig {
    @Bean
    public Jackson2ObjectMapperBuilderCustomizer customizer() {
        return builder -> builder
            .simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            .serializationInclusion(JsonInclude.Include.NON_NULL)
            .featuresToDisable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            .featuresToEnable(MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES);
    }
}

// ✅ 注解方式
@Data
public class UserVO {
    @JsonProperty("user_name")   // JSON字段重命名
    private String username;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @JsonIgnore                  // 序列化时忽略
    private String password;

    @JsonView(Views.Detail.class) // 仅详情视图返回
    private String email;
}

// ✅ TypeReference 反序列化
List<User> users = objectMapper.readValue(json,
    new TypeReference<List<User>>(){});

// ✅ Null值处理规则
objectMapper.configOverride(String.class)
    .setInclude(JsonInclude.Value.construct(
        JsonInclude.Include.NON_NULL,  // null string → null
        JsonInclude.Include.NON_NULL
    ));
```

## Gotchas
1. **ObjectMapper 是线程安全的** — 不要每次 new，使用单例
2. **TypeReference 必不可少** — 泛型反序列化不用 TypeReference 会得到 LinkedHashMap
3. **@JsonProperty 只影响序列化** — 不影响 Java 字段名
4. **WRITE_DATES_AS_TIMESTAMPS 默认 true** — Spring Boot 默认改为 false
5. **Jackson 的 @JsonFormat 和 Spring 的 @DateTimeFormat 不同** — 前者JSON后者表单/Query参数
6. **默认不能反序列化 LocalDateTime** — 需要 jackson-datatype-jsr310 依赖
7. **@JsonIgnore 和 @JsonProperty(access=READ_ONLY) 的区别** — @JsonIgnore 双向忽略，access控制方向
8. **null 数字不会自动变 0** — 需要全局 include=NON_NULL 或单独配置

## Data Privacy
本技能不收集、存储或传输任何用户数据。
