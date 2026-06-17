---
name: hutool
description: |
  Hutool 中文 Java 工具库技能。覆盖与 Guava/Apache Commons 的功能选择矩阵、字符串/集合/日期/文件/HTTP 最常用方法速查、HttpUtil vs OkHttp 选型、BeanUtil vs MapStruct 职责划分。
  当用户在 Java 项目中需要中文场景的工具方法(拼音/身份证/手机号校验)、HTTP请求、文件操作、加解密时使用。避免 LLM 自造轮子而不用 Hutool。
license: Apache-2.0
---

# Hutool Java 工具库

> 编码 Hutool 的使用规则。Hutool 覆盖极广，LLM 容易"用错方式"或"不知道存在"。

## Capability Boundaries

### ✅ Strong Suits
1. **StrUtil** — format/空判断/截断/下划线驼峰互转
2. **CollUtil** — isEmpty/intersection/union/subtract 集合操作
3. **DateUtil** — 日期格式化(yyyy-MM-dd HH:mm:ss)/偏移/时间差计算
4. **HttpUtil** — HTTP GET/POST/文件上传(简化 OkHttp/Apache HttpClient)
5. **JSONUtil** — 轻量 JSON 序列化(非高吞吐场景)
6. **SecureUtil** — MD5/SHA/AES/RSA/Base64 简化版
7. **IdcardUtil** — 身份证校验、提取生日/性别
8. **Validator** — 手机号/邮箱/IP 地址校验

### ❌ Out of Scope
1. 高性能 JSON → 用 **Jackson**/Fastjson2(Spring Boot 默认)
2. HTTP 高并发 → 用 **OkHttp** 连接池
3. Bean 映射 → 用 **MapStruct** 编译期生成
4. 分布式锁 → 用 **Redisson**

## 工具选择矩阵

| 场景 | Hutool | Guava | Apache Commons | Java 标准库 |
|------|:-----:|:-----:|:--------------:|:----------:|
| 字符串处理 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| 日期处理 | ⭐⭐⭐ | — | ⭐ | ⭐⭐ |
| HTTP客户端 | ⭐⭐⭐(简单) | — | ⭐⭐ | ⭐⭐ |
| 身份证/手机号 | ⭐⭐⭐ | — | ⭐⭐ | — |
| 加解密 | ⭐⭐ | — | ⭐ | — |
| 文件操作 | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| JSON | ⭐⭐ | — | — | — |

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 手写身份证校验正则 | `IdcardUtil.isValidCard("440101...")` |
| 2 | 手写日期格式转换/计算 | `DateUtil.parse(dateStr).offset(DateField.DAY_OF_MONTH, 7)` |
| 3 | Apache HttpClient 50行代码发GET | `HttpUtil.get(url)` 一行搞定 |
| 4 | 高并发场景也用 HttpUtil | 高并发用 OkHttp 连接池，HttpUtil 仅简单场景 |
| 5 | BeanUtil.copyProperties 替代 MapStruct | BeanUtil 是反射（运行时慢），MapStruct 是编译期生成（快） |
| 6 | JSONUtil 替代 Jackson | JSONUtil 仅轻量场景，生产 API 用 Jackson |

## 核心规则速查

```java
// ✅ 字符串
StrUtil.format("Hello {}", "world");       // Hello world
StrUtil.toCamelCase("user_name");         // userName
StrUtil.toUnderlineCase("userName");      // user_name

// ✅ 日期
DateUtil.parse("2024-03-15 10:30:00");   // 自动识别格式
DateUtil.offsetDay(new Date(), 7);         // 7天后
DateUtil.between(begin, end, DateUnit.DAY); // 间隔天数

// ✅ HTTP
String result = HttpUtil.get("https://api.example.com/data");
HttpUtil.post(url, params);                // application/x-www-form-urlencoded
HttpUtil.post(url, jsonBody);              // JSON POST

// ✅ 身份证
IdcardUtil.isValidCard("440101199001011234");  // 校验
int age = IdcardUtil.getAgeByIdCard(idCard);   // 提取年龄
String gender = IdcardUtil.getGenderByIdCard(idCard); // 提取性别

// ✅ 校验
Validator.isMobile("13800138000");
Validator.isEmail("test@example.com");
```

## Gotchas
1. **HttpUtil 默认无连接池** — 高并发场景用 OkHttp
2. **JSONUtil 日期格式默认 yyyy-MM-dd HH:mm:ss** — 与 Jackson 不同
3. **BeanUtil.copyProperties 是浅拷贝** — 嵌套对象不拷贝
4. **SecureUtil.sha256() 返回 hex 字符串** — 不是 byte[]
5. **DateUtil.parse() 自动识别格式有时误判** — 明确格式用 parse(dateStr, "yyyy-MM-dd")
6. **IdcardUtil 仅支持中国大陆18位身份证** — 港澳台/外籍不支持
7. **Hutool 功能太多(500+类)** — 不要全部引入，按需使用子模块

## Data Privacy
本技能不收集、存储或传输任何用户数据。
