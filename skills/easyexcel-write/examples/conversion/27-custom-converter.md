# 自定义转换器

```java
// 状态码 → 中文名称
public class StatusConverter implements Converter<String> {
    @Override
    public Class<?> supportJavaTypeKey() { return String.class; }

    @Override
    public CellDataTypeEnum supportExcelTypeKey() { return CellDataTypeEnum.STRING; }

    @Override
    public WriteCellData<?> convertToExcelData(WriteConverterContext<String> context) {
        String value = context.getValue();
        String label = switch (value) {
            case "ACTIVE" -> "活跃";
            case "INACTIVE" -> "冻结";
            case "DELETED" -> "已注销";
            default -> value;
        };
        return new WriteCellData<>(label);
    }
}

// 使用
@ExcelProperty(value = "状态", converter = StatusConverter.class)
private String status;
```
