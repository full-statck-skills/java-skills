# 最简写入 - 3 种写法

```java
private List<DemoData> data() {
    List<DemoData> list = new ArrayList<>();
    for (int i = 0; i < 10; i++) {
        DemoData data = new DemoData();
        data.setString("字符串" + i);
        data.setDate(new Date());
        data.setDoubleData(0.56);
        list.add(data);
    }
    return list;
}

@Test
public void simpleWrite() {
    String fileName = "simpleWrite" + System.currentTimeMillis() + ".xlsx";

    // 写法 1：JDK8+ Supplier
    EasyExcel.write(fileName, DemoData.class)
        .sheet("模板")
        .doWrite(() -> data());

    // 写法 2：传统
    EasyExcel.write(fileName, DemoData.class)
        .sheet("模板")
        .doWrite(data());

    // 写法 3：Builder
    try (ExcelWriter excelWriter = EasyExcel.write(fileName, DemoData.class).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet("模板").build();
        excelWriter.write(data(), writeSheet);
    }
}
```

> **官方原文**："数据量建议 5000 以内"
