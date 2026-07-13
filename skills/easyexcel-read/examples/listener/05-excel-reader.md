# ExcelReader（一个文件一个 reader）

```java
@Test
public void excelReaderRead() {
    String fileName = "demo.xlsx";
    try (ExcelReader excelReader = EasyExcel.read(fileName, DemoData.class,
            new DemoDataListener()).build()) {
        ReadSheet readSheet = EasyExcel.readSheet(0).build();
        excelReader.read(readSheet);
    }
}
```
