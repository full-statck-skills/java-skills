# 业务案例：发票生成

```java
public void generateInvoice(InvoiceDTO invoice, String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/invoice.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        // 简单对象填充（模板中已预置公式 =SUM()）
        Map<String, Object> vars = new HashMap<>();
        vars.put("invoiceNo", invoice.getInvoiceNo());
        vars.put("customer", invoice.getCustomer());
        vars.put("date", invoice.getDate());

        writer.fill(vars, sheet);
        writer.fill(invoice.getItems(), sheet);
    }
}
```

> **官方原文**："函数（=A2&B2） 这里是不会被填充的"
