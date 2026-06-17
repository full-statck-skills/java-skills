# 身份切换（模拟他人）

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mock-person.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mock-person.md)

## API

```java
// 切换到指定账号
StpUtil.switchTo(10044);

// 当前是否在切换状态中
StpUtil.isSwitch();                      // true

// 获取正在被模拟的账号id
StpUtil.getSwitchLoginId();

// 结束切换
StpUtil.endSwitch();

// Lambda作用域切换(推荐)
StpUtil.switchTo(10044, () -> {
    // 在此lambda内，StpUtil的一切操作都以10044身份进行
    System.out.println(StpUtil.getLoginId()); // 10044
    StpUtil.getSession().set("key", "value");
    System.out.println(StpUtil.hasPermission("user.add"));
});
// lambda外恢复正常身份
```
