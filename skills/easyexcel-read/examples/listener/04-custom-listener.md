# 自定义 ReadListener（标准模板）

```java
@Slf4j
public class DemoDataListener implements ReadListener<DemoData> {
    private static final int BATCH_COUNT = 100;
    private List<DemoData> cachedDataList =
        ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
    private DemoDAO demoDAO;

    public DemoDataListener() {
        demoDAO = new DemoDAO();
    }

    public DemoDataListener(DemoDAO demoDAO) {
        this.demoDAO = demoDAO;
    }

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        log.info("解析到一条数据:{}", JSON.toJSONString(data));
        cachedDataList.add(data);
        if (cachedDataList.size() >= BATCH_COUNT) {
            saveData();
            cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        saveData();
    }

    private void saveData() {
        log.info("{}条数据，开始存储数据库！", cachedDataList.size());
        demoDAO.save(cachedDataList);
    }
}
```

> **官方原文**："DemoDataListener 不能被spring管理，要每次读取excel都要new"
