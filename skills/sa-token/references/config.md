# 框架配置

## 配置方式

### 方式1：application.yml

```yaml
############## Sa-Token 配置 (文档: https://sa-token.cc) ##############
sa-token:
  # token 名称（同时也是 cookie 名称、数据持久化前缀）
  token-name: satoken
  # token 有效期（单位：秒） 默认30天，-1 代表永久有效
  timeout: 2592000
  # token 最低活跃频率（单位：秒），-1 代表不限制，永不冻结
  active-timeout: -1
  # 是否允许同一账号多地同时登录（true=允许，false=新登录挤掉旧登录）
  is-concurrent: true
  # 多人登录同一账号时，是否共用一个 token
  is-share: false
  # token 风格（uuid、simple-uuid、random-32、random-64、random-128、tik）
  token-style: uuid
  # 是否输出操作日志
  is-log: true
```

### 方式2：代码配置

**模式1**（会覆盖 application.yml 中的配置）：
```java
@Configuration
public class SaTokenConfigure {
    @Bean
    @Primary
    public SaTokenConfig getSaTokenConfigPrimary() {
        SaTokenConfig config = new SaTokenConfig();
        config.setTokenName("satoken");
        config.setTimeout(30 * 24 * 60 * 60);
        config.setActiveTimeout(-1);
        config.setIsConcurrent(true);
        config.setIsShare(false);
        config.setTokenStyle("uuid");
        config.setIsLog(false);
        return config;
    }
}
```

**模式2**（会与 application.yml 中的配置合并，代码配置优先）：
```java
@Configuration
public class SaTokenConfigure {
    @Autowired
    public void configSaToken(SaTokenConfig config) {
        config.setTokenName("satoken");
        config.setTimeout(30 * 24 * 60 * 60);
        config.setIsLog(true);
    }
}
```

两者的区别：模式1覆盖yml，模式2与yml合并（代码优先）。

## 核心模块完整配置项

| 参数名称 | 类型 | 默认值 | 说明 |
|----------|------|--------|------|
| tokenName | String | satoken | Token名称(Cookie名称、数据持久化前缀) |
| timeout | long | 2592000 | Token有效期(秒)，-1永久 |
| activeTimeout | long | -1 | Token最低活跃频率(秒)，-1不限制 |
| dynamicActiveTimeout | Boolean | false | 是否启用动态activeTimeout |
| isConcurrent | Boolean | true | 是否允许并发登录 |
| isShare | Boolean | false | 是否共用一个token |
| replacedLoginExitMode | String | OLD_DEVICE | 顶人时(旧设备下线/新设备登录成功, 或新设备失败/旧设备维持) |
| replacedRange | String | CURR_DEVICE_TYPE | 顶人范围(当前设备类型/所有设备类型) |
| maxLoginCount | int | 12 | 同一账号最大登录数量(isConcurrent=true,isShare=false时有效) |
| overflowLogoutMode | String | LOGOUT | 溢出处理(LOGOUT/KICKOUT/REPLACED) |
| maxTryTimes | int | 12 | 创建Token最高循环次数(-1=不重试) |
| isReadBody | Boolean | true | 从请求体读Token |
| isReadHeader | Boolean | true | 从header读Token |
| isReadCookie | Boolean | true | 从cookie读Token |
| isLastingCookie | Boolean | true | 是否为持久Cookie |
| isWriteHeader | Boolean | false | 登录后将Token写入响应头 |
| logoutRange | String | TOKEN | 注销范围(TOKEN/ACCOUNT) |
| isLogoutKeepFreezeOps | Boolean | false | 冻结Token是否保留操作权 |
| isLogoutKeepTokenSession | Boolean | false | 注销后保留Token-Session |
| rightNowCreateTokenSession | Boolean | false | 登录时立即创建Token-Session |
| tokenStyle | String | uuid | token风格 |
| dataRefreshPeriod | int | 30 | 清理过期数据间隔(秒) |
| tokenSessionCheckLogin | Boolean | true | Token-Session需登录 |
| autoRenew | Boolean | true | 自动续签 |
| tokenPrefix | String | null | token前缀(如Bearer) |
| cookieAutoFillPrefix | Boolean | false | Cookie自动填充前缀 |
| isPrint | Boolean | true | 打印版本字符画 |
| isLog | Boolean | false | 打印操作日志 |
| logLevel | String | trace | 日志等级 |
| jwtSecretKey | String | null | JWT秘钥 |
| sameTokenTimeout | long | 86400 | Same-Token有效期(秒) |
| basic | String | "" | Http Basic账号密码 |
| cookie | Object | new SaCookieConfig() | Cookie配置对象 |
| sign | Object | new SaSignConfig() | API签名配置对象 |

## Cookie 配置

| 参数名称 | 类型 | 默认值 | 说明 |
|----------|------|--------|------|
| domain | String | null | 作用域(SSO二级域名共享Cookie) |
| path | String | / | 路径 |
| secure | Boolean | false | 仅HTTPS |
| httpOnly | Boolean | false | 禁止JS操作Cookie |
| sameSite | String | Lax | 第三方限制(Strict/Lax/None) |
| extraAttrs | String | LinkedHashMap | 额外扩展属性 |

示例：
```yaml
sa-token:
  cookie:
    domain: stp.com
    path: /
    httpOnly: true
    sameSite: Lax
    extraAttrs:
      Priority: Medium
      Partitioned: ""
```

## Sign 参数签名配置

| 参数名称 | 类型 | 默认值 | 说明 |
|----------|------|--------|------|
| secretKey | String | null | API签名秘钥 |
| timestampDisparity | long | 900000 | 时间戳允许差距(ms)，-1不校验 |
| digestAlgo | String | md5 | 摘要算法 |

示例：
```yaml
sa-token:
  sign:
    secret-key: kQwIOrYvnXmSDkwEiFngrKidMcdrgKor
```

## API Key 配置

| 参数名称 | 类型 | 默认值 | 说明 |
|----------|------|--------|------|
| prefix | String | AK- | API Key前缀 |
| timeout | long | 2592000 | API Key有效期(秒) |
| isRecordIndex | String | true | 是否记录索引信息 |

示例：
```yaml
sa-token:
  api-key:
    prefix: AK-
    timeout: 2592000
```

## 配置项详解

### maxLoginCount

同一账号最大登录数量。在 `isConcurrent=true`, `isShare=false` 时，每次登录都会产生一个新Token，记录在 Account-Session 上。上线设为12，超过时主动注销第一个登录的会话（先进先出）。

### tokenSessionCheckLogin

获取 Token-Session 时是否必须登录。`StpUtil.getTokenSession()` 会检测 Token 是否有效，如果无效则抛出异常。需要登录前使用 Token-Session 时改为 `false`。

### isHttp

SSO模式配置。false=模式二(Redis校验ticket)，true=模式三(Http请求校验ticket)。

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/config.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/config.md)（592行）
