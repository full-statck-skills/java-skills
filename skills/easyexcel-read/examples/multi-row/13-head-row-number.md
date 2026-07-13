# 多行表头

```java
@Test
public void complexHeaderRead() {
    String fileName = "demo.xlsx";
    EasyExcel.read(fileName, DemoData.class, new DemoDataListener())
        .sheet()
        // 不指定时按 @ExcelProperty#value() 表头数量决定
        .headRowNumber(2)
        .doRead();
}
```

> **官方原文**："headRowNumber不指定时，会根据传入class的@ExcelProperty#value()的表头数量决定行数；不传入class则默认为1；指定了headRowNumber则以此为准"
