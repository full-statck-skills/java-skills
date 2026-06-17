# Same-Token 内部服务隔离

> 来源：
> - [same-token.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/same-token.md)（277行）
> - [import-intro.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/import-intro.md)（100行）

## 网关注入Same-Token

```java
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

## 子服务校验

```java
@Bean
public SaServletFilter getSaServletFilter() {
    return new SaServletFilter()
        .addInclude("/**")
        .addExclude("/favicon.ico")
        .setAuth(obj -> SaSameUtil.checkCurrentRequestToken())
        .setError(e -> SaResult.error("无效Same-Token:" + e.getMessage()));
}
```

## Feign内部调用

```java
@Component
public class FeignInterceptor implements RequestInterceptor {
    @Override
    public void apply(RequestTemplate requestTemplate) {
        requestTemplate.header(SaSameUtil.SAME_TOKEN, SaSameUtil.getToken());
    }
}

@FeignClient(name = "sp-home", configuration = FeignInterceptor.class)
public interface SpCfgInterface {
    @RequestMapping("/SpConfig/getConfig")
    public String getConfig(@RequestParam("key") String key);
}
```

## Same-Token API

```java
SaSameUtil.getToken();                         // 获取当前Same-Token
SaSameUtil.isValid(token);                     // 判断是否有效
SaSameUtil.checkToken(token);                  // 校验(无效抛异常)
SaSameUtil.checkCurrentRequestToken();          // 校验当前请求Token
SaSameUtil.refreshToken();                     // 刷新
```

## 定时刷新

```java
@Scheduled(cron = "0 0/5 * * * ?")
public void refreshToken() { SaSameUtil.refreshToken(); }
```

刷新时旧Token作为次级Token保留，新旧其一都可通过认证。

## 依赖引入

| 框架 | 依赖 |
|------|------|
| SpringBoot2+Servlet | sa-token-spring-boot-starter |
| SpringBoot3+Servlet | sa-token-spring-boot3-starter |
| SpringBoot4+Servlet | sa-token-spring-boot4-starter |
| SpringBoot2+Reactive | sa-token-reactor-spring-boot-starter |
| SpringBoot3+Reactive | sa-token-reactor-spring-boot3-starter |
| SpringBoot4+Reactive | sa-token-reactor-spring-boot4-starter |
