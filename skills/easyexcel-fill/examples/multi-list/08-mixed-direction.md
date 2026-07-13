# 多列表混合方向

```java
@Test
public void mixedDirectionFill() {
    String templateFileName = "templates/composite.xlsx";
    String fileName = "output/mixedDirection_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        FillConfig horizontal = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();
        FillConfig vertical = FillConfig.builder()
            .direction(WriteDirectionEnum.VERTICAL).build();

        // data1 横向、data2 纵向
        excelWriter.fill(new FillWrapper("data1", data()), horizontal, writeSheet);
        excelWriter.fill(new FillWrapper("data2", data()), vertical, writeSheet);
    }
}
```
