# 列表填充 - 一次性

```java
private List<FillData> data() {
    List<FillData> list = new ArrayList<>();
    for (int i = 0; i < 10; i++) {
        FillData data = new FillData();
        data.setName("张三" + i);
        data.setNumber(5.2 + i);
        data.setDate(new Date());
        list.add(data);
    }
    return list;
}

@Test
public void listFillOnce() {
    String templateFileName = "templates/list.xlsx";
    String fileName = "output/listFill_once_" + System.currentTimeMillis() + ".xlsx";

    // 一次性放入内存并填充
    EasyExcel.write(fileName).withTemplate(templateFileName)
        .sheet().doFill(data());
}
```

> **官方原文**："分多次 填充 会使用文件缓存"
