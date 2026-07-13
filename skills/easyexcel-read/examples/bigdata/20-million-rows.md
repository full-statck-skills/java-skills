# 百万级导入（分批入库）

```java
@Test
public void largeExcelImport() {
    EasyExcel.read(fileName, OrderDTO.class, new ReadListener<OrderDTO>() {
        private static final int BATCH_COUNT = 2000;
        private List<OrderDTO> cachedList = new ArrayList<>(BATCH_COUNT);

        @Override
        public void invoke(OrderDTO data, AnalysisContext context) {
            cachedList.add(data);
            if (cachedList.size() >= BATCH_COUNT) {
                orderDAO.batchInsert(cachedList);
                cachedList.clear();
                log.info("已处理 {} 行", context.getCurrentRowNum());
            }
        }

        @Override
        public void doAfterAllAnalysed(AnalysisContext context) {
            if (!cachedList.isEmpty()) {
                orderDAO.batchInsert(cachedList);
            }
        }
    }).sheet().doRead();
}
```
