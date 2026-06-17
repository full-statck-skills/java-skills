# 路由拦截鉴权

## 1. 注册 Sa-Token 路由拦截器

最简单的写法：只进行登录校验功能

```java
@Configuration
public class SaTokenConfigure implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor(handle -> StpUtil.checkLogin()))
                .addPathPatterns("/**")
                .excludePathPatterns("/user/doLogin");
    }
}
```

## 2. 自定义详细认证规则

可以在构造函数里写一个完整的 lambda 函数，来定义详细的校验规则：

```java
@Configuration
public class SaTokenConfigure implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor(handler -> {

            // 登录校验 -- 拦截所有路由，并排除/user/doLogin用于开放登录
            SaRouter.match("/**", "/user/doLogin", r -> StpUtil.checkLogin());

            // 角色校验 -- 拦截以admin开头的路由，必须具备admin或super-admin角色
            SaRouter.match("/admin/**", r -> StpUtil.checkRoleOr("admin", "super-admin"));

            // 权限校验 -- 不同模块校验不同权限
            SaRouter.match("/user/**", r -> StpUtil.checkPermission("user"));
            SaRouter.match("/goods/**", r -> StpUtil.checkPermission("goods"));
            SaRouter.match("/orders/**", r -> StpUtil.checkPermission("orders"));
            SaRouter.match("/notice/**", r -> StpUtil.checkPermission("notice"));
            SaRouter.match("/comment/**", r -> StpUtil.checkPermission("comment"));

            // 可以随意写打印语句
            SaRouter.match("/**", r -> System.out.println("----啦啦啦----"));

            // 连缀写法
            SaRouter.match("/**").check(r -> System.out.println("----啦啦啦----"));

        })).addPathPatterns("/**");
    }
}
```

## 3. 匹配特征详解

```java
// 1. 基础path匹配
SaRouter.match("/user/**").check(r -> StpUtil.checkLogin());

// 2. 多path匹配（支持restful风格）
SaRouter.match("/user/**", "/goods/**", "/art/get/{id}").check(/*函数*/);

// 3. 排除匹配
SaRouter.match("/**").notMatch("*.html", "*.css", "*.js").check(/*函数*/);

// 4. 请求类型匹配
SaRouter.match(SaHttpMethod.GET).check(/*函数*/);
SaRouter.match(SaHttpMethod.POST, SaHttpMethod.PUT).check(/*函数*/);

// 5. boolean条件匹配
SaRouter.match(StpUtil.isLogin()).check(/*函数*/);

// 6. lambda条件匹配
SaRouter.match(r -> StpUtil.isLogin()).check(/*函数*/);

// 7. 多条件一起使用（必须同时满足）
SaRouter.match(SaHttpMethod.GET).match("/user/**").check(/*函数*/);

// 8. 无限连缀（所有条件都满足才执行check）
SaRouter
    .match(SaHttpMethod.GET)
    .match("/admin/**")
    .match("/**/send/**")
    .notMatch("/**/*.js")
    .notMatch("/**/*.css")
    .check(/*所有条件都匹配成功才执行*/);
```

## 4. 提前退出匹配链

```java
// stop()：停止匹配，进入Controller
SaRouter.match("/**").check(r -> System.out.println("进入1"));
SaRouter.match("/**").check(r -> System.out.println("进入2")).stop();
SaRouter.match("/**").check(r -> System.out.println("不会执行"));

// back()：停止匹配，直接返回结果到前端（不进入Controller）
SaRouter.match("/user/back").back("要返回到前端的内容");
```

**stop() 与 back() 的区别：**
- `SaRouter.stop()`：停止匹配，**进入** Controller 执行后续逻辑
- `SaRouter.back()`：停止匹配，**直接返回**结果到前端，不进入 Controller

## 5. free 独立作用域

```java
SaRouter.match("/**").free(r -> {
    SaRouter.match("/a/**").check(/*---*/);
    SaRouter.match("/b/**").check(/*---*/).stop();
    SaRouter.match("/c/**").check(/*---*/);
});
// 执行stop()跳出free后继续执行下面的match匹配
SaRouter.match("/**").check(/*继续执行*/);
```

`free()` 的作用：打开一个独立的作用域，使内部的 `stop()` 不再一次性跳出整个 Auth 函数，而是仅仅跳出当前 free 作用域。

## 6. @SaIgnore 忽略路由拦截

先配置拦截规则，再在 Controller 中添加忽略注解：

```java
@Override
public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new SaInterceptor(handler -> {
        SaRouter.match("/user/**", r -> StpUtil.checkPermission("user"));
        SaRouter.match("/admin/**", r -> StpUtil.checkPermission("admin"));
    })).addPathPatterns("/**");
}

@SaIgnore
@RequestMapping("/user/getList")
public SaResult getList() { return SaResult.ok(); }
```

> ⚠️ `@SaIgnore` 只针对 SaInterceptor 拦截器和 AOP 注解鉴权生效，对自定义拦截器与过滤器不生效。

## 7. 关闭注解校验

```java
registry.addInterceptor(
    new SaInterceptor(handle -> {
        SaRouter.match("/**").check(r -> StpUtil.checkLogin());
    }).isAnnotation(false)  // 指定关闭注解鉴权能力，只做路由拦截校验
).addPathPatterns("/**");
```

## 8. setBeforeAuth 注册认证前置函数

```java
registry.addInterceptor(new SaInterceptor(handle -> {
    System.out.println(1);
})
.setBeforeAuth(handle -> {
    System.out.println(2);
})
).addPathPatterns("/**");
```

执行顺序：**2 → 注解鉴权 → 1**。如果 beforeAuth 里包含 `SaRouter.stop()`，将跳过后续的注解鉴权和 auth 认证环节。

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/route-check.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/route-check.md)（270行）
