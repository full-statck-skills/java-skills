# 账号封禁

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/disable.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/disable.md)

## 1. 全账号封禁（禁止一切操作）

```java
StpUtil.disable(10001, 200);                  // 封禁200秒
StpUtil.isDisable(10001);                      // boolean
StpUtil.checkDisable(10001);                  // 封禁抛DisableServiceException
StpUtil.getDisableTime(10001);                // 剩余封禁时间(-1=永久,-2=未被封禁)
StpUtil.untieDisable(10001);                  // 解封
```

## 2. 分类封禁（按服务类型）

```java
StpUtil.disable(10001, "comment", 200);       // 封禁comment服务200秒
StpUtil.disable(10001, "order", 300);         // 封禁order服务300秒
StpUtil.isDisable(10001, "comment");           // 评论服务是否被封禁
StpUtil.checkDisable(10001, "comment");        // 校验
StpUtil.untieDisable(10001, "comment");        // 解封评论服务

// 注解方式
@SaCheckDisable("comment")
@RequestMapping("send")
public SaResult send() { return SaResult.ok(); }

// 支持多个业务标识
@SaCheckDisable({"comment", "order"})
```

## 3. 阶梯封禁（按等级）

```java
StpUtil.disableLevel(10001, "comment", 2, 200); // 将comment服务封禁到level=2
StpUtil.isDisableLevel(10001, "comment", 1);     // level>=1被封禁? true/false
StpUtil.checkDisableLevel(10001, "comment", 3);  // level>=3抛异常
StpUtil.getDisableLevel(10001, "comment");        // 获取等级(-2=未封禁)
```

## StpInterface 自定义封禁逻辑

```java
@Component
public class StpInterfaceImpl implements StpInterface {
    @Override
    public boolean isDisabled(Object loginId, String service) {
        // 从数据库查询封禁状态
        return false;
    }
}
```
