# 数据量大的复杂填充（list 放最后一行 + write 追加）

```java
@Test
public void complexFillWithTable() {
    String templateFileName = "templates/complexFillWithTable.xlsx";
    String fileName = "output/complexFillWithTable_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();

        // 1. 写入 list 数据
        excelWriter.fill(data(), writeSheet);
        excelWriter.fill(data(), writeSheet);

        // 2. 写入 list 之前的变量
        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        excelWriter.fill(map, writeSheet);

        // 3. list 后面手动 write 统计行
        List<List<String>> totalListList = new ArrayList<>();
        List<String> totalList = new ArrayList<>();
        totalListList.add(totalList);
        totalList.add(null);
        totalList.add(null);
        totalList.add(null);
        totalList.add("统计:1000");
        excelWriter.write(totalListList, writeSheet);
    }
}
```

> **官方原文**："这里是write 别和fill 搞错了"
