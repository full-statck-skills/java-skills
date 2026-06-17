---
name: commons
description: |
  Apache Commons 核心工具库技能。覆盖 Lang3(StringUtils/ObjectUtils/RandomStringUtils等)/IO(FileUtils/IOUtils/FilenameUtils)/Collections4(集合操作)三件套的常用方法速查、与Guava功能重叠如何选择决策表。
  当用户手写工具方法替代Apache Commons时使用。避免LLM不知道这些工具类的存在。
license: Apache-2.0
---

# Apache Commons 核心工具库

> 编码 Commons 的选择规则。LLM 不知道 Commons 存在，自己写 FileUtils 和 StringUtils。

## Capability Boundaries

### ✅ Strong Suits
1. **Commons Lang3** — StringUtils/ObjectUtils/RandomStringUtils/DateUtils/Validate
2. **Commons IO** — FileUtils/IOUtils/FilenameUtils 文件操作
3. **Commons Collections4** — 集合工具与增强(MapUtils/SetUtils/IterableUtils)

### ❌ Out of Scope
1. 中文特色工具(身份证/拼音/HTTP简约) → **Hutool**
2. 不可变集合/缓存/EventBus → **Guava**
3. Bean映射/JSON → **MapStruct**/**Jackson**

## Commons vs Guava vs Hutool 选择表

| 场景 | Commons | Guava | Hutool | Java 标准库 |
|------|:-----:|:-----:|:-----:|:----------:|
| 字符串判空/截断/填充 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| 文件复制/删除/读行 | ⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ |
| 文件名/扩展名处理 | ⭐⭐⭐ | — | ⭐⭐ | ⭐ |
| 集合增强操作 | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| 日期处理 | ⭐ | — | ⭐⭐⭐ | ⭐⭐ |
| 中文场景 | — | — | ⭐⭐⭐ | — |
| 数学/统计 | ⭐⭐⭐ | — | ⭐ | ⭐ |

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `if (str != null && str.length() > 0)` | `StringUtils.isNotEmpty(str)` |
| 2 | 手写 `new File(path).mkdirs()` | `FileUtils.forceMkdir(new File(path))` |
| 3 | `str == null ? "" : str` | `ObjectUtils.defaultIfNull(str, "")` |
| 4 | 手写文件复制(InputStream/OutputStream) | `FileUtils.copyFile(src, dest)` |
| 5 | 手写随机字符串 | `RandomStringUtils.randomAlphanumeric(32)` |

## 核心规则速查

```java
// ✅ Commons Lang3
StringUtils.isBlank(str);                    // null/""/" " → true
StringUtils.defaultString(str, "");          // null → ""
StringUtils.leftPad("1", 3, '0');           // "001"
StringUtils.join(list, ",");                // "a,b,c"
RandomStringUtils.randomAlphanumeric(32);   // 随机32位字母数字
ObjectUtils.defaultIfNull(obj, defaultVal);  // null → 默认值
ObjectUtils.firstNonNull(a, b, c);          // 返回第一个非null
Validate.notNull(obj, "参数不能为空");       // Guava Preconditions 同义

// ✅ Commons IO
FileUtils.readFileToString(file, StandardCharsets.UTF_8);
FileUtils.writeStringToFile(file, content, StandardCharsets.UTF_8);
FileUtils.copyFile(srcFile, destFile);
FileUtils.deleteDirectory(dir);
IOUtils.toString(inputStream, StandardCharsets.UTF_8);
FilenameUtils.getExtension("file.txt");  // "txt"
FilenameUtils.getBaseName("/path/file.txt"); // "file"

// ✅ Commons Collections4
CollectionUtils.isEmpty(coll);
CollectionUtils.union(list1, list2);
CollectionUtils.intersection(list1, list2);
MapUtils.getString(map, "key", "default");
```

## Gotchas
1. **StringUtils.isBlank 和 isEmpty 不同** — isBlank 包含空格字符串
2. **FileUtils 操作会抛 IOException** — 需要 try-catch 或 throw
3. **Commons Lang3 的 DateUtils 与 Java8 LocalDateTime 不兼容** — 用 Java8 Time API
4. **Commons Collections4 包名是 org.apache.commons.collections4** — 不是 collections
5. **IOUtils.toString 不自动关闭流** — 用 try-with-resources
6. **StringUtils 和 Hutool 的 StrUtil 功能重叠** — 团队约定用一个，两个都导入会混乱

## Data Privacy
本技能不收集、存储或传输任何用户数据。
