# 异步导出

```java
@Async
public String asyncExport(QueryDTO query) {
    String taskId = "EXPORT_" + System.currentTimeMillis();
    String fileName = "/tmp/" + taskId + ".xlsx";

    try (ExcelWriter writer = EasyExcel.write(fileName, OrderExportVO.class).build()) {
        WriteSheet sheet = EasyExcel.writerSheet("订单").build();
        int pageNum = 1, pageSize = 2000;
        while (true) {
            List<OrderExportVO> data = orderMapper.pageQuery(query, pageNum, pageSize);
            if (data.isEmpty()) break;
            writer.write(data, sheet);
            data.clear();
            progressService.update(taskId, pageNum);
            pageNum++;
        }
    }
    return fileName;
}
```
