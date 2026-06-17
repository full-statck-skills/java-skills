# 登录参数详解

## 1. SaLoginParameter 完整参数

```java
StpUtil.login(10001, new SaLoginParameter()
    .setDeviceType("PC")                      // 此次登录的客户端设备类型，一般用于"同端互斥登录"
    .setDeviceId("xxxxxxxxx")                 // 此次登录的客户端设备ID
    .setIsLastingCookie(true)                 // 是否为持久Cookie（临时Cookie在浏览器关闭时会自动删除）
    .setTimeout(60 * 60 * 24 * 7)             // 指定此次登录token的有效期，单位:秒，-1=永久有效
    .setActiveTimeout(60 * 60 * 24 * 7)       // 指定此次登录token的最低活跃频率，单位:秒，-1=不检查
    .setIsConcurrent(true)                    // 是否允许同一账号多地同时登录
    .setIsShare(false)                        // 是否共用一个token
    .setMaxLoginCount(12)                     // 同一账号最大登录数量，-1不限
    .setMaxTryTimes(12)                       // 创建token最高循环次数
    .setExtra("key", "value")                 // 记录在Token上的扩展参数（只在jwt模式下生效）
    .setToken("xxxx-xxxx-xxxx-xxxx")          // 预定此次登录生成的Token
    .setIsWriteHeader(false)                  // 是否在登录后将Token写入响应头
    .setTerminalExtra("key", "value")         // 挂载到SaTerminalInfo的自定义扩展数据
    .setReplacedRange(SaReplacedRange.CURR_DEVICE_TYPE)  // 顶人下线的范围
    .setOverflowLogoutMode(SaLogoutMode.LOGOUT)          // 溢出处理方式
    .setRightNowCreateTokenSession(true)                 // 是否立即创建Token-Session
    .setupCookieConfig(cookie -> {                       // 设置Cookie配置项
        cookie.setDomain("sa-token.cc");
        cookie.setPath("/shop");
        cookie.setSecure(true);
        cookie.setHttpOnly(true);
        cookie.setSameSite("Lax");
        cookie.addExtraAttr("aa", "bb");
    })
);
```

> 以上大部分参数在未指定时将使用全局配置作为默认值。

## 2. SaLogoutParameter 注销参数

```java
// 当前客户端注销
StpUtil.logout(new SaLogoutParameter()
    .setRange(SaLogoutRange.TOKEN)    // TOKEN=只注销当前token，ACCOUNT=注销loginId所有客户端
);

// 指定 token 注销
StpUtil.logoutByTokenValue("xxxxxxxxxxxxxxxxxxxxxxx", new SaLogoutParameter()
    .setIsKeepFreezeOps(false)        // 冻结Token是否保留操作权
    .setIsKeepTokenSession(true)      // 是否保留Token-Session
);

// 指定 loginId 注销
StpUtil.logout(10001, new SaLogoutParameter()
    .setDeviceType("PC")              // 指定设备类型(不指定则注销所有客户端)
    .setIsKeepTokenSession(true)
    .setMode(SaLogoutMode.REPLACED)   // LOGOUT=注销、KICKOUT=踢人、REPLACED=顶人
);
```

## 3. 遍历登录终端

```java
@RequestMapping("logout")
public SaResult logout() {
    // 遍历账号 10001 已登录终端列表，进行详细操作
    StpUtil.forEachTerminalList(10001, (session, ter) -> {
        // 根据登录顺序，奇数的保留，偶数的下线
        if(ter.getIndex() % 2 == 0) {
            StpUtil.removeTerminalByLogout(session, ter);    // 注销下线
            // StpUtil.removeTerminalByKickout(session, ter); // 踢人下线
            // StpUtil.removeTerminalByReplaced(session, ter); // 顶人下线
        }
    });
    return SaResult.ok();
}
```

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/login-parameter.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/login-parameter.md)（108行）
