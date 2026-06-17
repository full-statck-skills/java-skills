# 登录认证 + 权限认证 + 注解鉴权 综合示例

```java
@RestController
@RequestMapping("/user/")
public class UserController {

    // ===== 登录认证 =====

    // 登录: POST /user/doLogin?name=zhang&pwd=123456
    @RequestMapping("doLogin")
    public SaResult doLogin(String name, String pwd) {
        if("zhang".equals(name) && "123456".equals(pwd)) {
            StpUtil.login(10001);
            return SaResult.ok("登录成功");
        }
        return SaResult.error("登录失败");
    }

    // 是否登录: GET /user/isLogin
    @RequestMapping("isLogin")
    public SaResult isLogin() {
        return SaResult.ok("是否登录：" + StpUtil.isLogin());
    }

    // 查看Token信息: GET /user/tokenInfo
    @RequestMapping("tokenInfo")
    public SaResult tokenInfo() {
        return SaResult.data(StpUtil.getTokenInfo());
    }

    // 注销: GET /user/logout
    @RequestMapping("logout")
    public SaResult logout() {
        StpUtil.logout();
        return SaResult.ok();
    }

    // ===== 权限认证(需登录) =====

    // 查询：需要 user.get 权限
    @SaCheckPermission("user.get")
    @RequestMapping("query")
    public SaResult query() {
        return SaResult.ok("查询用户信息");
    }

    // 新增：需要 user.add 权限 或 admin 角色
    @SaCheckPermission(value = "user.add", orRole = "admin")
    @RequestMapping("add")
    public SaResult add() {
        return SaResult.ok("新增用户");
    }

    // 删除：需要 user.delete AND user.add 权限
    @SaCheckPermission({"user.delete", "user.add"})
    @RequestMapping("delete")
    public SaResult delete() {
        return SaResult.ok("删除用户");
    }

    // ===== 路由拦截示例(需配合SaTokenConfigure) =====
    // 假设配置了 SaRouter.match("/admin/**").check(r -> StpUtil.checkRole("admin"))
    // 那么访问 /user/admin/dashboard 需要 admin 角色
    @RequestMapping("admin/dashboard")
    public SaResult dashboard() {
        return SaResult.ok("管理员面板");
    }
}
```

---

> 配套配置参考：
> - [references/login-auth.md](../references/login-auth.md)
> - [references/jur-auth.md](../references/jur-auth.md)
> - [references/at-check.md](../references/at-check.md)
> - [references/route-check.md](../references/route-check.md)
