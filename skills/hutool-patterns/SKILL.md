---
name: hutool-patterns
description: |
  Hutool 中文 Java 工具库技能。覆盖与 Guava/Apache Commons 的功能选择矩阵、字符串/集合/日期/文件/HTTP 最常用方法速查、HttpUtil vs OkHttp 选型、BeanUtil vs MapStruct 职责划分。
  当用户在 Java 项目中需要中文场景的工具方法(拼音/身份证/手机号校验)、HTTP请求、文件操作、加解密时使用。避免 LLM 自造轮子而不用 Hutool。
license: Apache-2.0
---

# Hutool Java 工具库

> 来源：[https://doc.hutool.cn/](https://doc.hutool.cn/)  
> GitHub：[https://github.com/chinabugotech/hutool](https://github.com/chinabugotech/hutool)

## Capability Boundaries

### ✅ Strong Suits
1. **StrUtil** — format/空判断/截断/下划线驼峰互转、subBetween 截取中间文本
2. **CollUtil** — isEmpty/intersection/union/subtract/groupBy 集合操作
3. **DateUtil** — 日期格式化/解析(自动识别多格式)/偏移/时间差/计时器
4. **HttpUtil** — HTTP GET/POST/文件上传(简化 OkHttp/Apache HttpClient)
5. **JSONUtil** — 轻量 JSON 序列化(非高吞吐场景)
6. **SecureUtil** — MD5/SHA/AES/RSA/Base64 简化版
7. **IdcardUtil** — 身份证校验(支持15/18位)、提取生日/性别/年龄/省份
8. **Validator** — 手机号/邮箱/IP/身份证/URL 校验
9. **DesensitizedUtil** — 数据脱敏(手机号/身份证/银行卡/地址)
10. **ReUtil** — 正则匹配/提取/替换简化

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
| 集合操作 | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 手写身份证校验正则 30 行 | `IdcardUtil.isValidCard("440101...")` — 含校验位算法 |
| 2 | String.format() 用 `%s` 难读 | `StrUtil.format("Hello {}", name)` 命名占位更可读 |
| 3 | 手写日期格式转换/计算 | `DateUtil.parse(dateStr).offset(DateField.DAY_OF_MONTH, 7)` |
| 4 | Apache HttpClient 50行代码发GET | `HttpUtil.get(url)` 一行搞定 |
| 5 | isEmpty 判断空白字符串误判 | 用 `StrUtil.isBlank()` 替代 `isEmpty()` — 含空白判断 |
| 6 | 高并发场景也用 HttpUtil | 高并发用 OkHttp 连接池，HttpUtil 仅简单场景 |
| 7 | BeanUtil.copyProperties 替代 MapStruct | BeanUtil 是反射（运行时慢），MapStruct 是编译期生成（快） |
| 8 | JSONUtil 替代 Jackson | JSONUtil 仅轻量场景，生产 API 用 Jackson |
| 9 | `StrUtil.isEmpty("  ")` 返回 false | `StrUtil.isBlank("  ")` 返回 true |
| 10 | SimpleDateFormat 线程不安全 | `DateUtil.parse()` 线程安全，底层 ThreadLocal |

## 核心规则速查

```java
// ✅ 字符串—isBlank 优于 isEmpty
StrUtil.isBlank(null);    // true  ✅
StrUtil.isBlank("");      // true
StrUtil.isBlank("   ");   // true ← isEmpty 认为 false
StrUtil.isEmpty("   ");   // false ❌

// ✅ 字符串—命名占位比 %s 可读
StrUtil.format("Hello {}, 欢迎来到{}!", "张三", "上海");
StrUtil.format("你好, {name}, 欢迎来到{city}!",
    MapUtil.of("name", "张三", "city", "上海"));

// ✅ 字符串—截取中间文本
String content = StrUtil.subBetween("prefix_content_suffix", "prefix_", "_suffix"); // "content"
StrUtil.removePrefix("prefix_content", "prefix_");  // "content"
StrUtil.removeSuffix("content_suffix", "_suffix");  // "content"

// ✅ 字符串—分割（自动 trim、忽略空值）
List<String> parts = StrUtil.split("a,b, c ,d", ',', 0, true, true);
// => ["a", "b", "c", "d"]

// ✅ 日期—自动识别多种格式
DateUtil.parse("2025-08-04");          // yyyy-MM-dd
DateUtil.parse("2025/08/04 10:30:00"); // yyyy/MM/dd HH:mm:ss
DateUtil.parse("2025年08月04日");       // 中文日期

// ✅ 日期—计算与比较
DateUtil.offsetDay(new Date(), 7);       // 7天后
DateUtil.between(begin, end, DateUnit.DAY); // 间隔天数
DateUtil.beginOfMonth(new Date());       // 月初
DateUtil.endOfMonth(new Date());         // 月末

// ✅ HTTP—简单请求一行搞定
String result = HttpUtil.get("https://api.example.com/data");
HttpUtil.post(url, params);           // application/x-www-form-urlencoded
HttpUtil.post(url, jsonBody);         // JSON POST

// ✅ HTTP—链式调用(自定义Header/超时)
String result = HttpUtil.createPost(url)
    .header("Authorization", "Bearer xxx")
    .header("Content-Type", "application/json")
    .timeout(5000)  // 5秒超时
    .body(jsonBody)
    .execute()
    .body();

// ✅ 身份证—全套处理
IdcardUtil.isValidCard("440101199001011234");              // 校验含校验位
int age = IdcardUtil.getAgeByIdCard(idCard);               // 提取年龄
String gender = IdcardUtil.getGenderByIdCard(idCard);       // 1=男, 0=女
String birth = IdcardUtil.getBirthByIdCard(idCard);         // 19900101
String province = IdcardUtil.getProvinceByIdCard(idCard);   // 广东

// ✅ 数据脱敏
DesensitizedUtil.idCardNum(idCard, 1, 2);     // 440***********1234
DesensitizedUtil.mobilePhone("13800138000");   // 138****8000
DesensitizedUtil.email("test@example.com");    // t***@example.com

// ✅ 校验
Validator.isMobile("13800138000");
Validator.isEmail("test@example.com");
Validator.isCitizenId("440101199001011234");   // 轻量版身份证校验

// ✅ 集合
CollUtil.isEmpty(list);                    // 安全的判空(null或空集)
List<String> union = CollUtil.union(list1, list2);  // 并集
List<String> inter = CollUtil.intersection(list1, list2); // 交集
Map<String, List<User>> grouped = CollUtil.groupBy(users, User::getStatus); // 分组
```

## 核心模式

### 模式 1: 身份证校验三段式
```java
// 1. 快速格式校验 → 2. 完整校验位验证 → 3. 提取信息
if (Validator.isCitizenId(idCard)) {                  // 轻量正则
    if (IdcardUtil.isValidCard(idCard)) {              // 完整校验(含校验位)
        int age = IdcardUtil.getAgeByIdCard(idCard);
        String gender = IdcardUtil.getGenderByIdCard(idCard);
    }
}
```

### 模式 2: 缓存空值防护
```java
// 查询外部 API 时缓存空值，防止穿透
public String queryWeather(String city) {
    return cache.get(city, key -> {
        String result = HttpUtil.get("https://api.weather.com/" + city);
        if (StrUtil.isBlank(result)) {
            return "NULL_CACHE";  // 空值标记，缓存5分钟
        }
        return result;
    });
}
```

### 模式 3: 多条件字符串处理链
```java
String clean = StrUtil.trim(input);              // 去首尾空白
String named = StrUtil.toCamelCase(clean);       // 转驼峰
List<String> parts = StrUtil.split(named, ',');  // 按逗号分割
```

## Gotchas
1. **isBlank vs isEmpty** — isEmpty 不识别空白字符串(空格/tab/换行)
2. **HttpUtil 默认无连接池** — 高并发场景用 OkHttp，HttpUtil 适合简单场景
3. **JSONUtil 日期格式默认 yyyy-MM-dd HH:mm:ss** — 与 Jackson 不同
4. **BeanUtil.copyProperties 是浅拷贝** — 嵌套对象不拷贝(引用共享)
5. **SecureUtil.sha256() 返回 hex 字符串** — 不是 byte[]
6. **DateUtil.parse() 自动识别格式有时误判** — 明确格式用 parse(dateStr, "yyyy-MM-dd")
7. **IdcardUtil 仅支持中国大陆18/15位身份证** — 港澳台/外籍不支持
8. **Hutool 功能太多(500+类)** — 不要全部引入，按需使用子模块
9. **DateUtil.parse() 线程安全** — 底层 ThreadLocal 持有 SimpleDateFormat
10. **CollUtil.groupBy() 按字段分组** — 替代手写 Map 循环

## Data Privacy
本技能不收集、存储或传输任何用户数据。
