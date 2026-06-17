# Jackson 实战示例

## 示例 1：Spring Boot 全局配置（中国日期格式）

```java
@Configuration
public class JacksonConfig {
    @Bean
    public Jackson2ObjectMapperBuilderCustomizer customizer() {
        return builder -> builder
            .simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            .serializationInclusion(JsonInclude.Include.NON_NULL)
            .featuresToDisable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            .featuresToDisable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    }
}
```

## 示例 2：同一个对象列表/详情不同字段

```java
public class UserVO {
    @JsonView(Views.Summary.class) private Long id;
    @JsonView(Views.Summary.class) private String username;
    @JsonView(Views.Detail.class)  private String email;
    @JsonView(Views.Detail.class)  private String phone;
}

@RestController
public class UserController {
    @JsonView(Views.Summary.class)
    @GetMapping("/users")         // 列表：只返回 id+username
    public List<UserVO> list() { ... }

    @JsonView(Views.Detail.class)
    @GetMapping("/users/{id}")    // 详情：返回全部字段
    public UserVO detail(@PathVariable Long id) { ... }
}
```

## 示例 3：TypeReference 泛型反序列化

```java
// ✅ 正确
List<UserDTO> users = objectMapper.readValue(json,
    new TypeReference<List<UserDTO>>(){});

// ❌ 错误：会得到 List<LinkedHashMap>
List<UserDTO> users = objectMapper.readValue(json, List.class);
```

---

> 来源：[https://github.com/FasterXML/jackson-docs](https://github.com/FasterXML/jackson-docs)
