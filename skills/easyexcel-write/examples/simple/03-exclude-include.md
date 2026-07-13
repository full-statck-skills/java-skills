# 排除/包含列

```java
@Test
public void excludeOrIncludeWrite() {
    String fileName = "excludeOrIncludeWrite" + System.currentTimeMillis() + ".xlsx";

    // 排除某列
    Set<String> excludeColumnFiledNames = new HashSet<>();
    excludeColumnFiledNames.add("date");
    EasyExcel.write(fileName, DemoData.class)
        .excludeColumnFiledNames(excludeColumnFiledNames)
        .sheet("模板")
        .doWrite(data());

    // 只导出某列
    Set<String> includeColumnFiledNames = new HashSet<>();
    includeColumnFiledNames.add("date");
    EasyExcel.write(fileName, DemoData.class)
        .includeColumnFiledNames(includeColumnFiledNames)
        .sheet("模板")
        .doWrite(data());
}
```

> **官方原文**："order 会忽略空列，index 不会忽略"
