# 同步读取 - 返回 List

```java
@Test
public void synchronousRead() {
    String fileName = "demo.xlsx";
    List<DemoData> list = EasyExcel.read(fileName).head(DemoData.class)
        .sheet().doReadSync();
    for (DemoData data : list) {
        LOGGER.info("读取到数据:{}", JSON.toJSONString(data));
    }
}
```

> **官方原文**："不推荐使用，如果数据量大会把数据放到内存里面"
