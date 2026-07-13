# 异步导出（大数据量）

```java
@Async
public CompletableFuture<String> asyncExport(QueryDTO query) {
    String taskId = "FILL_" + System.currentTimeMillis();
    String outputPath = "/tmp/" + taskId + ".xlsx";

    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("/templates/order_list.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        int pageNum = 1, pageSize = 2000;
        while (true) {
            List<OrderDTO> page = orderMapper.findPage(query, pageNum, pageSize);
            if (page.isEmpty()) break;
            writer.fill(page, sheet);
            page.clear();
            pageNum++;
            progressService.update(taskId, pageNum);
        }
    }
    return CompletableFuture.completedFuture(outputPath);
}
```
