# 性能优化：内存控制

```java
// ✅ 推荐：分次填充（文件缓存）
try (ExcelWriter writer = EasyExcel.write(fileName)
        .withTemplate(templateFileName).build()) {
    WriteSheet sheet = EasyExcel.writerSheet().build();
    writer.fill(list, sheet);  // 第 1 批
    writer.fill(list, sheet);  // 第 2 批
    // 自动文件缓存，不占内存
}

// ⚠️ 慎用：forceNewRow=true 全量驻内存
FillConfig cfg = FillConfig.builder().forceNewRow(Boolean.TRUE).build();
// 数据量大时 OOM
```

> **官方原文**："forceNewRow 如果设置了true,有个缺点 就是他会把所有的数据都放到内存了，所以慎用"
