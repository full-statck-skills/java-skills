---
name: easyexcel-write
description: 基于 Alibaba EasyExcel（com.alibaba:easyexcel:4.0.3）的 Excel 数据写入技能。覆盖最简写入（3 种写法）、复杂表头（多级）、@ExcelProperty/@ExcelIgnore/@DateTimeFormat/@NumberFormat 注解、includeColumn/excludeColumn 选择列、@ColumnWidth/@ContentRowHeight 样式注解、@HeadStyle/@ContentStyle 自定义样式、合并单元格（@ContentLoopMerge/LoopMergeStrategy）、图片导出（File/InputStream/URL/byte[]）、超链接/批注/公式/富文本（WriteCellData）、动态表头、自动列宽、自定义拦截器（CellWriteHandler/SheetWriteHandler/RowWriteHandler）、分页分批写入、Web 下载直接写 OutputStream、03/07 版兼容。当用户需要程序化生成 Excel（无预制模板）导出订单/用户/财务/库存/报表/对账单/审批单等结构化数据时使用此技能，不适用于按预制模板填充（改用 easyexcel-fill）、不适用于读取 Excel（改用 easyexcel-read）。
license: Apache-2.0
---

# EasyExcel 数据写入（Write）

> 官方文档：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
> 官方示例：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/write/WriteTest.java
> 当前版本：`com.alibaba:easyexcel:4.0.3`（Apache-2.0，仓库已归档，仅做 Bug 修复）

本技能专注于 **"程序化生成 Excel"** 场景。当用户没有预制模板、要求用 Java 对象/Map 直接生成结构化 Excel（订单、用户、财务、库存、报表、对账单、审批单）时，应当使用本技能。

## Capability Boundaries

### ✅ 强项
1. 最简写入（JDK8+ 写法、传统写法、Builder 写法）
2. 复杂表头（多级表头 `@ExcelProperty({"主标题", "副标题"})`）
3. 选择性导出列（`includeColumnFiledNames` / `excludeColumnFiledNames`）
4. 注解定义格式（`@ColumnWidth` `@ContentRowHeight` `@DateTimeFormat` `@NumberFormat`）
5. 自定义样式（注解方式 / 拦截器方式 / `HorizontalCellStyleStrategy`）
6. 合并单元格（`@ContentLoopMerge` / `LoopMergeStrategy`）
7. 图片导出（File/InputStream/URL/byte[] 多种来源）
8. 超链接/批注/公式/富文本（`WriteCellData` 体系）
9. 动态表头（运行时决定表头）
10. 多次写入/多 Sheet/多 Table
11. Web 直接输出到 `HttpServletResponse`

### ⚠️ 限制
1. 单 Sheet 建议 < 5000 行一次性写入（数据量大用分批）
2. 样式对象最多创建 6W 个，否则 Excel 打不开
3. 图片会驻内存，超大图建议上传到 OSS
4. 批注需要 `inMemory(true)`
5. 03 版（`.xls`）兼容性需用 `excelType(ExcelTypeEnum.XLS)`

### ❌ Out of Scope（不该用本技能的场景，请改用其它技能）
1. **按预制模板填充** → **不适用**本技能，使用 `easyexcel-fill`
2. **读取 Excel 数据** → **不适用**本技能，使用 `easyexcel-read`
3. **CSV 文件处理** → **不适用**本技能，自行使用 commons-csv / OpenCSV
4. **Word/PPT** → **不适用**本技能，使用 Apache POI / Apache POI-XML

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅用于本地开发参考。

## When to use this skill

- 用户说"导出 Excel"、"生成 Excel"、"下载 Excel"、"导出订单/用户/财务/库存"
- 没有预制模板，需要程序化生成结构化 Excel
- 业务上有"分 Sheet（按月份/状态/类型）"、"分 Table（多个表块）"等需求
- 需要导出图片、超链接、公式、富文本、合并单元格

## Quick Start

**典型调用方式（3 种写法）**：

```java
// 写法 1：JDK8+ 用 Supplier（since 3.0.0-beta1，最简洁）
EasyExcel.write(fileName, DemoData.class)
    .sheet("模板")
    .doWrite(() -> data());

// 写法 2：传统 + 已有 List
List<DemoData> data = data();
EasyExcel.write(fileName, DemoData.class)
    .sheet("模板")
    .doWrite(data);

// 写法 3：Builder（多次写入 / 复杂配置）
try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet("模板").build();
    excelWriter.write(data(), writeSheet);
}
```

> **官方原文**："数据量建议 5000 以内"（单 sheet 一次性写入推荐上限）。

## Workflow

Step 1. **定义数据模型** — 编写 DTO/VO，标注 `@ExcelProperty` 等注解
Step 2. **选择写入方式** — 单次 `doWrite()` / 多次 `excelWriter.write()` / 多次 `doWrite()` 循环
Step 3. **配置 Builder** — 包含列选择、表头、样式、注册拦截器等
Step 4. **构造数据** — 准备 `List<DTO>` / `List<List<String>>`
Step 5. **执行写入** — try-with-resources 关闭 `ExcelWriter`
Step 6. **验证输出** — 打开生成的 `.xlsx` 检查表头/样式/格式/合并

## Critical: 注解速查

| 注解 | 用途 | 关键属性 |
|------|------|---------|
| `@ExcelProperty` | 指定列名/索引/转换器 | `value`, `index`, `order`, `converter` |
| `@ExcelIgnore` | 忽略该字段 | —— |
| `@ExcelIgnoreUnannotated` | 类级：未标注字段不参与读写 | —— |
| `@DateTimeFormat` | 日期格式 | `value`, `use1904windowing` |
| `@NumberFormat` | 数字格式 | `value`, `roundingMode` |
| `@ColumnWidth` | 列宽 | `value` |
| `@HeadRowHeight` | 表头行高 | `value` |
| `@ContentRowHeight` | 内容行高 | `value` |
| `@HeadStyle` | 表头样式（POI 风格） | fillPatternType, fillForegroundColor, font 等 |
| `@HeadFontStyle` | 表头字体 | fontHeightInPoints, color, bold 等 |
| `@ContentStyle` | 内容样式 | 同 HeadStyle |
| `@ContentFontStyle` | 内容字体 | 同 HeadFontStyle |
| `@ContentLoopMerge` | 循环合并 | `eachRow` |
| `@OnceAbsoluteMerge` | 一次性绝对合并 | `firstRowIndex` `lastRowIndex` 等 |

> **官方原文**：`order` 默认 `Integer.MAX_VALUE`；优先级：`index` > `order` > `value`。
> **官方原文**："不建议 index 和 name 同时用，要么只用index，要么只用name匹配"

## Critical: 3 种基础写入模式

### 模式 1：最简写入（推荐）
```java
// DTO
@Getter
@Setter
@EqualsAndHashCode
public class DemoData {
    @ExcelProperty("字符串标题")
    private String string;
    @ExcelProperty("日期标题")
    private Date date;
    @ExcelProperty("数字标题")
    private Double doubleData;
    @ExcelIgnore
    private String ignore;  // 不导出
}

// 写入
EasyExcel.write(fileName, DemoData.class)
    .sheet("模板")
    .doWrite(data());
```

### 模式 2：选择性导出列
```java
// 排除某列
Set<String> exclude = new HashSet<>();
exclude.add("date");
EasyExcel.write(fileName, DemoData.class)
    .excludeColumnFiledNames(exclude)
    .sheet("模板").doWrite(data());

// 只导出某列
Set<String> include = new HashSet<>();
include.add("date");
EasyExcel.write(fileName, DemoData.class)
    .includeColumnFiledNames(include)
    .sheet("模板").doWrite(data());
```

### 模式 3：多次写入（同一 Sheet / 不同 Sheet / 不同对象）
```java
try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
    // 同一 sheet 多次写入
    WriteSheet writeSheet = EasyExcel.writerSheet("模板").build();
    for (int i = 0; i < 5; i++) {
        excelWriter.write(data(), writeSheet);
    }

    // 不同 sheet 同一对象
    for (int i = 0; i < 5; i++) {
        WriteSheet sheet = EasyExcel.writerSheet(i, "模板" + i).build();
        excelWriter.write(data(), sheet);
    }
}
```

## Critical: 复杂表头与格式

### 多级表头
```java
@Getter
@Setter
@EqualsAndHashCode
public class ComplexHeadData {
    @ExcelProperty({"主标题", "字符串标题"})
    private String string;
    @ExcelProperty({"主标题", "日期标题"})
    private Date date;
    @ExcelProperty({"主标题", "数字标题"})
    private Double doubleData;
}
```

### 数字/日期格式化
```java
@Getter
@Setter
@EqualsAndHashCode
public class ConverterData {
    @ExcelProperty(value = "字符串标题", converter = CustomStringStringConverter.class)
    private String string;
    @DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
    @ExcelProperty("日期标题")
    private Date date;
    @NumberFormat("#.##%")
    @ExcelProperty("数字标题")
    private Double doubleData;
}
```

### 列宽与行高
```java
@Getter
@Setter
@EqualsAndHashCode
@ContentRowHeight(10)
@HeadRowHeight(20)
@ColumnWidth(25)
public class WidthAndHeightData {
    @ExcelProperty("字符串标题")
    private String string;
    @ColumnWidth(50)
    @ExcelProperty("数字标题")
    private Double doubleData;
}
```

## Critical: 自定义样式

### 注解方式（since 2.2.0-beta1）
```java
@Data
@HeadStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 10)
@HeadFontStyle(fontHeightInPoints = 20)
@ContentStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 17)
@ContentFontStyle(fontHeightInPoints = 20)
public class DemoStyleData {
    @HeadStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 14)
    @HeadFontStyle(fontHeightInPoints = 30)
    @ExcelProperty("字符串标题")
    private String string;
}
```

### 拦截器方式（最灵活）
```java
WriteCellStyle headStyle = new WriteCellStyle();
headStyle.setFillForegroundColor(IndexedColors.RED.getIndex());
WriteFont headFont = new WriteFont();
headFont.setFontHeightInPoints((short) 20);
headStyle.setWriteFont(headFont);

WriteCellStyle contentStyle = new WriteCellStyle();
contentStyle.setFillPatternType(FillPatternType.SOLID_FOREGROUND);
contentStyle.setFillForegroundColor(IndexedColors.GREEN.getIndex());

HorizontalCellStyleStrategy strategy =
    new HorizontalCellStyleStrategy(headStyle, contentStyle);

EasyExcel.write(fileName, DemoData.class)
    .registerWriteHandler(strategy)
    .sheet("模板").doWrite(data());
```

> **官方提示**："不要一直去创建style 记得缓存起来 最多创建6W个就挂了"

## Critical: 合并单元格

### 注解方式
```java
@ContentLoopMerge(eachRow = 2)  // 每 2 行合并
@ExcelProperty("字符串标题")
private String string;
```

### 策略方式
```java
LoopMergeStrategy loopMergeStrategy = new LoopMergeStrategy(2, 0);
EasyExcel.write(fileName, DemoData.class)
    .registerWriteHandler(loopMergeStrategy)
    .sheet("模板").doWrite(data());
```

## Critical: 图片导出

```java
@Getter
@Setter
@EqualsAndHashCode
@ContentRowHeight(100)
@ColumnWidth(100 / 8)
public class ImageDemoData {
    private File file;
    private InputStream inputStream;
    @ExcelProperty(converter = StringImageConverter.class)
    private String string;
    private byte[] byteArray;
    private URL url;
    private WriteCellData<Void> writeCellDataFile;  // 复杂图片（多图/带文字）
}
```

**多图嵌入同一单元格**：
```java
WriteCellData<Void> writeCellData = new WriteCellData<>();
imageDemoData.setWriteCellDataFile(writeCellData);
writeCellData.setType(CellDataTypeEnum.STRING);
writeCellData.setStringValue("额外的文字");

List<ImageData> imageDataList = new ArrayList<>();
ImageData imageData = new ImageData();
imageDataList.add(imageData);
writeCellData.setImageDataList(imageDataList);
imageData.setImage(FileUtils.readFileToByteArray(new File(imagePath)));
imageData.setImageType(ImageType.PICTURE_TYPE_PNG);
imageData.setTop(5);
imageData.setRight(40);
imageData.setBottom(5);
imageData.setLeft(5);
```

> **官方原文**："图片都会放到内存 暂时没有很好的解法，大量图片的情况下建议…将图片上传到oss…然后直接放链接"

## Critical: 超链接/批注/公式/富文本

```java
@Getter
@Setter
@EqualsAndHashCode
public class WriteCellDemoData {
    private WriteCellData<String> hyperlink;
    private WriteCellData<String> commentData;
    private WriteCellData<String> formulaData;
    private WriteCellData<String> writeCellStyle;
    private WriteCellData<String> richText;
}
```

**超链接示例**：
```java
WriteCellData<String> hyperlink = new WriteCellData<>("官方网站");
HyperlinkData hyperlinkData = new HyperlinkData();
hyperlink.setHyperlinkData(hyperlinkData);
hyperlinkData.setAddress("https://github.com/alibaba/easyexcel");
hyperlinkData.setHyperlinkType(HyperlinkType.URL);
writeCellDemoData.setHyperlink(hyperlink);
```

**公式示例**：
```java
WriteCellData<String> formula = new WriteCellData<>();
FormulaData formulaData = new FormulaData();
formula.setFormulaData(formulaData);
formulaData.setFormulaValue("REPLACE(123456789,1,1,2)");
```

**富文本示例**：
```java
WriteCellData<String> richTest = new WriteCellData<>();
richTest.setType(CellDataTypeEnum.RICH_TEXT_STRING);
RichTextStringData richTextStringData = new RichTextStringData();
richTest.setRichTextStringDataValue(richTextStringData);
richTextStringData.setTextString("红色绿色默认");
WriteFont writeFont = new WriteFont();
writeFont.setColor(IndexedColors.RED.getIndex());
richTextStringData.applyFont(0, 2, writeFont);
writeFont = new WriteFont();
writeFont.setColor(IndexedColors.GREEN.getIndex());
richTextStringData.applyFont(2, 4, writeFont);
```

> **官方提示**："inMemory 要设置为true，才能支持批注"

## Critical: Web 下载

```java
@GetMapping("download")
public void download(HttpServletResponse response) throws IOException {
    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setCharacterEncoding("utf-8");
    String fileName = URLEncoder.encode("测试", "UTF-8").replaceAll("\\+", "%20");
    response.setHeader("Content-disposition",
        "attachment;filename*=utf-8''" + fileName + ".xlsx");
    EasyExcel.write(response.getOutputStream(), DownloadData.class)
        .sheet("模板").doWrite(data());
}
```

**失败回 JSON**：
```java
@GetMapping("downloadFailedUsingJson")
public void downloadFailedUsingJson(HttpServletResponse response) throws IOException {
    try {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("测试", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition",
            "attachment;filename*=utf-8''" + fileName + ".xlsx");
        EasyExcel.write(response.getOutputStream(), DownloadData.class)
            .autoCloseStream(Boolean.FALSE)  // 失败时还要 reset 输出 JSON
            .sheet("模板").doWrite(data());
    } catch (Exception e) {
        response.reset();
        response.setContentType("application/json");
        response.setCharacterEncoding("utf-8");
        Map<String, String> map = new HashMap<>();
        map.put("status", "failure");
        map.put("message", "下载文件失败" + e.getMessage());
        response.getWriter().println(JSON.toJSONString(map));
    }
}
```

## Critical: 高级特性

### 动态表头
```java
@Test
public void dynamicHeadWrite() {
    EasyExcel.write(fileName)
        .head(head())  // 运行时构造表头
        .sheet("模板")
        .doWrite(data());
}

private List<List<String>> head() {
    List<List<String>> list = new ArrayList<>();
    List<String> head0 = new ArrayList<>();
    head0.add("字符串" + System.currentTimeMillis());
    list.add(head0);
    return list;
}
```

### 自动列宽（不太精确）
```java
EasyExcel.write(fileName, LongestMatchColumnWidthData.class)
    .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
    .sheet("模板").doWrite(dataLong());
```

### 自定义拦截器：单元格下拉框
```java
@Slf4j
public class CustomSheetWriteHandler implements SheetWriteHandler {
    @Override
    public void afterSheetCreate(SheetWriteHandlerContext context) {
        CellRangeAddressList cellRangeAddressList = new CellRangeAddressList(1, 2, 0, 0);
        DataValidationHelper helper = context.getWriteSheetHolder().getSheet()
            .getDataValidationHelper();
        DataValidationConstraint constraint =
            helper.createExplicitListConstraint(new String[]{"测试1", "测试2"});
        DataValidation dataValidation =
            helper.createValidation(constraint, cellRangeAddressList);
        context.getWriteSheetHolder().getSheet().addValidationData(dataValidation);
    }
}
```

### 自定义拦截器：超链接
```java
@Slf4j
public class CustomCellWriteHandler implements CellWriteHandler {
    @Override
    public void afterCellDispose(CellWriteHandlerContext context) {
        Cell cell = context.getCell();
        if (BooleanUtils.isTrue(context.getHead()) && cell.getColumnIndex() == 0) {
            CreationHelper createHelper = context.getWriteSheetHolder()
                .getSheet().getWorkbook().getCreationHelper();
            Hyperlink hyperlink = createHelper.createHyperlink(HyperlinkType.URL);
            hyperlink.setAddress("https://github.com/alibaba/easyexcel");
            cell.setHyperlink(hyperlink);
        }
    }
}
```

### 03 版兼容
```java
EasyExcel.write(fileName, DemoData.class)
    .excelType(ExcelTypeEnum.XLS)  // 默认 XLSX
    .sheet("模板").doWrite(data());
```

## Critical: 百万级写入

```java
@GetMapping("/export/large")
public void exportLarge(HttpServletResponse response) throws IOException {
    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setCharacterEncoding("utf-8");
    String fileName = URLEncoder.encode("大数据", "UTF-8").replaceAll("\\+", "%20");
    response.setHeader("Content-disposition",
        "attachment;filename*=utf-8''" + fileName + ".xlsx");

    try (ExcelWriter excelWriter = EasyExcel.write(
            response.getOutputStream(), UserExportDTO.class).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet("用户列表").build();
        int pageSize = 2000;
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        for (int pageNum = 1; pageNum <= totalPage; pageNum++) {
            List<UserExportDTO> pageData = userService.findPage(pageNum, pageSize);
            excelWriter.write(pageData, writeSheet);
            pageData.clear();
        }
    }
}
```

## Gotchas（常见错误）

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `@ExcelProperty` index 和 value 同时用 | 只用一种（index 或 name） |
| 2 | 一次性写入 10 万行 | 改为分批 `excelWriter.write()` |
| 3 | 每次写入都 new `WriteCellStyle` | 缓存 style 对象，最多 6W 个 |
| 4 | 用 `WriteCellData` 没设 `setType` | 设 `setType(CellDataTypeEnum.STRING/...)` |
| 5 | 批注没设 `inMemory(true)` | 批注必须 `inMemory(true)` |
| 6 | Web 导出先写文件再读入 response | 直接 `EasyExcel.write(response.getOutputStream())` |
| 7 | 没关闭 `ExcelWriter` 写入失败 | try-with-resources 自动 `finish()` |
| 8 | 导出 CSV | EasyExcel 也支持，但中文编码注意 `Charset` |
| 9 | 大图片全存内存 | 上传 OSS 后用 URL |
| 10 | `autoCloseStream(true)` 在失败回 JSON 场景 | 设 `autoCloseStream(false)` |
| 11 | 跨 sheet 顺序不对 | sheetNo 从 0 开始 |
| 12 | 用 `Sheet` 写自定义逻辑时未注册拦截器 | 写 `WriteHandler` 后用 `registerWriteHandler()` |

## Key Classes / Methods

| 类型 | 名称 | 用途 |
|------|------|------|
| 入口 | `EasyExcel.write(path, head)` | 写文件 + 表头类 |
| 入口 | `EasyExcel.write(outputStream, head)` | 写流 + 表头类 |
| 入口 | `EasyExcel.write(path)` | 写文件（无表头类，运行时表头） |
| 核心 | `ExcelWriter` | 多次写入容器 |
| 核心 | `WriteSheet` | 单个 sheet |
| 核心 | `WriteTable` | sheet 内的多表 |
| 注解 | `@ExcelProperty` | 表头/索引/转换器 |
| 注解 | `@ExcelIgnore` | 忽略字段 |
| 注解 | `@DateTimeFormat` `@NumberFormat` | 格式 |
| 注解 | `@ColumnWidth` `@HeadRowHeight` `@ContentRowHeight` | 尺寸 |
| 注解 | `@HeadStyle` `@ContentStyle` | 样式 |
| 注解 | `@ContentLoopMerge` | 合并 |
| 配置 | `excludeColumnFiledNames(Set)` | 排除列 |
| 配置 | `includeColumnFiledNames(Set)` | 包含列 |
| 配置 | `inMemory(true)` | 内存模式（批注必须） |
| 配置 | `autoCloseStream(false)` | 不自动关流（失败回 JSON） |
| 配置 | `excelType(ExcelTypeEnum.XLS)` | 03 版兼容 |
| 配置 | `registerWriteHandler(handler)` | 注册拦截器 |
| 工具 | `EasyExcel.writerSheet(0, "name").build()` | 创建 sheet |
| 工具 | `EasyExcel.writerTable(0).needHead(true).build()` | 创建 table |

## References

- **官方文档**：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
- **官方示例**：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/write/WriteTest.java
- **项目主页**：https://easyexcel.opensource.alibaba.com/
- **GitHub**：https://github.com/alibaba/easyexcel
- **API 参考**：https://easyexcel.opensource.alibaba.com/docs/current/api/
- [references/annotations.md](references/annotations.md) — 注解完整参考
- [references/styling-and-formatting.md](references/styling-and-formatting.md) — 样式与格式化完整指南
- [references/advanced-features.md](references/advanced-features.md) — 图片/超链接/批注/公式/合并/拦截器
- [examples/real-cases.md](examples/real-cases.md) — 6 种写入模式完整可复制代码
- [examples/business-scenarios.md](examples/business-scenarios.md) — 订单/用户/财务/库存/报表等真实案例
- [examples/web-integration.md](examples/web-integration.md) — Web 下载 + Spring Boot 集成
