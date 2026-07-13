# 业务案例：对账文件解析（容错 + 错误导出）

```java
public ReconciliationResult parseReconciliation(MultipartFile file) {
    ReconciliationListener listener = new ReconciliationListener();
    EasyExcel.read(file.getInputStream(), ReconciliationItemDTO.class, listener)
        .sheet().doRead();

    ReconciliationResult result = new ReconciliationResult();
    result.setItems(listener.getItems());
    result.setErrorRows(listener.getErrors());
    return result;
}
```

> 适合对账文件、第三方导入文件、Excel 数据校验等场景
