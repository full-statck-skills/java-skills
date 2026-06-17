# 临时 Token

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/temp-token.md)（120行）

## 适用场景

短期有效授权（5分钟/半小时）、超链接邀请机制、替代明文ID防止伪造。

## 核心API（内嵌核心包，无需额外依赖）

```java
// 创建
String token = SaTempUtil.createToken("10014", 200);    // value+有效期秒

// 解析
String value = SaTempUtil.parseToken(token, String.class);

// 剩余有效期
SaTempUtil.getTimeout(token);

// 删除
SaTempUtil.deleteToken(token);
```

## 前缀裁剪

为不同业务线加前缀区分：

```java
String token = SaTempUtil.createToken("shop_1001", 200);
Long value = SaTempUtil.parseToken(token, "shop_", Long.class); // 1001
Long wrong = SaTempUtil.parseToken(token, "user_", Long.class); // null
```

## 反向查询

```java
String token = SaTempUtil.createToken(10004, 1200, true);  // 开启反查
List<String> list = SaTempUtil.getTempTokenList(10004);
```

## JWT集成

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-temp-jwt</artifactId>
    <version>1.45.0</version>
</dependency>
```
```yaml
sa-token:
  jwt-secret-key: JfdDSgfCmPsDfmsAaQwnXk
```
引入后上层API保持不变。
