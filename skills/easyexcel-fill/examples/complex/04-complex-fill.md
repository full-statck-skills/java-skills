# 复杂填充（list 后还有内容）

```java
@Test
public void complexFill() {
    String templateFileName = "templates/complex.xlsx";
    String fileName = "output/complexFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        // ⚠️ 关键：forceNewRow=true
        FillConfig fillConfig = FillConfig.builder()
            .forceNewRow(Boolean.TRUE).build();

        excelWriter.fill(data(), fillConfig, writeSheet);
        excelWriter.fill(data(), fillConfig, writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        map.put("total", 1000);
        excelWriter.fill(map, writeSheet);
    }
}
```

> **官方原文**："在 02 版上面 模板 list 不是最后一行 下面还有数据 需要设置 forceNewRow=true 但是有一个缺点 就是他会把所有的数据都放到内存了 慎用"
