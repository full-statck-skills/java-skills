# 异常处理

```java
@Override
public void onException(Exception exception, AnalysisContext context) {
    log.error("解析失败，但是继续解析下一行:{}", exception.getMessage());
    if (exception instanceof ExcelDataConvertException) {
        ExcelDataConvertException excelDataConvertException =
            (ExcelDataConvertException) exception;
        log.error("第{}行，第{}列解析异常，数据为:{}",
            excelDataConvertException.getRowIndex(),
            excelDataConvertException.getColumnIndex(),
            excelDataConvertException.getCellData());
    }
    // 抛出异常则停止读取；不抛出则继续
}

@Test
public void exceptionRead() {
    EasyExcel.read(fileName, ExceptionDemoData.class, new DemoExceptionListener())
        .sheet().doRead();
}
```

> **官方原文**："在转换异常 获取其他异常下会调用本接口。抛出异常则停止读取。如果这里不抛出异常则 继续读取下一行。"
