# 多 Table 写入同一 Sheet

```java
@Test
public void tableWrite() {
    try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet("模板")
            .needHead(Boolean.FALSE).build();
        WriteTable writeTable0 = EasyExcel.writerTable(0).needHead(Boolean.TRUE).build();
        WriteTable writeTable1 = EasyExcel.writerTable(1).needHead(Boolean.TRUE).build();
        excelWriter.write(data(), writeSheet, writeTable0);
        excelWriter.write(data(), writeSheet, writeTable1);
    }
}
```
