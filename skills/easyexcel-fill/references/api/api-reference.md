# EasyExcel 填充 API 完整参考

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 来源：https://easyexcel.opensource.alibaba.com/docs/current/api/

## 1. 核心 API 入口

| API | 用途 | 适用场景 |
|-----|------|---------|
| `EasyExcel.write(fileName).withTemplate(template)` | 指定模板路径 | 文件 → 文件 |
| `EasyExcel.write(outputStream).withTemplate(template)` | Web 输出流 | 文件 → HTTP 响应 |
| `EasyExcel.write(fileName).withTemplate(templateStream)` | 模板为 InputStream | 资源文件 → 文件 |
| `EasyExcel.write(fileName, head).withTemplate(template)` | 带表头类的填充 | 不常用 |
| `.sheet().doFill(data)` | 一次性填充 | 简单对象 / 一次性 list |
| `.sheet().doFill(map)` | 一次性 Map 填充 | 简单对象（无 DTO） |
| `excelWriter.fill(data, writeSheet)` | 多次填充（文件缓存） | 大 list 分次填 |
| `excelWriter.fill(map, writeSheet)` | 多次填充变量 | 多变量独立 |
| `excelWriter.fill(fillWrapper, writeSheet)` | 多列表分组 | 多个 list |
| `excelWriter.fill(data, fillConfig, writeSheet)` | 带配置填充 | 横向 / forceNewRow |

## 2. 辅助类

### FillConfig
```java
FillConfig fillConfig = FillConfig.builder()
    .forceNewRow(Boolean.TRUE)              // 复杂填充：list 后还有内容
    .direction(WriteDirectionEnum.HORIZONTAL) // 横向多列
    .build();
```

### FillWrapper
```java
new FillWrapper("prefix", list)  // 多个 list 分组，prefix 对应模板 {prefix.}
```

### WriteDirectionEnum
- `VERTICAL`（默认，纵向）
- `HORIZONTAL`（横向）

## 3. 模板语法完整规则

| 模板占位符 | 含义 | 触发替换 |
|-----------|------|---------|
| `{name}` | 普通变量 | Map.put("name", value) 或 DTO.name |
| `{number}` | 普通变量 | 同上 |
| `{date}` | 普通变量（Date 类型自动转字符串） | 同上 |
| `{.}` | 列表（默认纵向） | fill(list, sheet) |
| `{data1.}` | 带前缀列表 | fill(new FillWrapper("data1", list), sheet) |
| `\{` | 字面量 `{` | 不会被替换为变量 |
| `\}` | 字面量 `}` | 不会被替换为变量 |

> **官方原文**："{} 普通变量，{.} list 的变量。如果本来就有'{'、'}' 特殊字符 用'\\{'、'\\}' 代替。"
> **官方原文**："模板上必须有{前缀.}前缀可以区分不同的list"

## 4. 关键参数

### ExcelWriter 多次填充
```java
try (ExcelWriter excelWriter = EasyExcel.write(fileName)
        .withTemplate(templateFileName).build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet().build();

    // 多次 fill —— 自动使用文件缓存
    excelWriter.fill(data(), writeSheet);
    excelWriter.fill(data(), writeSheet);

    // fill 普通变量
    Map<String, Object> map = new HashMap<>();
    map.put("date", new Date());
    excelWriter.fill(map, writeSheet);
}
```

### WriteSheet
```java
WriteSheet writeSheet = EasyExcel.writerSheet().build();          // 默认
WriteSheet writeSheet = EasyExcel.writerSheet(0, "名称").build(); // 指定 sheetNo + name
```

## 5. 完整工作流（按业务规模）

| 数据规模 | 推荐方案 | 模板要求 |
|---------|---------|---------|
| < 1000 行 | `doFill(data)` 一次 | 无 |
| 1000 ~ 1 万行 | `doFill(list)` 一次 | 无 |
| 1 万 ~ 10 万行 | `excelWriter.fill(list, sheet)` 分次 | list 必须放最后一行 |
| 10 万+ 行 | 先 fill 列表 + 后 write 追加合计行 | list 必须是最后一行，后续行用 write |
| 复杂 list + 后续内容 | `forceNewRow=true` | list 后有内容（但要全量驻内存） |
| 多个 list 横向 | `FillWrapper` + `HORIZONTAL` | 模板含 `{prefix.}` |

## 6. 完整异常处理

```java
try (ExcelWriter excelWriter = EasyExcel.write(fileName)
        .withTemplate(templateFileName).build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet().build();
    try {
        excelWriter.fill(list, writeSheet);
        excelWriter.fill(headerMap, writeSheet);
    } catch (ExcelGenerateException e) {
        log.error("填充失败: {}", e.getMessage(), e);
        throw new BizException("EXPORT_FAILED", e.getMessage());
    }
}
```

## 7. 与其它模式的关系

| 模式 | 入口 | 是否需要模板 | 适合 |
|------|------|------------|------|
| **简单写入** | `EasyExcel.write().sheet().doWrite()` | ❌ | 程序化生成 |
| **模板写入** | `EasyExcel.write().withTemplate().sheet().doWrite()` | ✅ | 模板 + 列表数据 |
| **模板填充**（本技能） | `EasyExcel.write().withTemplate().sheet().doFill()` | ✅ | 模板 + 单对象/列表 |
| **读取** | `EasyExcel.read().sheet().doRead()` | —— | 解析 Excel |

> 模板填充 vs 模板写入：填充用 `{var}` `{var.}` 占位符，**保留模板原有样式**；模板写入把模板当作"表头参考"，**数据追加在表头后**。
