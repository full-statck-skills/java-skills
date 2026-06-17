# 二级认证 + 账号封禁 + 多账号 示例

```java
@RestController
@RequestMapping("/advanced/")
public class AdvancedController {

    // ===== 二级认证 =====

    // 开启二级认证(修改密码前校验): GET /advanced/openSafe
    @RequestMapping("openSafe")
    public SaResult openSafe() {
        StpUtil.openSafe("update-password", 120);
        return SaResult.ok("二级认证已开启，请在两分钟内完成操作");
    }

    // 执行敏感操作: GET /advanced/updatePassword
    @SaCheckSafe("update-password")
    @RequestMapping("updatePassword")
    public SaResult updatePassword() {
        return SaResult.ok("密码修改成功");
    }

    // ===== 账号封禁 =====

    // 封禁用户评论服务: GET /advanced/banComment?userId=10001
    @RequestMapping("banComment")
    public SaResult banComment(Long userId) {
        StpUtil.disable(userId, "comment", 86400);  // 封禁1天
        return SaResult.ok("用户" + userId + "的评论功能已被封禁");
    }

    // 检查评论权限: GET /advanced/sendComment
    @SaCheckDisable("comment")
    @RequestMapping("sendComment")
    public SaResult sendComment() {
        return SaResult.ok("评论发送成功");
    }

    // 解封: GET /advanced/unban?userId=10001
    @RequestMapping("unban")
    public SaResult unban(Long userId) {
        StpUtil.untieDisable(userId, "comment");
        return SaResult.ok("用户" + userId + "的评论功能已解封");
    }

    // ===== 多账号(Admin体系) =====

    // Admin登录: GET /advanced/adminLogin
    @RequestMapping("adminLogin")
    public SaResult adminLogin() {
        StpUtil.login(10001);
        return SaResult.ok("Admin登录成功");
    }

    // Admin检查: GET /advanced/adminCheck
    @RequestMapping("adminCheck")
    public SaResult adminCheck() {
        return SaResult.ok("当前AdminId：" + StpUtil.getLoginId());
    }

    // ===== 身份切换(模拟他人) =====

    // 切换到用户10086操作: GET /advanced/switchTo?targetId=10086
    @RequestMapping("switchTo")
    public SaResult switchTo(Long targetId) {
        StpUtil.switchTo(targetId, () -> {
            System.out.println("模拟用户" + StpUtil.getLoginId() + "执行操作");
            // 在此lambda中，所有StpUtil操作都以targetId身份执行
        });
        return SaResult.ok("操作完成");
    }
}
```

---

> 配套配置参考：
> - [references/safe-auth.md](../references/safe-auth.md)
> - [references/disable.md](../references/disable.md)
> - [references/many-account.md](../references/many-account.md)
> - [references/mock-person.md](../references/mock-person.md)
