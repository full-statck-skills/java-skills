# 模板语法完整参考

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill

## 1. 占位符规则

| 模板占位符 | 含义 | Java 数据 |
|------------|------|----------|
| `{name}` `{number}` `{date}` | 单值 | `Map.put("name", value)` 或 DTO 字段 |
| `{.}` | 列表（默认纵向） | `List<DTO>` 整体作为 fill 第一个参数 |
| `{data1.}` `{data2.}` | 带前缀列表 | `new FillWrapper("data1", list)` |
| `\{` | 字面量 `{` | —— |
| `\}` | 字面量 `}` | —— |

## 2. 多列表前缀

> **官方原文**："模板上必须有{前缀.}前缀可以区分不同的list"

```java
// 模板：{data1.} {data2.} {data3.}
// 填充：每个 prefix 用 FillWrapper 包裹
excelWriter.fill(new FillWrapper("data1", list1), sheet);
excelWriter.fill(new FillWrapper("data2", list2), sheet);
excelWriter.fill(new FillWrapper("data3", list3), sheet);
```

## 3. 转义完整规则

| 模板原义 | 模板写法 | 说明 |
|---------|---------|------|
| 字面 `{` | `\{` | 避免被识别为变量开始 |
| 字面 `}` | `\}` | 避免被识别为变量结束 |
| 变量 `{name}` | `{name}` | 正常占位符 |
| 列表 `{.}` | `{.}` | 列表占位符 |
| 列表 `{data1.}` | `{data1.}` | 带前缀列表 |
