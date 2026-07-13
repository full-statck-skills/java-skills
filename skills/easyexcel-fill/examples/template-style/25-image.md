# 模板中含图章/图片

```java
// 模板里预置公司图章
// 填充时只填文字变量，图章保持原位

// 示例
try (ExcelWriter writer = EasyExcel.write(outputPath)
        .withTemplate("templates/contract_with_seal.xlsx").build()) {
    WriteSheet sheet = EasyExcel.writerSheet().build();
    Map<String, Object> data = new HashMap<>();
    data.put("contractNo", "HT-2024-001");
    data.put("partyA", "甲方公司");
    writer.fill(data, sheet);
}
```

> **官方原文**："图片都会放到内存 暂时没有很好的解法，大量图片的情况下建议…将图片上传到oss"
