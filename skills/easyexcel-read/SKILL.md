---
name: easyexcel-read
description: 基于 Alibaba EasyExcel（com.alibaba:easyexcel:4.0.3）的 Excel 数据读取技能。覆盖监听器模式（ReadListener/AnalysisEventListener/PageReadListener）、同步读取（doReadSync）、多 Sheet 读取、@ExcelProperty(index/name)匹配、多行表头（headRowNumber）、日期数字自定义转换器（@DateTimeFormat/@NumberFormat/Converter）、监听器异常处理（onException + ExcelDataConvertException）、额外信息读取（批注/超链接/合并单元格，extraRead + CellExtra）、公式和单元格类型（CellData<T>）、不创建对象的读（ReadListener<Map<Integer,String>>）、Web 上传读取（MultipartFile→InputStream）。当用户需要解析 Excel（导入数据/批量入库/对账文件/用户上传/Excel 转对象/Excel 转 Map）时使用此技能，不适用于按预制模板填充（改用 easyexcel-fill）、不适用于程序化生成 Excel（改用 easyexcel-write）。
license: Apache-2.0
---

# EasyExcel 数据读取（Read）

> 官方文档：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 官方示例：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/read/ReadTest.java
> 当前版本：`com.alibaba:easyexcel:4.0.3`（Apache-2.0，仓库已归档，仅做 Bug 修复）

本技能专注于 **"读取 Excel 数据"** 场景。当用户需要解析 `.xlsx`/`.xls` 文件（导入数据、批量入库、对账文件解析、用户上传）时，应当使用本技能。

## Capability Boundaries

### ✅ 强项
1. 监听器模式（流式，大文件不 OOM）
2. 同步读取（小文件一次性返回 List）
3. 多 Sheet 读取（全部 / 部分）
4. 多行表头支持（`headRowNumber`）
5. 自定义转换器（日期/数字/枚举）
6. 异常处理（行级容错）
7. 额外信息读取（批注/超链接/合并单元格）
8. 公式和单元格原始类型
9. 不创建对象的读（直接得 Map）
10. Web 上传文件读取

### ⚠️ 限制
1. 监听器不能被 Spring 管理（必须 new，且字段需要用构造方法传入 Spring Bean）
2. 一个 sheet 不能重复读取（多次读取需重新构造 reader）
3. 03 版多 sheet 一次性传入避免重复解析
4. `headRowNumber` 不指定时会按 `@ExcelProperty#value()` 表头数量推断
5. `doReadSync()` 不推荐大数据量

### ❌ Out of Scope（不该用本技能的场景，请改用其它技能）
1. **按预制模板填充** → **不适用**本技能，使用 `easyexcel-fill`
2. **程序化生成 Excel** → **不适用**本技能，使用 `easyexcel-write`
3. **CSV 文件** → **不适用**本技能，自行使用 commons-csv / OpenCSV（EasyExcel 也支持 CSV，需 `excelType(CSV)`）
4. **Word/PPT** → **不适用**本技能，使用 Apache POI

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅用于本地开发参考。

## When to use this skill

- 用户说"读取 Excel"、"解析 Excel"、"导入 Excel"、"上传 Excel"
- 用户上传 `.xlsx` 文件，要求把数据读为 Java 对象或 Map
- 业务上有"批量入库"、"对账文件解析"、"动态列读取"等需求
- 需要读取批注/超链接/合并单元格等额外信息

## Quick Start

**典型调用方式（4 种写法）**：

```java
// 写法 1：JDK8+ PageReadListener（since 3.0.0-beta1，最简洁）
EasyExcel.read(fileName, DemoData.class, new PageReadListener<DemoData>(dataList -> {
    for (DemoData data : dataList) {
        log.info("读取到数据: {}", JSON.toJSONString(data));
    }
})).sheet().doRead();

// 写法 2：匿名 ReadListener
EasyExcel.read(fileName, DemoData.class, new ReadListener<DemoData>() {
    @Override public void invoke(DemoData data, AnalysisContext context) { /* 每行回调 */ }
    @Override public void doAfterAllAnalysed(AnalysisContext context) { /* 全部完成 */ }
}).sheet().doRead();

// 写法 3：自定义 ReadListener
EasyExcel.read(fileName, DemoData.class, new DemoDataListener()).sheet().doRead();

// 写法 4：ExcelReader（一个文件一个 reader）
try (ExcelReader excelReader = EasyExcel.read(fileName, DemoData.class,
        new DemoDataListener()).build()) {
    ReadSheet readSheet = EasyExcel.readSheet(0).build();
    excelReader.read(readSheet);
}
```

> **官方原文**："PageReadListener 默认每次会读取100条数据 然后返回过来 直接调用使用数据就行"

## Workflow

Step 1. **确认场景** — 数据规模、是否包含额外信息、是否有 DTO
Step 2. **定义数据模型** — 编写 DTO/VO，标注 `@ExcelProperty` 等注解
Step 3. **选择读取方式** — 监听器（流式）/ 同步（小文件）/ 不创建对象
Step 4. **实现 ReadListener** — 注入 DAO（构造方法）；处理 `invoke` / `doAfterAllAnalysed` / `onException` / `invokeHead` / `extra`
Step 5. **执行读取** — `doRead()` 或 `excelReader.read(readSheet)`
Step 6. **验证输出** — 检查行数、转换异常、批注/超链接捕获

## Critical: 模式选择决策

```
数据规模？
├── < 1000 行 + 一次性返回 → 同步模式：doReadSync()
├── < 1 万行 + 简单处理 → PageReadListener
├── > 1 万行 + 入库 → ReadListener + 批量入库（每 2000 行）
└── 不需要对象 + 动态列 → ReadListener<Map<Integer, String>>

需要额外信息？
├── 批注 → extraRead(CellExtraTypeEnum.COMMENT)
├── 超链接 → extraRead(CellExtraTypeEnum.HYPERLINK)
└── 合并单元格 → extraRead(CellExtraTypeEnum.MERGE)

需要多 Sheet？
├── 全部 → doReadAll()
└── 部分 → ExcelReader.read(readSheet1, readSheet2, ...)
```

## Critical: 标准监听器模板

```java
@Slf4j
public class DemoDataListener implements ReadListener<DemoData> {
    /**
     * 官方原文："DemoDataListener 不能被spring管理，要每次读取excel都要new"
     */
    private static final int BATCH_COUNT = 100;
    private List<DemoData> cachedDataList =
        ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
    private DemoDAO demoDAO;

    public DemoDataListener() {
        demoDAO = new DemoDAO();
    }

    /**
     * 官方原文："如果使用了spring,请使用这个构造方法。
     *            每次创建Listener的时候需要把spring管理的类传进来"
     */
    public DemoDataListener(DemoDAO demoDAO) {
        this.demoDAO = demoDAO;
    }

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        log.info("解析到一条数据:{}", JSON.toJSONString(data));
        cachedDataList.add(data);
        if (cachedDataList.size() >= BATCH_COUNT) {
            saveData();
            cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        saveData();  // ⚠️ 处理最后一批
        log.info("所有数据解析完成！");
    }

    private void saveData() {
        log.info("{}条数据，开始存储数据库！", cachedDataList.size());
        demoDAO.save(cachedDataList);
        log.info("存储数据库成功！");
    }
}

// 持久层（官方原文："如果是mybatis,尽量别直接调用多次insert,
//            自己写一个mapper里面新增一个方法batchInsert"）
public class DemoDAO {
    public void save(List<DemoData> list) {
        // mybatis batchInsert
    }
}
```

## Critical: 4 种基础读取模式

### 模式 1：最简读取（4 种写法）

```java
// DTO
@Getter
@Setter
@EqualsAndHashCode
public class DemoData {
    private String string;
    private Date date;
    private Double doubleData;
}

@Test
public void simpleRead() {
    String fileName = "demo.xlsx";

    // 写法 1：JDK8+ PageReadListener
    EasyExcel.read(fileName, DemoData.class, new PageReadListener<DemoData>(dataList -> {
        for (DemoData d : dataList) {
            log.info("读取到一条数据{}", JSON.toJSONString(d));
        }
    })).sheet().doRead();

    // 写法 2：匿名 ReadListener
    EasyExcel.read(fileName, DemoData.class, new ReadListener<DemoData>() {
        private static final int BATCH_COUNT = 100;
        private List<DemoData> cachedDataList =
            ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);

        @Override
        public void invoke(DemoData data, AnalysisContext context) {
            cachedDataList.add(data);
            if (cachedDataList.size() >= BATCH_COUNT) {
                saveData();
                cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
            }
        }
        @Override
        public void doAfterAllAnalysed(AnalysisContext context) { saveData(); }

        private void saveData() {
            log.info("{}条数据，开始存储数据库！", cachedDataList.size());
        }
    }).sheet().doRead();

    // 写法 3：自定义 Listener
    EasyExcel.read(fileName, DemoData.class, new DemoDataListener()).sheet().doRead();

    // 写法 4：ExcelReader
    try (ExcelReader excelReader = EasyExcel.read(fileName, DemoData.class,
            new DemoDataListener()).build()) {
        ReadSheet readSheet = EasyExcel.readSheet(0).build();
        excelReader.read(readSheet);
    }
}
```

### 模式 2：指定列的下标或列名

```java
@Getter
@Setter
@EqualsAndHashCode
public class IndexOrNameData {
    @ExcelProperty(index = 2)
    private Double doubleData;
    @ExcelProperty("字符串标题")
    private String string;
    @ExcelProperty("日期标题")
    private Date date;
}

@Test
public void indexOrNameRead() {
    EasyExcel.read(fileName, IndexOrNameData.class, new IndexOrNameDataListener())
        .sheet().doRead();
}
```

> **官方原文**："不建议 index 和 name 同时用，要么只用index，要么只用name匹配"

### 模式 3：多 Sheet 读取

```java
@Test
public void repeatedRead() {
    String fileName = "demo.xlsx";

    // 读取全部 sheet
    EasyExcel.read(fileName, DemoData.class, new DemoDataListener()).doReadAll();

    // 读取部分 sheet
    try (ExcelReader excelReader = EasyExcel.read(fileName).build()) {
        ReadSheet readSheet1 = EasyExcel.readSheet(0).head(DemoData.class)
                .registerReadListener(new DemoDataListener()).build();
        ReadSheet readSheet2 = EasyExcel.readSheet(1).head(DemoData.class)
                .registerReadListener(new DemoDataListener()).build();
        // ⚠️ 必须把 sheet1 sheet2 一起传进去，不然03版excel会读取多次浪费性能
        excelReader.read(readSheet1, readSheet2);
    }
}
```

> **官方原文**："一个sheet不能读取多次，多次读取需要重新读取文件"
> **官方原文**："必须把sheet1 sheet2 一起传进去，不然03版excel会读取多次浪费性能"

### 模式 4：日期/数字/自定义格式转换

```java
@Getter
@Setter
@EqualsAndHashCode
public class ConverterData {
    @ExcelProperty(converter = CustomStringStringConverter.class)
    private String string;
    @DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
    private String date;
    @NumberFormat("#.##%")
    private String doubleData;
}

public class CustomStringStringConverter implements Converter<String> {
    @Override
    public Class<?> supportJavaTypeKey() { return String.class; }

    @Override
    public CellDataTypeEnum supportExcelTypeKey() { return CellDataTypeEnum.STRING; }

    @Override
    public String convertToJavaData(ReadConverterContext<?> context) {
        return "自定义：" + context.getReadCellData().getStringValue();
    }

    @Override
    public WriteCellData<?> convertToExcelData(WriteConverterContext<String> context) {
        return new WriteCellData<>(context.getValue());
    }
}

@Test
public void converterRead() {
    EasyExcel.read(fileName, ConverterData.class, new ConverterDataListener())
        // .registerConverter(new CustomStringStringConverter())  // 全局注册
        .sheet().doRead();
}
```

> **官方原文**："registerConverter 会变成全局，所有java为string,excel为string都会用这个转换器；如果就想单个字段使用请使用@ExcelProperty 指定converter"

## Critical: 多行头

```java
@Test
public void complexHeaderRead() {
    // 模板默认 headRowNumber=1，多行头用 headRowNumber(N)
    EasyExcel.read(fileName, DemoData.class, new DemoDataListener())
        .sheet()
        .headRowNumber(2)  // 2 行表头
        .doRead();
}
```

> **官方原文**："headRowNumber不指定时，会根据传入class的@ExcelProperty#value()的表头数量决定行数；不传入class则默认为1；指定了headRowNumber则以此为准"

## Critical: 同步读取（小文件）

```java
@Test
public void synchronousRead() {
    String fileName = "demo.xlsx";

    // 指定 class 返回 List
    List<DemoData> list = EasyExcel.read(fileName).head(DemoData.class)
        .sheet().doReadSync();
    for (DemoData data : list) {
        LOGGER.info("读取到数据:{}", JSON.toJSONString(data));
    }

    // 不指定 class 返回 List<Map<Integer, String>>
    List<Map<Integer, String>> listMap = EasyExcel.read(fileName)
        .sheet().doReadSync();
    for (Map<Integer, String> data : listMap) {
        LOGGER.info("读取到数据:{}", JSON.toJSONString(data));
    }
}
```

> **官方原文**："不推荐使用，如果数据量大会把数据放到内存里面"

## Critical: 读取表头数据

```java
@Slf4j
public class DemoHeadDataListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        log.info("解析到一条头数据:{}", JSON.toJSONString(headMap));
        // 转成 Map<Integer,String>：
        // 方案 1：不implements ReadListener 而是 extends AnalysisEventListener
        // 方案 2：调用 ConverterUtils.convertToStringMap(headMap, context) 自动转换
    }

    @Override public void invoke(DemoData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}
}

@Test
public void headerRead() {
    EasyExcel.read(fileName, DemoData.class, new DemoHeadDataListener()).sheet().doRead();
}
```

## Critical: 额外信息（批注/超链接/合并单元格）

```java
@Slf4j
public class DemoExtraListener implements ReadListener<DemoExtraData> {
    @Override public void invoke(DemoExtraData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}

    @Override
    public void extra(CellExtra extra, AnalysisContext context) {
        log.info("读取到了一条额外信息:{}", JSON.toJSONString(extra));
        switch (extra.getType()) {
            case COMMENT:
                log.info("额外信息是批注,在rowIndex:{},columnIndex;{},内容是:{}",
                    extra.getRowIndex(), extra.getColumnIndex(), extra.getText());
                break;
            case HYPERLINK:
                log.info("额外信息是超链接,在rowIndex:{},columnIndex;{},内容是:{}",
                    extra.getRowIndex(), extra.getColumnIndex(), extra.getText());
                break;
            case MERGE:
                log.info("额外信息是超链接,覆盖了一个区间,在firstRowIndex:{},firstColumnIndex;{}," +
                    "lastRowIndex:{},lastColumnIndex:{}",
                    extra.getFirstRowIndex(), extra.getFirstColumnIndex(),
                    extra.getLastRowIndex(), extra.getLastColumnIndex());
                break;
        }
    }
}

@Test
public void extraRead() {
    EasyExcel.read(fileName, DemoExtraData.class, new DemoExtraListener())
        .extraRead(CellExtraTypeEnum.COMMENT)     // 批注 默认不读取
        .extraRead(CellExtraTypeEnum.HYPERLINK)  // 超链接 默认不读取
        .extraRead(CellExtraTypeEnum.MERGE)      // 合并单元格 默认不读取
        .sheet().doRead();
}
```

> **官方原文**："批注、超链接、合并单元格信息默认不读取，需显式调用"

## Critical: 读取公式和单元格类型

```java
@Getter
@Setter
@EqualsAndHashCode
public class CellDataReadDemoData {
    private CellData<String> string;
    private CellData<Date> date;        // excel 中是 number，包装后是 Date
    private CellData<Double> doubleData;
    private CellData<String> formulaValue;
}

@Test
public void cellDataRead() {
    EasyExcel.read(fileName, CellDataReadDemoData.class, new CellDataDemoHeadDataListener())
        .sheet().doRead();
}
```

> **官方原文**："依赖性公式可能读不到，后续会修复"

## Critical: 数据转换异常处理

```java
@Override
public void onException(Exception exception, AnalysisContext context) {
    log.error("解析失败，但是继续解析下一行:{}", exception.getMessage());
    // 抛出异常则停止读取；不抛出则继续读取下一行
    if (exception instanceof ExcelDataConvertException) {
        ExcelDataConvertException ex = (ExcelDataConvertException) exception;
        log.error("第{}行，第{}列解析异常，数据为:{}",
            ex.getRowIndex(), ex.getColumnIndex(), ex.getCellData());
    }
}

@Test
public void exceptionRead() {
    EasyExcel.read(fileName, ExceptionDemoData.class, new DemoExceptionListener())
        .sheet().doRead();
}
```

## Critical: 不创建对象的读

```java
@Slf4j
public class NoModelDataListener extends AnalysisEventListener<Map<Integer, String>> {
    private static final int BATCH_COUNT = 5;
    private List<Map<Integer, String>> cachedDataList =
        ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);

    @Override
    public void invoke(Map<Integer, String> data, AnalysisContext context) {
        log.info("解析到一条数据:{}", JSON.toJSONString(data));
        cachedDataList.add(data);
        if (cachedDataList.size() >= BATCH_COUNT) {
            saveData();
            cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        saveData();
    }

    private void saveData() {
        log.info("{}条数据，开始存储数据库！", cachedDataList.size());
    }
}

@Test
public void noModelRead() {
    EasyExcel.read(fileName, new NoModelDataListener()).sheet().doRead();
}
```

> **官方原文**："不创建对象的读"用于动态列、未知表头结构

## Critical: Web 上传读取

```java
@PostMapping("upload")
@ResponseBody
public String upload(MultipartFile file) throws IOException {
    EasyExcel.read(file.getInputStream(), UploadData.class,
                   new UploadDataListener(uploadDAO)).sheet().doRead();
    return "success";
}
```

> **官方原文**："上传文件以 InputStream 形式读取"

## Gotchas（常见错误）

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 监听器标 `@Component` / `@Service` | 监听器**不能**被 Spring 管理，必须 `new` |
| 2 | 监听器直接 `@Autowired` DAO | 通过**构造方法**注入 Spring Bean |
| 3 | 同一 `ExcelReader` 多次 `read()` 同一 sheet | 一个 sheet 不能重复读取，需重新 build |
| 4 | 多 sheet 逐个 `read()` | 必须 `excelReader.read(sheet1, sheet2, ...)` 一次性传入 |
| 5 | 大文件用 `doReadSync()` | 用 `ReadListener` 流式 |
| 6 | `onException` 直接抛出 | 不抛出则继续读，抛出则停止 |
| 7 | 全局 `registerConverter` 后字段都被影响 | 单字段用 `@ExcelProperty(converter=...)` |
| 8 | `extraRead` 不调用就以为能读到批注 | 批注/超链接/合并默认不读，需显式调用 |
| 9 | `headRowNumber` 与表头实际行数不匹配 | 多级表头必须正确指定 |
| 10 | Web 上传时 `MultipartFile.getInputStream()` 没关闭 | 用 try-with-resources 包裹 |
| 11 | 03 版多 sheet 浪费性能 | 一次性传入 `excelReader.read(sheet1, sheet2, ...)` |
| 12 | 同步读取用在大数据量 | 改用监听器 |

## Key Classes / Methods

| 类型 | 名称 | 用途 |
|------|------|------|
| 入口 | `EasyExcel.read(path, head, listener)` | 读文件 + DTO + 监听器 |
| 入口 | `EasyExcel.read(inputStream, head, listener)` | 读流（Web 上传） |
| 入口 | `EasyExcel.read(path)` | 不指定 head（动态） |
| 入口 | `EasyExcel.read(path, head).sheet().doReadSync()` | 同步读取 |
| 核心 | `ExcelReader` | 多次读取容器 |
| 核心 | `ReadSheet` | 单个 sheet |
| 核心 | `ReadListener<T>` | 监听器接口 |
| 核心 | `AnalysisEventListener<T>` | 监听器基类（带 head/extra） |
| 核心 | `PageReadListener<T>` | JDK8+ 简化监听器（since 3.0.0-beta1） |
| 核心 | `AnalysisContext` | 读取上下文（含 sheetNo/rowIndex） |
| 注解 | `@ExcelProperty` | 表头/索引/转换器 |
| 注解 | `@DateTimeFormat` `@NumberFormat` | 格式 |
| 注解 | `@ExcelIgnore` `@ExcelIgnoreUnannotated` | 忽略字段 |
| 配置 | `headRowNumber(N)` | 表头行数 |
| 配置 | `extraRead(CellExtraTypeEnum.X)` | 额外信息读取 |
| 配置 | `registerConverter(converter)` | 全局转换器 |
| 异常 | `ExcelDataConvertException` | 转换异常（行/列号） |
| 数据 | `CellData<T>` | 单元格原始类型（含公式） |
| 数据 | `CellExtra` | 额外信息（批注/超链接/合并） |
| 工具 | `EasyExcel.readSheet(0).build()` | 创建 ReadSheet |
| 工具 | `EasyExcel.readSheet("name").build()` | 按名称 |

## References

- **官方文档**：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
- **官方示例**：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/read/ReadTest.java
- **Web 示例**：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/web/WebTest.java
- **项目主页**：https://easyexcel.opensource.alibaba.com/
- **GitHub**：https://github.com/alibaba/easyexcel
- **API 参考**：https://easyexcel.opensource.alibaba.com/docs/current/api/
- [references/api-reference.md](references/api-reference.md) — 完整 API 与注解索引
- [references/listener-patterns.md](references/listener-patterns.md) — 4 种监听器模式详解
- [references/converter-and-format.md](references/converter-and-format.md) — 转换器与格式完整指南
- [references/exception-handling.md](references/exception-handling.md) — 异常处理与容错读取
- [examples/real-cases.md](examples/real-cases.md) — 6 种读取模式完整可复制代码
- [examples/business-scenarios.md](examples/business-scenarios.md) — 订单导入/对账文件/用户上传等真实案例
- [examples/spring-boot-integration.md](examples/spring-boot-integration.md) — Spring Boot 集成完整示例
