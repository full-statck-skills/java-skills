# JWT 集成 + Redis 持久化 完整示例

## 1. JWT Simple模式集成

### 依赖
```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-jwt</artifactId>
    <version>1.45.0</version>
</dependency>
```

### application.yml
```yaml
sa-token:
  jwt-secret-key: asdasdasifhueuiwyurfewbfjsdafjk
  token-name: satoken
  timeout: 2592000
```

### 注入JWT实现
```java
@Configuration
public class SaTokenConfigure {
    @Bean
    public StpLogic getStpLogicJwt() {
        return new StpLogicJwtForSimple();  // Simple模式
    }
}
```

### 使用扩展参数
```java
@RestController
public class JwtController {

    // 登录并携带扩展参数
    @RequestMapping("login")
    public SaResult login() {
        StpUtil.login(10001, new SaLoginParameter()
            .setExtra("name", "张三")
            .setExtra("role", "admin"));
        return SaResult.data(StpUtil.getTokenInfo());
    }

    // 读取扩展参数
    @RequestMapping("info")
    public SaResult info() {
        String name = StpUtil.getExtra("name");
        String role = StpUtil.getExtra("role");
        return SaResult.data("name=" + name + ", role=" + role);
    }
}
```

生成的JWT Token示例：
```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbklkIjoiMTAwMDEiLCJybiI6IjZYYzgySzBHVWV3Uk5NTTl1dFdjbnpFZFZHTVNYd3JOIn0.F_7fbHsFsDZmckHlGDaBuwDotZwAjZ0HB14DRujQfOQ
```

## 2. Redis 持久化

### 依赖
```xml
<!-- RedisTemplate JSON序列化(推荐) -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis-template</artifactId>
    <version>1.45.0</version>
</dependency>
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  redis:
    database: 1
    host: 127.0.0.1
    port: 6379
    timeout: 1000ms
    lettuce:
      pool:
        max-active: 200
        max-idle: 10
        min-idle: 0
```

引入依赖后，框架自动保存会话数据到 Redis，所有上层 API 不变。

> **来源：**
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md)（247行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/integ-redis.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/integ-redis.md)（212行）
