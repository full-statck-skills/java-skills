---
name: easyexcel-patterns
description: |
  EasyExcel Excel读写技能。覆盖监听器模式(大文件流式读)vs同步模式(小文件)、写模式选择(分页分批写入/模板填充/动态表头)、百万级数据OOM防护、inMemory(true)模板导出陷阱、@ExcelProperty/@ContentStyle/@DateTimeFormat注解、Web下载直接写OutputStream。
  纠正 LLM：用 Apache POI 手写 50 行代码做简单导入导出、大文件不监听器模式(OOM)、inMemory(true)用错、不关闭ExcelWriter。
license: Apache-2.0
---

# EasyExcel Excel 处理

> 来源：[https://easyexcel.opensource.alibaba.com/](https://easyexcel.opensource.alibaba.com/)  
> GitHub：[https://github.com/alibaba/easyexcel](https://github.com/alibaba/easyexcel)

## Capability Boundaries

### ✅ Strong Suits
1. **读取** — 监听器模式(大文件/流式) vs 同步模式(小文件<1000行)
2. **写入** — 分页分批写入/模板填充/动态表头/自定义样式/多次写入
3. **百万级优化** — 分批写入+flush策略+分Sheet
4. **模板填充** — 复杂格式报表(函数/合并单元格/图表)
5. **Web导出** — 直接写 OutputStream(不写临时文件)

### ❌ Out of Scope
1. 复杂Word/PPT操作 → Apache POI(少量场景)
2. CSV文件 → commons-csv 或 OpenCSV

## 读模式选择决策

```
文件大小？
├── < 1000行 → 同步模式：doReadSync()
├── 1000~1万行 → 监听器模式，全量收集再处理
└── > 1万行 → 监听器模式 + 分批处理(每2000行flush一次)
```

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 手写 POI Workbook/Sheet/Row/Cell 样板代码 | EasyExcel 一行 `EasyExcel.read().sheet().doRead()` |
| 2 | 大文件一次性加载到内存 OOM | 监听器模式，每2000行处理一次 |
| 3 | 导出不关闭流或ExcelWriter | `finally { excelWriter.finish() }` |
| 4 | 不知道模板填充 | `EasyExcel.write().withTemplate("template.xlsx").sheet().doFill(data)` |
| 5 | 模板填充用 inMemory(true) | ⚠️ 只有导出模板时用 inMemory(true)；填充数据时绝不能用！ |
| 6 | 百万级导出一次性查全部数据 | 分页查询(每批2000~5000条) + 分批写入 |
| 7 | Web导出先写文件再读入response | 直接 `EasyExcel.write(response.getOutputStream())` |
| 8 | 监听器复用单例 | 每次读取必须 new 监听器 |

## 核心模式

### 模式 1: 同步读(小文件<1000行)
```java
// ✅ 小文件：同步读取，返回全部List
List<UserDTO> list = EasyExcel.read(file)
    .head(UserDTO.class)
    .sheet()
    .doReadSync();
```

### 模式 2: 监听器读(大文件，分批处理)
```java
// ✅ 大文件：监听器模式，分批处理避免OOM
public class BatchExcelListener<T> extends AnalysisEventListener<T> {
    private static final int BATCH_COUNT = 2000;
    private final List<T> batch = new ArrayList<>(BATCH_COUNT);
    private final Consumer<List<T>> processor;  // 外部批量处理函数

    public BatchExcelListener(Consumer<List<T>> processor) {
        this.processor = processor;
    }

    @Override
    public void invoke(T data, AnalysisContext context) {
        batch.add(data);
        if (batch.size() >= BATCH_COUNT) {
            processor.accept(new ArrayList<>(batch));
            batch.clear();  // ← 关键：释放内存
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        if (!batch.isEmpty()) {
            processor.accept(new ArrayList<>(batch));
            batch.clear();
        }
    }
}

// 使用(每2000条批量存库)
EasyExcel.read(file, UserDTO.class, new BatchExcelListener<>(userService::batchInsert))
    .sheet()
    .doRead();
```

### 模式 3: 百万级写入(分页查询+分批写入)
```java
public void exportLargeData(HttpServletResponse response, int totalCount) {
    // ✅ 直接写 OutputStream(不写临时文件)
    try (ExcelWriter excelWriter = EasyExcel.write(
            response.getOutputStream(), UserExportDTO.class).build()) {

        WriteSheet writeSheet = EasyExcel.writerSheet("用户列表").build();
        int pageSize = 2000;
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);

        for (int pageNum = 1; pageNum <= totalPage; pageNum++) {
            List<UserExportDTO> pageData = userService.findPage(pageNum, pageSize);
            excelWriter.write(pageData, writeSheet);
            pageData.clear();  // ← 分批释放
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment;filename=users.xlsx");
    }
}
```

### 模式 4: 模板填充(复杂报表)
```java
// ✅ 模板填充——先在Excel模板中定义变量 {name} {.name}
// 导出模板时用 inMemory(true)，填充数据时不用！

// 导出模板
EasyExcel.write(fileName, DemoData.class)
    .inMemory(true)  // ← 导出模板必须加！否则变量名被分片损坏
    .sheet("模板")
    .doWrite(fillData());

// 使用模板填充数据
try (ExcelWriter excelWriter = EasyExcel.write(response.getOutputStream())
        .withTemplate(templateStream)
        .build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet().build();
    FillConfig fillConfig = FillConfig.builder().forceNewRow(true).build();

    // 分页填充(避免OOM)
    for (int page = 1; ; page++) {
        List<?> data = getDataByPage(page, 2000);
        if (data.isEmpty()) break;
        excelWriter.fill(data, fillConfig, writeSheet);
        data.clear();
    }
}
```

### 模式 5: 实体定义
```java
@Data
public class UserExportDTO {
    @ExcelProperty(value = "用户名", index = 0)  // 指定列顺序
    private String username;

    @ExcelProperty("年龄")
    @ContentStyle(dataFormat = 1)               // 整数格式
    private Integer age;

    @ExcelIgnore                                 // 不导出
    private String password;

    @ExcelProperty("创建时间")
    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")      // 日期格式
    private LocalDateTime createTime;

    @ExcelProperty("状态")
    @ContentStyle(dataFormat = 0x31)            // 自定义格式
    private String status;
}
```

### 模式 6: 异步导出(超50万行)
```java
@GetMapping("/export/async")
public Result<String> triggerExport() {
    String taskId = "EXPORT_" + System.currentTimeMillis();
    asyncTaskExecutor.execute(() -> doExport(taskId));
    return Result.ok("导出已提交，taskId: " + taskId);
}

private void doExport(String taskId) {
    int total = userService.countTotal();
    try (ExcelWriter writer = EasyExcel.write(...).build()) {
        // 写入时更新进度(可通过Redis/cache查询)
        for (int i = 1; i <= totalPage; i++) {
            List<?> data = userService.findPage(i, 2000);
            writer.write(data, writeSheet);
            exportTaskService.updateProgress(taskId, i * 100 / totalPage);
        }
    }
}
```

## Gotchas
1. **大文件(>1万行)必须用监听器模式** — 同步模式一次性加载 OOM
2. **监听器中不能自动注入 Spring Bean** — 手动 new 需要传参，或手动从SpringContext获取
3. **模板填充的 {} 占位符语法** — `{name}`(单个)或`{.name}`(列表)两种方式
4. **@ExcelProperty 的 index 从0开始** — 确保和Excel列对应
5. **EasyExcel 基于反射** — 字段名变更后Excel映射失效
6. **日期格式化需要 @DateTimeFormat** — 否则默认 yyyy-MM-dd HH:mm:ss
7. **`finally { excelWriter.finish() }` 必须执行** — 否则文件损坏
8. **`inMemory(true)` 只在导出模板时用** — 真实数据填充绝不能用，否则全量驻留内存→OOM
9. **监听器每次读取必须 new** — 不能复用单例，因为内部状态不清理
10. **单Sheet上限104万行** — 超限需分Sheet或改用CSV
11. **Web导出直接写 OutputStream** — 不要先写文件再读，减少IO
12. **实体类字段用包装类型(Integer)** — 避免基本类型空指针

## Data Privacy
本技能不收集、存储或传输任何用户数据。
