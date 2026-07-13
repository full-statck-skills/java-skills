# EasyExcel 读取 API 完整参考

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/api/
> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read

## 1. 核心 API 入口

| API | 用途 |
|-----|------|
| `EasyExcel.read(fileName, head, listener).sheet().doRead()` | 单 Sheet 监听器读取 |
| `EasyExcel.read(fileName, head, listener).doReadAll()` | 全部 Sheet 监听器读取 |
| `EasyExcel.read(fileName, head).sheet().doReadSync()` | 同步读取返回 List |
| `EasyExcel.read(fileName).head(head).sheet().doReadSync()` | 同步读取 |
| `EasyExcel.read(inputStream, head, listener).sheet().doRead()` | Web 上传 |
| `EasyExcel.read(fileName).build()` | 创建 ExcelReader（多次读取） |
| `excelReader.read(readSheet1, readSheet2, ...)` | 多 sheet 一次性读取 |
| `.sheet().headRowNumber(N)` | 多行表头 |
| `.extraRead(CellExtraTypeEnum.X)` | 额外信息 |
| `.registerConverter(converter)` | 全局转换器 |

## 2. 注解

### @ExcelProperty
| 属性 | 默认值 | 说明 |
|------|--------|------|
| value | 空 | 表头名称匹配 |
| order | Integer.MAX_VALUE | 字段顺序（优先级低于 index） |
| index | -1 | 列下标匹配（优先级最高） |
| converter | 自动 | 字段级转换器 |

> **官方原文**："index、order、value 三个属性不建议同时使用"

### @ExcelIgnore / @ExcelIgnoreUnannotated

### @DateTimeFormat
- `value`：格式串
- `use1904windowing`：1904 起始日期

### @NumberFormat
- `value`：格式串
- `roundingMode`：舍入模式

## 3. ReadWorkbook 参数

| 名称 | 默认值 | 描述 |
|------|--------|------|
| excelType | 空 | XLS/XLSX/CSV |
| inputStream | 空 | 与 file 二选一 |
| file | 空 | 与 inputStream 二选一 |
| autoCloseStream | true | 自动关闭流 |
| readCache | 空 | <5M 内存，>5M EhCache |
| ignoreEmptyRow | true | 忽略空行 |
| password | 空 | 文件密码 |
| extraReadSet | 空 | 额外信息 set |
| readDefaultReturn | STRING | STRING/ACTUAL_DATA/READ_CELL_DATA |
| headRowNumber | 1 | 表头行数 |

## 4. ReadSheet 参数

| 名称 | 默认值 | 描述 |
|------|--------|------|
| sheetNo | 0 | sheet 编号 |
| sheetName | 空 | sheet 名称 |
| headRowNumber | 1 | 表头行数（覆盖 workbook） |
| head | 空 | 表头类 |
| clazz | 空 | 表头 class |

## 5. ReadListener 接口

```java
public interface ReadListener<T> {
    void invoke(T data, AnalysisContext context);
    void doAfterAllAnalysed(AnalysisContext context);

    // 可选
    default void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {}
    default void extra(CellExtra extra, AnalysisContext context) {}
    default void onException(Exception exception, AnalysisContext context) {}
    default boolean hasNext(AnalysisContext context) { return true; }
}
```

## 6. AnalysisContext

| 方法 | 用途 |
|------|------|
| `context.getCurrentSheet()` | 当前 ReadSheet |
| `context.getCurrentRowNum()` | 当前行号（0 开始） |
| `context.getTotalCount()` | 已处理行数 |
| `context.getCustom()` | 获取自定义数据 |

## 7. CellExtra / CellExtraTypeEnum

| 类型 | 说明 |
|------|------|
| `COMMENT` | 批注 |
| `HYPERLINK` | 超链接 |
| `MERGE` | 合并单元格 |
| `HYPERLINK` 字段 | firstRowIndex, firstColumnIndex, lastRowIndex, lastColumnIndex |

## 8. CellData<T>

| 方法 | 用途 |
|------|------|
| `getStringValue()` | 字符串值 |
| `getNumberValue()` | 数字值 |
| `getBooleanValue()` | 布尔值 |
| `getDateValue()` | 日期值 |
| `getFormulaValue()` | 公式值 |
| `getType()` | CellDataTypeEnum 类型 |

> **官方原文**："依赖性公式可能读不到，后续会修复"

## 9. ExcelDataConvertException

| 方法 | 用途 |
|------|------|
| `getRowIndex()` | 出错行号 |
| `getColumnIndex()` | 出错列号 |
| `getCellData()` | 原始单元格数据 |
| `getExcelCoordinate()` | Excel 坐标（A1） |

## 10. PageReadListener（since 3.0.0-beta1）

```java
public PageReadListener(Consumer<List<T>> consumer) {
    this(DEFAULT_BATCH_SIZE, consumer);  // DEFAULT_BATCH_SIZE = 100
}
```

> **官方原文**："这里默认每次会读取100条数据"
