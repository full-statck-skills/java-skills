# Token 风格 & 前缀

## 内置 Token 风格

通过 `sa-token.token-style=风格类型` 配置：

```yaml
sa-token:
  token-style: uuid              # UUID风格(默认): 623368f0-ae5e-4475-a53f-93e4225f16ae
  # token-style: simple-uuid    # 无中划线: 6fd4221395024b5f87edd34bc3258ee8
  # token-style: random-32      # 32位: qEjyPsEA1Bkc9dr8YP6okFr5umCZNR6W
  # token-style: random-64      # 64位: v4ueNLEpPwMtmOPMBtOOeIQsvP8z9gkM...
  # token-style: random-128     # 128位: nojYPmcEtrFEaN0Otpssa8I8jpk8FO53...
  # token-style: tik            # tik风格: gr_SwoIN0MC1ewxHX_vfCW3BothWDZMMtx__
```

## 自定义 Token 生成策略

重写 `SaStrategy` 策略类的 `createToken` 算法：

1. 在 `SaTokenConfigure` 配置类中添加代码：

```java
@Configuration
public class SaTokenConfigure {
    @PostConstruct
    public void rewriteSaStrategy() {
        SaStrategy.instance.createToken = (loginId, loginType) -> {
            return SaFoxUtil.getRandomString(60);  // 随机60位长度字符串
        };
    }
}
```

2. 再次调用 `StpUtil.login(10001)` 登录，观察生成的 token 样式：
```
gfuPSwZsnUhwgz08GTCH4wOgasWtc3odP4HLwXJ7NDGOximTvT4OlW19zeLH
```

> ⚠️ 更改了 token 生成策略但是不生效？把 Redis 中的旧数据清除掉再试试。

## Token 提交前缀

某些系统中，前端提交 token 时会在前面加个固定的前缀，例如 `Bearer xxxx-xxxx-xxxx-xxxx`。

此时后端需要配置：
```yaml
sa-token:
  token-prefix: Bearer
```

Sa-Token 在读取 Token 时自动裁剪掉 `Bearer`，成功获取 `xxxx-xxxx-xxxx-xxxx`。

> **Token 前缀与 Token 值之间必须有一个空格**

### Cookie 模式自动填充前缀

由于 Cookie 中无法存储空格字符，配置 Token 前缀后 Cookie 模式会失效。使用 `cookieAutoFillPrefix` 配置项解决：

```yaml
sa-token:
  cookie-auto-fill-prefix: true
```

---

> 来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-style.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-style.md)（68行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-prefix.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/token-prefix.md)（57行）
