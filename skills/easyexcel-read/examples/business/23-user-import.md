# 业务案例：用户批量导入（容错）

```java
@Slf4j
class TolerantListener extends AnalysisEventListener<UserDTO> {
    private static final int BATCH_COUNT = 200;
    private final List<UserDTO> cachedList = new ArrayList<>(BATCH_COUNT);
    private final List<ImportError> errors = new ArrayList<>();

    @Override
    public void invoke(UserDTO data, AnalysisContext context) {
        if (data.getEmail() == null || !data.getEmail().contains("@")) {
            errors.add(new ImportError(context.getCurrentRowNum(), -1, "邮箱格式错误"));
            return;
        }
        cachedList.add(data);
        if (cachedList.size() >= BATCH_COUNT) saveData();
    }

    @Override
    public void onException(Exception exception, AnalysisContext context) {
        if (exception instanceof ExcelDataConvertException) {
            ExcelDataConvertException ex = (ExcelDataConvertException) exception;
            errors.add(new ImportError(ex.getRowIndex(), ex.getColumnIndex(),
                "转换失败: " + ex.getCellData()));
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) { saveData(); }

    private void saveData() {
        if (!cachedList.isEmpty()) {
            userDAO.batchInsert(cachedList);
            cachedList.clear();
        }
    }
}
```
