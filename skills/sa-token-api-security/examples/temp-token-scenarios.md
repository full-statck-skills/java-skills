# 临时Token 多种场景示例

> 来源: 官方 demo `TempTokenController` + `plugin/temp-token.md`

```java
@RestController
@RequestMapping("/temp-token/")
public class TempTokenController {

    // 1) 创建并解析: GET /temp-token/create
    @RequestMapping("create")
    public SaResult create() {
        String token = SaTempUtil.createToken(10001, 1200);
        System.out.println("创建成功：" + token);
        return SaResult.data(token);
    }

    // 2) 前缀裁剪: GET /temp-token/create2
    @RequestMapping("create2")
    public SaResult create2() {
        String token = SaTempUtil.createToken("shop_1001", 1200);
        System.out.println("原始值: " + SaTempUtil.parseToken(token));
        System.out.println("裁剪前缀: " + SaTempUtil.parseToken(token, "shop_", Long.class));
        System.out.println("错误前缀: " + SaTempUtil.parseToken(token, "art_", Long.class));
        return SaResult.data(token);
    }

    // 3) 创建并删除: GET /temp-token/create3
    @RequestMapping("create3")
    public SaResult create3() {
        String token = SaTempUtil.createToken(10003, 1200);
        System.out.println("创建后获取: " + SaTempUtil.parseToken(token));
        SaTempUtil.deleteToken(token);
        System.out.println("删除后获取: " + SaTempUtil.parseToken(token));
        return SaResult.data(token);
    }

    // 4) 记录索引并反查: GET /temp-token/create4
    @RequestMapping("create4")
    public SaResult create4() {
        String token1 = SaTempUtil.createToken(10004, 1200, true);
        String token2 = SaTempUtil.createToken(10004, 1300, true);
        String token3 = SaTempUtil.createToken(10004, -1, true);

        System.out.println("token1 剩余: " + SaTempUtil.getTimeout(token1));
        System.out.println("token2 剩余: " + SaTempUtil.getTimeout(token2));
        System.out.println("token3 剩余: " + SaTempUtil.getTimeout(token3));

        SaTempUtil.deleteToken(token3);

        // 反查所有token
        List<String> list = SaTempUtil.getTempTokenList(10004);
        System.out.println("10004的所有token: " + list);
        return SaResult.data(token1);
    }

    // 5) 实际应用: 邀请链接
    @RequestMapping("invite")
    public SaResult invite(Long userId) {
        String token = SaTempUtil.createToken(userId, 600);  // 10分钟有效
        String inviteUrl = "http://example.com/register?token=" + token;
        return SaResult.data(inviteUrl);
    }

    // 6) 通过邀请链接注册
    @RequestMapping("register")
    public SaResult register(String token) {
        Long userId = SaTempUtil.parseToken(token, Long.class);
        if (userId == null) {
            return SaResult.error("邀请链接无效或已过期");
        }
        return SaResult.ok("注册成功，邀请人：" + userId);
    }
}
```

---

> 来源:
> - [TempTokenController.java](https://github.com/dromara/sa-token/blob/dev/sa-token-demo/sa-token-demo-case/src/main/java/com/pj/cases/plugin/TempTokenController.java)
> - [temp-token.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md)
