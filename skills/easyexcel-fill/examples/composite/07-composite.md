# 多列表组合填充

```java
@Test
public void compositeFill() {
    String templateFileName = "templates/composite.xlsx";
    String fileName = "output/compositeFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        FillConfig fillConfig = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();

        // ⚠️ 多 list 必须用 FillWrapper
        excelWriter.fill(new FillWrapper("data1", data()), fillConfig, writeSheet);
        excelWriter.fill(new FillWrapper("data2", data()), writeSheet);
        excelWriter.fill(new FillWrapper("data3", data()), writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", new Date());
        excelWriter.fill(map, writeSheet);
    }
}
```

> **官方原文**："多个 list 必须用 FillWrapper 包裹；{前缀.} 前缀可以区分不同的list"
