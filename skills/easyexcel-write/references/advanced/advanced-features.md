# EasyExcel 高级特性完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write

## 1. 图片导出

### DTO 定义
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
    private WriteCellData<Void> writeCellDataFile;
}
```

### 复杂图片（一格多图 + 文字）
```java
WriteCellData<Void> writeCellData = new WriteCellData<>();
writeCellData.setType(CellDataTypeEnum.STRING);
writeCellData.setStringValue("额外的放一些文字");

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

## 2. 超链接（HyperlinkData）

```java
WriteCellData<String> hyperlink = new WriteCellData<>("官方网站");
HyperlinkData hyperlinkData = new HyperlinkData();
hyperlink.setHyperlinkData(hyperlinkData);
hyperlinkData.setAddress("https://github.com/alibaba/easyexcel");
hyperlinkData.setHyperlinkType(HyperlinkType.URL);
```

`HyperlinkType` 可选：URL/EMAIL/FILE/DOCUMENT

## 3. 批注（CommentData）

```java
WriteCellData<String> comment = new WriteCellData<>("备注的单元格信息");
CommentData commentData = new CommentData();
comment.setCommentData(commentData);
commentData.setAuthor("Jiaju Zhuang");
commentData.setRichTextStringData(new RichTextStringData("这是一个备注"));
commentData.setRelativeLastColumnIndex(1);
commentData.setRelativeLastRowIndex(1);
```

> **官方提示**：批注必须 `inMemory(true)`，否则不会写入。

## 4. 公式（FormulaData）

```java
FormulaData formulaData = new FormulaData();
formulaData.setFormulaValue("REPLACE(123456789,1,1,2)");
```

支持的 Excel 公式：SUM、AVERAGE、IF、VLOOKUP、HLOOKUP、INDEX/MATCH、CONCATENATE、LEFT/RIGHT/MID 等。

## 5. 富文本（RichTextStringData）

```java
WriteCellData<String> richText = new WriteCellData<>();
richText.setType(CellDataTypeEnum.RICH_TEXT_STRING);
RichTextStringData richTextStringData = new RichTextStringData();
richText.setRichTextStringDataValue(richTextStringData);
richTextStringData.setTextString("红色绿色默认");

WriteFont writeFont = new WriteFont();
writeFont.setColor(IndexedColors.RED.getIndex());
richTextStringData.applyFont(0, 2, writeFont);
```

## 6. 合并单元格

### 注解
```java
@ContentLoopMerge(eachRow = 2)
@ExcelProperty("字符串标题")
private String string;
```

### 策略
```java
LoopMergeStrategy loopMergeStrategy = new LoopMergeStrategy(2, 0);
EasyExcel.write(fileName, DemoData.class)
    .registerWriteHandler(loopMergeStrategy)
    .sheet("模板").doWrite(data());
```

## 7. 自定义拦截器

### 单元格级别（CellWriteHandler）
### Sheet 级别（SheetWriteHandler）—— 下拉框
### 行级别（RowWriteHandler）—— 批注

注册：
```java
EasyExcel.write(fileName, DemoData.class)
    .registerWriteHandler(new CustomSheetWriteHandler())
    .registerWriteHandler(new CustomCellWriteHandler())
    .sheet("模板").doWrite(data());
```

## 8. 动态表头

```java
EasyExcel.write(fileName)
    .head(head())
    .sheet("模板")
    .doWrite(data());
```

## 9. WriteTable 多次写入同一 Sheet 不同表

```java
try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet("模板")
        .needHead(Boolean.FALSE).build();
    WriteTable writeTable0 = EasyExcel.writerTable(0).needHead(Boolean.TRUE).build();
    WriteTable writeTable1 = EasyExcel.writerTable(1).needHead(Boolean.TRUE).build();
    excelWriter.write(data(), writeSheet, writeTable0);
    excelWriter.write(data(), writeSheet, writeTable1);
}
```

## 10. 03 版兼容

```java
EasyExcel.write(fileName, DemoData.class)
    .excelType(ExcelTypeEnum.XLS)
    .sheet("模板").doWrite(data());
```
