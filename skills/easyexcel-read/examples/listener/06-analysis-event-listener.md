# AnalysisEventListener（带 head/extra 监听）

```java
@Slf4j
public class DemoHeadDataListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        log.info("解析到一条头数据:{}", JSON.toJSONString(headMap));
    }

    @Override public void invoke(DemoData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}
}
```
