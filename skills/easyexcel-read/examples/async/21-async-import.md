# 异步导入（提交任务）

```java
@PostMapping("/api/orders/async-import")
public Result<String> asyncImport(@RequestParam MultipartFile file) {
    String taskId = "IMPORT_" + System.currentTimeMillis();
    asyncTaskExecutor.execute(() -> {
        try {
            ImportResult<OrderDTO> result = orderService.importOrders(file);
            importTaskService.complete(taskId, result);
        } catch (Exception e) {
            importTaskService.fail(taskId, e.getMessage());
        }
    });
    return Result.ok("导入任务已提交，taskId: " + taskId);
}
```
