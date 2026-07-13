# EasyExcel 异常处理与容错读取完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read

## 1. 异常类型

| 异常 | 说明 |
|------|------|
| `ExcelDataConvertException` | 转换异常（类型/格式） |
| `ExcelAnalysisException` | 解析异常（文件结构） |
| `ExcelGenerateException` | 写入异常（写入时） |
| `ExcelCommonException` | 通用异常 |

## 2. onException 标准处理

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
    // ⚠️ 不抛出异常 → 继续读取下一行
    // ⚠️ 抛出异常   → 停止读取
}
```

> **官方原文**："在转换异常 获取其他异常下会调用本接口。抛出异常则停止读取。如果这里不抛出异常则 继续读取下一行。"

## 3. 实战：收集所有错误行

```java
@Slf4j
public class TolerantListener extends AnalysisEventListener<DemoData> {
    private final List<ExcelDataConvertException> errors = new ArrayList<>();
    private final List<DemoData> successData = new ArrayList<>();

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        successData.add(data);
    }

    @Override
    public void onException(Exception exception, AnalysisContext context) {
        if (exception instanceof ExcelDataConvertException) {
            errors.add((ExcelDataConvertException) exception);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        log.info("成功 {} 条, 失败 {} 条", successData.size(), errors.size());
    }

    public List<ExcelDataConvertException> getErrors() { return errors; }
}
```

## 4. 实战：跳过异常行继续读取

```java
@Slf4j
public class SkipErrorListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invoke(DemoData data, AnalysisContext context) {}

    @Override
    public void onException(Exception exception, AnalysisContext context) {
        log.warn("跳过异常行: {}", exception.getMessage());
    }
}
```

## 5. 实战：异常中止 + 错误报告

```java
@Slf4j
public class FailFastListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invoke(DemoData data, AnalysisContext context) {}

    @Override
    public void onException(Exception exception, AnalysisContext context) {
        log.error("中止: {}", exception.getMessage());
        throw new BizException("IMPORT_FAILED", ...);
    }
}
```

## 6. ExcelDataConvertException 完整字段

| 方法 | 用途 |
|------|------|
| `getRowIndex()` | 出错行号 |
| `getColumnIndex()` | 出错列号 |
| `getCellData()` | 原始单元格数据 |
| `getExcelCoordinate()` | Excel 坐标（A1, B2） |
| `getMessage()` | 错误信息 |
| `getCause()` | 原始异常 |

## 7. 实战：多行容错 + 部分入库

```java
public ImportResult importUsers(MultipartFile file) {
    TolerantListener listener = new TolerantListener();
    try {
        EasyExcel.read(file.getInputStream(), UserDTO.class, listener)
            .sheet().doRead();

        ImportResult result = new ImportResult();
        result.setSuccessCount(listener.getSuccessData().size());
        result.setErrorCount(listener.getErrors().size());
        result.setErrors(listener.getErrors().stream()
            .map(e -> new ImportError(e.getRowIndex(), e.getColumnIndex(), e.getMessage()))
            .collect(Collectors.toList()));
        return result;
    } catch (Exception e) {
        throw new BizException("IMPORT_FAILED", e.getMessage());
    }
}
```

## 8. Web 场景：失败回 JSON

```java
@PostMapping("/api/import")
public Result<ImportResult> importExcel(@RequestParam MultipartFile file) {
    try {
        ImportResult result = importService.importUsers(file);
        return Result.ok(result);
    } catch (ExcelAnalysisException e) {
        return Result.fail("文件结构错误: " + e.getMessage());
    } catch (ExcelDataConvertException e) {
        return Result.fail("第" + e.getRowIndex() + "行 第" + e.getColumnIndex()
            + "列 数据格式错误: " + e.getCellData());
    } catch (Exception e) {
        return Result.fail("导入失败: " + e.getMessage());
    }
}
```

## 9. 监听器外部捕获

```java
try {
    EasyExcel.read(fileName, DemoData.class, listener).sheet().doRead();
} catch (ExcelAnalysisException e) {
    log.error("文件结构错误: {}", e.getMessage());
} catch (Exception e) {
    log.error("读取失败: {}", e.getMessage(), e);
}
```

## 10. 关键提示

> **官方原文**："onException 默认是 abstract，子类可选实现。如果不实现，遇到异常会直接抛出，中断读取。"
> **官方原文**："为了保证数据完整性，建议在监听器中实现 onException 收集错误行。"

## 11. 验证数据完整性

```java
public ImportResult importWithValidation(MultipartFile file) {
    TolerantListener listener = new TolerantListener();
    EasyExcel.read(file.getInputStream(), UserDTO.class, listener)
        .sheet().doRead();
    // 业务校验（在监听器 invoke 中调用）
    return new ImportResult(listener.getSuccessData(), listener.getErrors());
}
```
