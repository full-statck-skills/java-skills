# 同端互斥登录

## 概念

像腾讯QQ一样：可以手机电脑同时在线，但是不能在两个手机上同时登录一个账号。即**同一类型设备上只允许单地点登录，在不同类型设备上允许同时在线。**

## 配置

```yaml
sa-token:
  is-concurrent: false          # 关闭并发登录
```

## 指定设备类型登录

```java
// 指定账号id和设备类型进行登录
StpUtil.login(10001, "PC");
```

调用此方法登录后，同设备的会被顶下线（不同设备不受影响），再次访问系统时会抛出 `NotLoginException` 异常，场景值=`-4`。

## 指定设备类型强制注销

```java
// 指定账号id和设备类型进行强制注销
StpUtil.logout(10001, "PC");
```

如果第二个参数填写 null 或不填，代表将这个账号id所有在线端强制注销，被踢出者再次访问系统时会抛出 `NotLoginException` 异常，场景值=`-2`。

## 查询当前登录的设备类型

```java
// 返回当前token的登录设备类型
StpUtil.getLoginDevice();
```

## Id 反查 Token

```java
// 获取指定loginId指定设备类型端的tokenValue
StpUtil.getTokenValueByLoginId(10001, "APP");
```

## 其他相关 API

```java
// 获取指定账号的终端列表
StpUtil.getTerminalListByLoginId(10001);
StpUtil.getTerminalListByLoginId(10001, "PC");

// 遍历终端
StpUtil.forEachTerminalList(10001, (session, ter) -> {
    System.out.println(ter.getDevice());
    System.out.println(ter.getToken());
});
```

## 相关配置项

```yaml
sa-token:
  # 顶人时：OLD_DEVICE=旧设备下线/新设备成功，NEW_DEVICE=新设备失败/旧设备维持
  replaced-login-exit-mode: OLD_DEVICE
  # 顶人范围：CURR_DEVICE_TYPE=当前设备类型，ALL_DEVICE_TYPE=所有类型
  replaced-range: CURR_DEVICE_TYPE
```

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mutex-login.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/mutex-login.md)（51行）
