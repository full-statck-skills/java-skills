# 全局侦听器 + 全局过滤器

> 侦听器来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/global-listener.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/global-listener.md)
> 过滤器来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/global-filter.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/global-filter.md)

## 全局侦听器

SaTokenListener 接口定义的事件：

```java
public interface SaTokenListener {
    void doLogin(String loginType, Object loginId, String tokenValue, SaLoginParameter loginParameter);
    void doLogout(String loginType, Object loginId, String tokenValue);
    void doKickout(String loginType, Object loginId, String tokenValue);
    void doReplaced(String loginType, Object loginId, String tokenValue);
    void doDisable(String loginType, Object loginId, String service, int level, long disableTime);
    void doUntieDisable(String loginType, Object loginId, String service);
    void doOpenSafe(String loginType, Object loginId, String service, long safeTime);
    void doCloseSafe(String loginType, Object loginId, String service);
    void doCreateSession(String id);
    void doLogoutSession(String id);
    void doRenewTimeout(String loginType, Object loginId, long timeout);
}
```

使用 `SaTokenListenerForSimple` 简化实现（只重写需要的方法）：

```java
@Component
public class MyListener extends SaTokenListenerForSimple {
    @Override
    public void doLogin(String loginType, Object loginId, String tokenValue, SaLoginParameter loginParameter) {
        System.out.println("用户登录: " + loginId);
    }
    @Override
    public void doLogout(String loginType, Object loginId, String tokenValue) {
        System.out.println("用户注销: " + loginId);
    }
    @Override
    public void doKickout(String loginType, Object loginId, String tokenValue) {
        System.out.println("用户被踢下线: " + loginId);
    }
    @Override
    public void doDisable(String loginType, Object loginId, String service, int level, long disableTime) {
        System.out.println("账号被封禁: " + loginId + ", 服务:" + service);
    }
}
```

事件注册：
```java
// 手动注册（@Component自动注册无需手动操作）
SaTokenEventCenter.registerListener(listener);
```

## 全局过滤器（SaServletFilter）

```java
@Bean
public SaServletFilter getSaServletFilter() {
    return new SaServletFilter()
        .addInclude("/**")                    // 拦截所有
        .addExclude("/favicon.ico")           // 排除
        .setAuth(obj -> {                     // 认证逻辑
            SaRouter.match("/**").check(r -> StpUtil.checkLogin());
            SaRouter.match("/user/**").check(r -> StpUtil.checkPermission("user"));
            SaRouter.match("/admin/**").check(r -> StpUtil.checkPermission("admin"));
        })
        .setError(e -> SaResult.error(e.getMessage()))  // 异常返回
        .setBeforeAuth(obj -> {               // 前置处理(如CORS)
            SaHolder.getResponse()
                .setHeader("Access-Control-Allow-Origin", "*")
                .setHeader("Access-Control-Allow-Methods", "*");
        });
}
```

WebFlux 反应式环境使用 `SaReactorFilter`。

## 过滤器 vs 拦截器

| 特性 | SaServletFilter | SaInterceptor |
|------|:--------------:|:-------------:|
| 执行顺序 | 优先执行 | 后执行 |
| 过滤范围 | 所有请求(含静态资源) | Controller层(含注解) |
| WebFlux支持 | SaReactorFilter | ❌ |
| 注解鉴权 | ❌ | ✅ |
| 优先级控制 | FilterRegistrationBean | interceptor.order |
