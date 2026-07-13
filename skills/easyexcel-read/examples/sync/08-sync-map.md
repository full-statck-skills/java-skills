# 同步读取 - 返回 List<Map>

```java
@Test
public void synchronousReadAsMap() {
    String fileName = "demo.xlsx";
    List<Map<Integer, String>> listMap = EasyExcel.read(fileName)
        .sheet().doReadSync();
    for (Map<Integer, String> data : listMap) {
        LOGGER.info("读取到数据:{}", JSON.toJSONString(data));
    }
}
```
