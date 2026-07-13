# PageReadListener（since 3.0.0-beta1）

```java
@Test
public void pageReadListener() {
    String fileName = "demo.xlsx";
    EasyExcel.read(fileName, DemoData.class, new PageReadListener<DemoData>(dataList -> {
        for (DemoData d : dataList) {
            log.info("读取到数据: {}", JSON.toJSONString(d));
        }
    })).sheet().doRead();
}
```

> **官方原文**："这里默认每次会读取100条数据 然后返回过来 直接调用使用数据就行。具体需要返回多少行可以在`PageReadListener`的构造函数设置"
