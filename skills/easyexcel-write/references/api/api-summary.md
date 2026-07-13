# EasyExcel 写入 API 速查

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write

## 核心 API

| API | 用途 |
|-----|------|
| `EasyExcel.write(path, head).sheet().doWrite(data)` | 一次性写入 |
| `EasyExcel.write(path, head).sheet().doWrite(Supplier)` | JDK8+ 一次性写入 |
| `EasyExcel.write(path, head).build()` | 创建 ExcelWriter（多次写入） |
| `excelWriter.write(data, writeSheet)` | 单次写入 sheet |
| `EasyExcel.writerSheet(0, "name").build()` | 创建 WriteSheet |
| `EasyExcel.writerTable(0).needHead(true).build()` | 创建 WriteTable |

## 注解

| 注解 | 用途 |
|------|------|
| `@ExcelProperty` | 表头/索引/转换器 |
| `@ExcelIgnore` | 忽略字段 |
| `@ExcelIgnoreUnannotated` | 类级忽略未标注字段 |
| `@DateTimeFormat` | 日期格式 |
| `@NumberFormat` | 数字格式 |
| `@ColumnWidth` `@HeadRowHeight` `@ContentRowHeight` | 尺寸 |
| `@HeadStyle` `@ContentStyle` | 样式 |
| `@HeadFontStyle` `@ContentFontStyle` | 字体 |
| `@ContentLoopMerge` | 循环合并 |
| `@OnceAbsoluteMerge` | 一次性绝对合并 |

## 配置

| 配置 | 用途 |
|------|------|
| `excludeColumnFiledNames(Set)` | 排除列 |
| `includeColumnFiledNames(Set)` | 包含列 |
| `inMemory(true)` | 内存模式（批注必须） |
| `autoCloseStream(false)` | 不自动关流（失败回 JSON） |
| `excelType(ExcelTypeEnum.XLS)` | 03 版兼容 |
| `registerWriteHandler(handler)` | 注册拦截器 |

## 拦截器

| 拦截器 | 用途 |
|--------|------|
| `CellWriteHandler` | 单元格级（超链接、样式） |
| `SheetWriteHandler` | Sheet 级（下拉框、冻结） |
| `RowWriteHandler` | 行级（批注） |
| `HorizontalCellStyleStrategy` | 已有策略（水平样式） |
| `LoopMergeStrategy` | 合并策略 |
| `LongestMatchColumnWidthStyleStrategy` | 自动列宽 |
