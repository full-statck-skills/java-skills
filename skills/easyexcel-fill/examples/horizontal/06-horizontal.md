# 横向填充

```java
@Test
public void horizontalFill() {
    String templateFileName = "templates/horizontal.xlsx";
    String fileName = "output/horizontalFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        FillConfig fillConfig = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();
        excelWriter.fill(data(), fillConfig, writeSheet);
        excelWriter.fill(data(), fillConfig, writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        excelWriter.fill(map, writeSheet);
    }
}
```
