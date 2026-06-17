# 权限认证 + 注解鉴权 + 路由拦截 综合示例

> 来源: 官方 demo `JurAuthController` + `AtCheckController` + `RouterCheckController` + `SaTokenConfigure` + `StpInterfaceImpl`

## 1. StpInterface 权限加载器

```java
@Component
public class StpInterfaceImpl implements StpInterface {
    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        List<String> list = new ArrayList<>();
        list.add("101");
        list.add("user.add");
        list.add("user.update");
        list.add("user.get");
        list.add("art.*");        // 通配符
        return list;
    }

    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        List<String> list = new ArrayList<>();
        list.add("admin");
        list.add("super-admin");
        return list;
    }
}
```

## 2. 权限/角色认证查询

```java
@RestController
@RequestMapping("/jur/")
public class JurAuthController {

    // 查询权限/角色: GET /jur/getPermission
    @RequestMapping("getPermission")
    public SaResult getPermission() {
        List<String> permissionList = StpUtil.getPermissionList();
        List<String> roleList = StpUtil.getRoleList();
        return SaResult.ok()
            .set("roleList", roleList)
            .set("permissionList", permissionList);
    }

    // 权限校验: GET /jur/checkPermission
    @RequestMapping("checkPermission")
    public SaResult checkPermission() {
        // 判断(返回boolean)
        StpUtil.hasPermission("user.add");
        StpUtil.hasPermissionAnd("user.add", "user.delete", "user.get");
        StpUtil.hasPermissionOr("user.add", "user.delete", "user.get");

        // 校验(失败抛异常)
        StpUtil.checkPermission("user.add");
        StpUtil.checkPermissionAnd("user.add", "user.delete", "user.get");
        StpUtil.checkPermissionOr("user.add", "user.delete", "user.get");

        return SaResult.ok();
    }

    // 角色校验: GET /jur/checkRole
    @RequestMapping("checkRole")
    public SaResult checkRole() {
        StpUtil.hasRole("admin");
        StpUtil.hasRoleAnd("admin", "ceo", "cfo");
        StpUtil.hasRoleOr("admin", "ceo", "cfo");

        StpUtil.checkRole("admin");
        StpUtil.checkRoleAnd("admin", "ceo", "cfo");
        StpUtil.checkRoleOr("admin", "ceo", "cfo");

        return SaResult.ok();
    }

    // 通配符测试: GET /jur/wildcardPermission
    @RequestMapping("wildcardPermission")
    public SaResult wildcardPermission() {
        // 假设账号拥有 "art.*"
        StpUtil.hasPermission("art.add");        // true
        StpUtil.hasPermission("art.delete");     // true
        StpUtil.hasPermission("goods.add");      // false

        // * 出现在开头: "*.delete"
        StpUtil.hasPermission("goods.add");       // false
        StpUtil.hasPermission("goods.delete");    // true
        StpUtil.hasPermission("art.delete");     // true

        // * 出现在中间: "shop.*.user"
        StpUtil.hasPermission("shop.add.user");    // true
        StpUtil.hasPermission("shop.delete.user"); // true
        StpUtil.hasPermission("shop.delete.goods"); // false

        // 上帝权限 "*" → 所有都通过
        return SaResult.ok();
    }
}
```

## 3. 注解鉴权

```java
@RestController
@RequestMapping("/at-check/")
public class AtCheckController {

    // 登录校验: GET /at-check/checkLogin
    @SaCheckLogin
    @RequestMapping("checkLogin")
    public SaResult checkLogin() { return SaResult.ok(); }

    // 权限校验(单个): GET /at-check/checkPermission
    @SaCheckPermission("user.add")
    @RequestMapping("checkPermission")
    public SaResult checkPermission() { return SaResult.ok(); }

    // 权限校验(AND): GET /at-check/checkPermission2
    @SaCheckPermission(value = {"user.add", "user.delete"}, mode = SaMode.AND)
    @RequestMapping("checkPermission2")
    public SaResult checkPermission2() { return SaResult.ok(); }

    // 权限校验(OR): GET /at-check/checkPermission3
    @SaCheckPermission(value = {"user.add", "user.delete"}, mode = SaMode.OR)
    @RequestMapping("checkPermission3")
    public SaResult checkPermission3() { return SaResult.ok(); }

    // 角色校验: GET /at-check/checkRole
    @SaCheckRole("super-admin")
    @RequestMapping("checkRole")
    public SaResult checkRole() { return SaResult.ok(); }

    // 角色权限双重OR: GET /at-check/userAdd
    @SaCheckPermission(value = "user.add", orRole = "admin")
    @RequestMapping("userAdd")
    public SaResult userAdd() { return SaResult.data("用户信息"); }

    // 忽略校验: GET /at-check/ignore
    @SaIgnore
    @SaCheckLogin
    @RequestMapping("ignore")
    public SaResult ignore() { return SaResult.ok(); }
}
```

## 4. SaTokenConfigure 完整配置

```java
@Configuration
public class SaTokenConfigure implements WebMvcConfigurer {

    // 注册拦截器(注解鉴权+路由鉴权)
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor(handler -> {
            SaRouter.match("/user/**")
                .notMatch("/user/doLogin")
                .check(r -> StpUtil.checkLogin());

            SaRouter.match("/admin/**", r -> StpUtil.checkPermission("admin"));
            SaRouter.match("/goods/**", r -> StpUtil.checkPermission("goods"));
            SaRouter.match("/orders/**", r -> StpUtil.checkPermission("orders"));
        })).addPathPatterns("/**");
    }

    // 全局过滤器(CORS + 安全头 + 全局鉴权)
    @Bean
    public SaServletFilter getSaServletFilter() {
        return new SaServletFilter()
            .addInclude("/**")
            .setAuth(obj -> {
                SaRouter.match("/admin/**", r -> StpUtil.checkPermission("admin"));
            })
            .setError(e -> SaResult.error(e.getMessage()))
            .setBeforeAuth(r -> {
                SaHolder.getResponse()
                    .setServer("sa-server")
                    .setHeader("X-Frame-Options", "SAMEORIGIN")
                    .setHeader("X-XSS-Protection", "1; mode=block")
                    .setHeader("X-Content-Type-Options", "nosniff");
            });
    }
}
```

---

> 来源:
> - [JurAuthController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/use/JurAuthController.java)
> - [AtCheckController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/use/AtCheckController.java)
> - [SaTokenConfigure.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/satoken/SaTokenConfigure.java)
