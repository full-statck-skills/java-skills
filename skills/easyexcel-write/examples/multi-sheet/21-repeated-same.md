# 同一对象不同 Sheet 多次写入

```java
@Test
public void repeatedWrite() {
    try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
        for (int i = 0; i < 5; i++) {
            WriteSheet writeSheet = EasyExcel.writerSheet(i, "模板" + i).build();
            excelWriter.write(data(), writeSheet);
        }
    }
}
```
