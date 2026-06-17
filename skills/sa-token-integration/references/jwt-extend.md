# JWT 集成三种模式

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/jwt-extend.md)（247行）

## 三种模式对比表

| 功能点 | Simple | Mixin | Stateless |
|--------|:------:|:-----:|:---------:|
| Token风格 | jwt | jwt | jwt |
| 登录数据存储 | Redis中 | Token中 | Token中 |
| Session存储 | Redis中 | Redis中 | 无Session |
| 注销下线 | 前后端双清 | 前后端双清 | 前端清除 |
| 踢人下线API | ✅ | ❌ | ❌ |
| 顶人下线API | ✅ | ❌ | ❌ |
| timeout有效期 | ✅ | ✅ | ✅ |
| active-timeout | ✅ | ✅ | ❌ |
| id反查Token | ✅ | ✅ | ❌ |
| 会话管理 | ✅ | 部分支持 | ❌ |
| 账号封禁 | ✅ | ✅ | ❌ |
| 身份切换 | ✅ | ✅ | ✅ |
| 二级认证 | ✅ | ✅ | ✅ |
| **模式总结** | **推荐(Token风格替换)** | 混入部分逻辑 | 完全无状态 |

## 依赖+配置

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-jwt</artifactId>
    <version>1.45.0</version>
</dependency>
```

```yaml
sa-token:
  jwt-secret-key: asdasdasifhueuiwyurfewbfjsdafjk
```

## 注入

```java
@Configuration
public class SaTokenConfigure {
    // Simple模式(推荐)
    @Bean
    public StpLogic getStpLogicJwt() { return new StpLogicJwtForSimple(); }

    // Mixin模式
    // @Bean
    // public StpLogic getStpLogicJwt() { return new StpLogicJwtForMixin(); }

    // Stateless模式
    // @Bean
    // public StpLogic getStpLogicJwt() { return new StpLogicJwtForStateless(); }
}
```

## 扩展参数

```java
StpUtil.login(10001, new SaLoginParameter()
    .setExtra("name", "zhangsan")
    .setExtra("role", "超级管理员"));
String name = StpUtil.getExtra("name");
String role = StpUtil.getExtra("tokenValue", "name"); // 指定Token获取
```

## 注意点
1. Simple模式 `is-share` 恒等于false（与Extra数据不兼容）
2. Mixin模式 `is-concurrent` 必须为true
3. Mixin模式 `max-try-times` 恒等于-1
