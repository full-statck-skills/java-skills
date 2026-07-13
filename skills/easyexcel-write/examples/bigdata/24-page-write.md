# 百万级分页写入

```java
@Test
public void largeDataWrite() {
    try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        int pageSize = 2000;
        for (int pageNum = 1; pageNum <= 100; pageNum++) {
            List<DemoData> pageData = queryPage(pageNum, pageSize);
            excelWriter.write(pageData, writeSheet);
            pageData.clear();
        }
    }
}
```

> **官方提示**："数据量建议 5000 以内"（一次性），分页写入可超过
