# 读取全部 Sheet

```java
@Test
public void readAllSheets() {
    String fileName = "demo.xlsx";
    EasyExcel.read(fileName, DemoData.class, new DemoDataListener())
        .doReadAll();
}
```

> **官方原文**："doAfterAllAnalysed 会在每个sheet读取完毕后调用一次"
