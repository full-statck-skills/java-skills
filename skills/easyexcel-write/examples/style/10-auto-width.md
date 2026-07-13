# 自动列宽

```java
@Test
public void autoColumnWidthWrite() {
    EasyExcel.write(fileName, LongestMatchColumnWidthData.class)
        .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
        .sheet("模板")
        .doWrite(dataLong());
}
```

> **官方原文**："自动列宽（不太精确）"
