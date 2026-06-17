---
name: commons-patterns
description: |
  Apache Commons 最佳实践模式。从官方文档提炼，覆盖 Commons Lang3(StringUtils千面判空/isEmpty vs isBlank/Validate抛NullPointerException迁移)、Commons IO(IOUtils.toString大文件陷阱/FileUtils.lineIterator逐行读模式/FilenameUtils.normalize路径规范化)、Commons Collections4(CollectionUtils.union/intersection/subtract集合运算)。
  纠正 LLM 误用：混淆 StringUtils.isBlank vs isEmpty、IOUtils.toString 读大文件OOM、不知道 LineIterator 逐行读模式、用 lang 而非 lang3 包名。
license: Apache-2.0
---

# Apache Commons 最佳实践模式

> 来源: [Commons Home](https://commons.apache.org/) | [Lang3 User Guide](https://commons.apache.org/proper/commons-lang/) | [IO Description](https://commons.apache.org/proper/commons-io/description.html)

## Capability Boundaries

### ✅ Strong Suits
1. **StringUtils 判空模式** — isEmpty vs isBlank vs defaultString 精确语义选择
2. **Commons IO 文件操作** — FileUtils 读写复制 / IOUtils 流操作 / LineIterator 逐行
3. **Commons Collections4** — CollectionUtils/MultiValuedMap/MapUtils
4. **RandomStringUtils** — 生成随机字符串(验证码/Token/临时密码)
5. **Validate** — 参数校验(注意3.0起抛NullPointerException而非IllegalArgumentException)

### ❌ Out of Scope
1. 中文特色(身份证/拼音) → **hutool-patterns**
2. 不可变集合/缓存/EventBus → **guava-patterns**
3. Bean映射/JSON → **mapstruct-patterns**/**jackson-patterns**

## Commons vs Guava vs Hutool 选择表

| 场景 | Commons | Guava | Hutool | 优先选 |
|------|:-----:|:-----:|:-----:|--------|
| 字符串判空/截断/填充 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | 任意(团队约定) |
| 文件复制/删除/读行 | ⭐⭐⭐ | ⭐ | ⭐⭐ | **Commons IO** |
| 文件名/路径处理 | ⭐⭐⭐ | — | ⭐⭐ | **Commons IO** |
| 集合运算(交/并/差) | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | 任意 |
| 日期处理(旧Date) | ⭐ | — | ⭐⭐⭐ | **Java8 Time** |
| 随机字符串 | ⭐⭐⭐ | — | ⭐⭐ | **Commons Lang3** |
| HTML/XML转义 | ⭐⭐⭐ | — | ⭐ | **Commons Lang3** |
| 数学/统计 | ⭐⭐⭐ | — | ⭐ | **Commons Math** |

## 核心模式

### 模式 1: StringUtils 判空精确语义

```java
// ✅ isEmpty: null 或 "" → true (不含空格)
StringUtils.isEmpty(null);    // true
StringUtils.isEmpty("");      // true
StringUtils.isEmpty(" ");     // false ← 注意！
StringUtils.isEmpty("abc");   // false

// ✅ isBlank: null 或 空白字符 → true
StringUtils.isBlank(null);    // true
StringUtils.isBlank("");      // true
StringUtils.isBlank(" ");     // true ← 含空格也true
StringUtils.isBlank("abc");   // false

// ✅ 选择规则: 表单验证用isBlank(不接受空白输入)，集合判空用isEmpty

// ✅ defaultString: null安全取值
StringUtils.defaultString(str, "");         // null → ""
StringUtils.defaultIfBlank(str, "N/A");     // null/""/" " → "N/A"

// ✅ 填充与截断
StringUtils.leftPad("1", 3, '0');           // "001"
StringUtils.abbreviate("very long text", 10); // "very lo..."
```

### 模式 2: Commons IO 文件模式

```java
// ✅ 读取整个文件(小文件，<10MB)
String content = FileUtils.readFileToString(file, StandardCharsets.UTF_8);
List<String> lines = FileUtils.readLines(file, StandardCharsets.UTF_8);

// ✅ 逐行读(大文件) — LineIterator 模式
LineIterator it = FileUtils.lineIterator(file, "UTF-8");
try { while (it.hasNext()) { String line = it.nextLine(); /* 处理 */ }
} finally { LineIterator.closeQuietly(it); }

// ✅ 流操作(需手动关流)
InputStream in = new URL("https://example.com").openStream();
try { String result = IOUtils.toString(in, StandardCharsets.UTF_8); }
finally { IOUtils.closeQuietly(in); }

// ❌ 反模式: IOUtils.toString() 读 1GB 文件 → 尝试创建1GB String → OOM

// ✅ 写入/复制/删除
FileUtils.writeStringToFile(file, content, StandardCharsets.UTF_8);
FileUtils.copyFile(src, dest);
FileUtils.forceMkdir(dir);          // 递归创建目录
FileUtils.deleteDirectory(dir);      // 递归删除

// ✅ 文件名处理
FilenameUtils.getExtension("archive.tar.gz");  // "gz" (最后一个.)
FilenameUtils.getBaseName("/path/file.txt");   // "file"
String normalized = FilenameUtils.normalize("C:/a/../b/file.txt"); // "C:/b/file.txt"
```

### 模式 3: Commons Lang3 迁移注意事项

```java
// ❌ 旧包名 — 不要用
import org.apache.commons.lang.StringUtils;

// ✅ 新包名(3.0+) — 必须用
import org.apache.commons.lang3.StringUtils;

// Maven坐标
// groupId: commons-lang → org.apache.commons
// artifactId: commons-lang → commons-lang3
```

### 模式 4: Validate 的参数校验

```java
// ⚠️ Commons Lang 3.0 变化: Validate 校验 null 抛 NullPointerException
// (对齐JDK标准行为，以前抛 IllegalArgumentException)
Validate.notNull(obj, "参数不能为空: %s", name);   // 抛 NPE
Validate.isTrue(age > 0, "年龄必须>0");             // 抛 IllegalArgumentException
// 注意：验证null用Validate.notNull，验证状态用Validate.isTrue
```

### 模式 5: RandomStringUtils

```java
// ✅ 随机字母数字(验证码/Token)
RandomStringUtils.randomAlphanumeric(6);      // "a3Bx9K"
RandomStringUtils.randomAlphanumeric(32);     // 32位Token
// ✅ 随机数字
RandomStringUtils.randomNumeric(6);           // "482931"
// ✅ 随机字母
RandomStringUtils.randomAlphabetic(8);        // "AbCdEfGh"
```

### 模式 6: 集合运算

```java
// ⚠️ 包名: org.apache.commons.collections4 (不是 collections)
CollectionUtils.isEmpty(coll);
CollectionUtils.union(list1, list2);          // 并集
CollectionUtils.intersection(list1, list2);   // 交集
CollectionUtils.subtract(list1, list2);       // 差集(list1 - list2)

MapUtils.getString(map, "key", "default");    // null安全取值
```

## Gotchas
1. **isEmpty vs isBlank** — isEmpty(" ")→true(不含空格)，isBlank(" ")→true(含空格)
2. **IOUtils.toString 加载整个流到内存** — 大文件(>10MB)用 LineIterator 逐行读
3. **IOUtils.toString 不关流** — 配合 finally { IOUtils.closeQuietly(in) }
4. **Lang3 DateUtils 与 Java8 LocalDateTime 不兼容** — 用 java.time API，仅旧Date用Commons
5. **Collections4 包名是 collections4** — 不是 collections(那是3.x)
6. **Lang3 3.0 起 isAlpha/isNumeric/isAlphanumeric("")→false** — 以前版本返回true
7. **Maven坐标: groupId=org.apache.commons, artifactId=commons-lang3** — 不是 commons-lang
8. **Validate.notNull 抛 NullPointerException** — Validate.isTrue 抛 IllegalArgumentException

## Data Privacy
本技能不收集、存储或传输任何用户数据。
