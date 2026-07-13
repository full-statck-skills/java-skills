# 业务案例：对账单（list 后 write 合计行）

```java
public void exportReconciliation(List<ReconciliationItem> items,
                                 ReconciliationHeader header,
                                 String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/reconciliation.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        // 1. 填充列表
        writer.fill(items, sheet);

        // 2. 填充头部变量
        Map<String, Object> headerMap = new HashMap<>();
        headerMap.put("date", header.getDate());
        headerMap.put("accountNo", header.getAccountNo());
        writer.fill(headerMap, sheet);

        // 3. 写合计行（这里是 write 不是 fill）
        BigDecimal total = items.stream()
            .map(ReconciliationItem::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        List<List<String>> totalRow = new ArrayList<>();
        List<String> row = new ArrayList<>();
        row.add(null); row.add(null); row.add("合计");
        row.add(total.toString());
        totalRow.add(row);
        writer.write(totalRow, sheet);
    }
}
```

> **官方原文**："这里是write 别和fill 搞错了"
