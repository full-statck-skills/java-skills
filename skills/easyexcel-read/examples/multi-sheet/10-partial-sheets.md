# 读取部分 Sheet

```java
@Test
public void readPartialSheets() {
    String fileName = "demo.xlsx";
    try (ExcelReader excelReader = EasyExcel.read(fileName).build()) {
        ReadSheet readSheet1 = EasyExcel.readSheet(0).head(DemoData.class)
                .registerReadListener(new DemoDataListener()).build();
        ReadSheet readSheet2 = EasyExcel.readSheet(1).head(DemoData.class)
                .registerReadListener(new DemoDataListener()).build();
        // 必须把 sheet1 sheet2 一起传进去
        excelReader.read(readSheet1, readSheet2);
    }
}
```

> **官方原文**："必须把sheet1 sheet2 一起传进去，不然03版excel会读取多次浪费性能"
