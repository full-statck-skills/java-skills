# 列表填充 - 分次填充（文件缓存，省内存）

```java
@Test
public void listFillMultiTimes() {
    String templateFileName = "templates/list.xlsx";
    String fileName = "output/listFill_multi_" + System.currentTimeMillis() + ".xlsx";

    // 分次填充 → 自动使用文件缓存，省内存（推荐）
    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        excelWriter.fill(data(), writeSheet);
        excelWriter.fill(data(), writeSheet);
    }
}
```

> **官方原文**："分多次 填充 会使用文件缓存"
