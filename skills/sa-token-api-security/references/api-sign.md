# API 参数签名

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-sign.md)（591行）

## 防重放攻击四步演进

```text
1. 直接裸奔 → 接口任何人都可调用
2. 固定secretKey → 密钥泄露风险，参数可篡改
3. sign摘要 → 参数不可篡改，但可重放
4. nonce+timestamp+sign → 防重放最终方案
```

## 依赖

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-sign</artifactId>
    <version>1.45.0</version>
</dependency>
```

## 配置秘钥

```yaml
sa-token:
  sign:
    secret-key: kQwIOrYvnXmSDkwEiFngrKidMcdrgKor   # 签名秘钥
    timestamp-disparity: 900000                      # 时间戳允许差距(ms)
    digest-algo: md5                                 # 摘要算法
```

## 请求端构建签名

```java
Map<String, Object> paramMap = new LinkedHashMap<>();
paramMap.put("userId", 10001);
paramMap.put("money", 1000);
String paramStr = SaSignUtil.addSignParamsAndJoin(paramMap);
url += "?" + paramStr;
// 生成的URL: /addMoney?userId=10001&money=1000&nonce=xxx&timestamp=xxx&sign=xxx
```

## 接收端校验

```java
// 方法调用
@RequestMapping("addMoney")
public SaResult addMoney(long userId, long money) {
    SaSignUtil.checkRequest(SaHolder.getRequest());
    return SaResult.ok();
}

// 注解方式
@SaCheckSign
@RequestMapping("addMoney")
public SaResult addMoney(long userId, long money) { return SaResult.ok(); }
```

校验顺序：①时间差检查 ②nonce重复性检查 ③签名一致性检查

## 多应用模式

```yaml
sa-token:
  sign:
    many:
      app1: { secret-key: app1Secret, digest-algo: sha256 }
      app2: { secret-key: app2Secret, digest-algo: sha512 }
```

```java
SaSignTemplate template = SaSignMany.getSignTemplate("appId");
template.checkRequest(SaHolder.getRequest());
```
