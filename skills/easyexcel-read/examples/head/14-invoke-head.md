# 读取表头数据

```java
@Slf4j
public class DemoHeadDataListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        log.info("解析到一条头数据:{}", JSON.toJSONString(headMap));
        // 转成 Map<Integer,String>：
        // 方案 1：不implements ReadListener 而是 extends AnalysisEventListener
        // 方案 2：调用 ConverterUtils.convertToStringMap(headMap, context)
    }
    @Override public void invoke(DemoData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}
}

@Test
public void headerRead() {
    EasyExcel.read(fileName, DemoData.class, new DemoHeadDataListener())
        .sheet().doRead();
}
```
