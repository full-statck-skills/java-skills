# 不同对象不同 Sheet

```java
@Test
public void multiSheetWrite() {
    try (ExcelWriter excelWriter = EasyExcel.write(fileName).build()) {
        for (int i = 0; i < 5; i++) {
            WriteSheet writeSheet = EasyExcel.writerSheet(i, "模板" + i)
                .head(DemoData.class).build();
            excelWriter.write(data(), writeSheet);
        }
    }
}
```
