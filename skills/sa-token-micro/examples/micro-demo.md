# 微服务网关统一鉴权 + Same-Token 完整示例

## 网关模块 (sa-token-gateway)

### 依赖
```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-reactor-spring-boot-starter</artifactId>
    <version>1.45.0</version>
</dependency>
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis-template</artifactId>
    <version>1.45.0</version>
</dependency>
```

### 网关鉴权 + Same-Token 注入
```java
@Bean
public SaReactorFilter getSaReactorFilter() {
    return new SaReactorFilter()
        .addInclude("/**")
        .addExclude("/favicon.ico")
        .setAuth(obj -> {
            SaRouter.match("/**").check(r -> StpUtil.checkLogin());
            SaRouter.match("/user/**").check(r -> StpUtil.checkPermission("user"));
            SaRouter.match("/admin/**").check(r -> StpUtil.checkPermission("admin"));
        })
        .setError(e -> SaResult.error(e.getMessage()));
}

@Component
public class ForwardAuthFilter implements GlobalFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest newRequest = exchange.getRequest().mutate()
            .header(SaSameUtil.SAME_TOKEN, SaSameUtil.getToken())
            .build();
        ServerWebExchange newExchange = exchange.mutate().request(newRequest).build();
        return chain.filter(newExchange);
    }
}
```

## 子服务模块

### 依赖
```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-spring-boot-starter</artifactId>
    <version>1.45.0</version>
</dependency>
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis-template</artifactId>
    <version>1.45.0</version>
</dependency>
```

### 子服务 Same-Token 校验
```java
@Bean
public SaServletFilter getSaServletFilter() {
    return new SaServletFilter()
        .addInclude("/**")
        .addExclude("/favicon.ico")
        .setAuth(obj -> {
            SaSameUtil.checkCurrentRequestToken();
        })
        .setError(e -> SaResult.error("无效请求"));
}

@RestController
public class ServiceController {
    @RequestMapping("/service/data")
    public SaResult getData() {
        return SaResult.data("来自子服务的数据");
    }
}
```

## Feign 内部调用

```java
@Component
public class FeignInterceptor implements RequestInterceptor {
    @Override
    public void apply(RequestTemplate requestTemplate) {
        requestTemplate.header(SaSameUtil.SAME_TOKEN, SaSameUtil.getToken());
    }
}

@FeignClient(name = "my-service", configuration = FeignInterceptor.class)
public interface MyServiceClient {
    @RequestMapping("/service/data")
    String getData();

    @RequestMapping("/admin/info")
    String getAdminInfo();
}
```

---

> 来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/gateway-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/gateway-auth.md)（132行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/same-token.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/same-token.md)（277行）
