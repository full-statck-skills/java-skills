# 业务案例：财务报表（横向多列）

```java
public void exportFinanceReport(List<MonthlyFinance> data, String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/finance_report.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        FillConfig horizontalCfg = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();

        // 月份明细横向填充
        writer.fill(new FillWrapper("months", data), horizontalCfg, sheet);
        // 合计行横向填充
        writer.fill(new FillWrapper("totals", data), horizontalCfg, sheet);
    }
}
```
