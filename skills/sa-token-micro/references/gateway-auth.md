# 网关统一鉴权 + 分布式Session

> 来源：
> - [gateway-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/gateway-auth.md)（132行）
> - [dcs-session.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/micro/dcs-session.md)（68行）

## 网关统一鉴权

所有请求在网关层统一校验登录状态和权限。

### 网关依赖

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-reactor-spring-boot-starter</artifactId>
    <version>1.45.0</version>
</dependency>
<!-- SpringBoot3: sa-token-reactor-spring-boot3-starter -->
<!-- SpringBoot4: sa-token-reactor-spring-boot4-starter -->
```

### 网关鉴权代码

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
            SaRouter.match("/goods/**").check(r -> StpUtil.checkPermission("goods"));
        })
        .setError(e -> SaResult.error(e.getMessage()));
}
```

## 分布式Session

### 4种方案

| 方案 | 说明 | 推荐度 |
|------|------|:------:|
| Session同步 | 各服务间同步 | ⭐ |
| 粘性Session | 负载均衡到同一节点 | ⭐⭐ |
| **Redis Session中心** | 统一Redis存储 | ⭐⭐⭐⭐⭐ |
| JWT无状态 | Token自带数据 | ⭐⭐⭐⭐ |

### Redis方案

只需引入 `sa-token-redis-template` 依赖并配置Redis连接即可实现所有服务共享Session。

```yaml
spring:
  redis:
    host: 127.0.0.1
    port: 6379
```

原理：子服务A存数据到Redis后，子服务B可以直接读取。
```java
// 子服务A
StpUtil.getSession().set("user", user);
// 子服务B
SysUser user = (SysUser) StpUtil.getSession().get("user");
```
