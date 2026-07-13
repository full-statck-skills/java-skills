# 匿名 ReadListener

```java
@Test
public void anonymousListener() {
    String fileName = "demo.xlsx";
    EasyExcel.read(fileName, DemoData.class, new ReadListener<DemoData>() {
        private static final int BATCH_COUNT = 100;
        private List<DemoData> cachedDataList =
            ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);

        @Override
        public void invoke(DemoData data, AnalysisContext context) {
            cachedDataList.add(data);
            if (cachedDataList.size() >= BATCH_COUNT) {
                saveData();
                cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
            }
        }
        @Override
        public void doAfterAllAnalysed(AnalysisContext context) { saveData(); }
        private void saveData() {
            log.info("{}条数据，开始存储数据库！", cachedDataList.size());
        }
    }).sheet().doRead();
}
```
