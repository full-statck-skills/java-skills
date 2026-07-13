# CSV 读取

```java
public List<DemoData> readCsv(String fileName) {
    return EasyExcel.read(fileName, DemoData.class, new DemoDataListener())
        .excelType(ExcelTypeEnum.CSV)
        .charset(StandardCharsets.UTF_8)
        .sheet()
        .doReadSync();
}
```

> **官方提示**：EasyExcel 通过 `excelType(ExcelTypeEnum.CSV)` 支持 CSV 文件。
