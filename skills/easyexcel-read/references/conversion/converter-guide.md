# EasyExcel 转换器与格式完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 来源：https://easyexcel.opensource.alibaba.com/docs/current/api/

## 1. 内置格式

### @DateTimeFormat
```java
@DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
@ExcelProperty("日期")
private Date date;
```

支持的格式参考 `SimpleDateFormat`。

### @NumberFormat
```java
@NumberFormat("#.##%")
@ExcelProperty("占比")
private Double rate;
```

支持的格式参考 `DecimalFormat`。

## 2. 自定义 Converter

### 2.1 字段级 Converter
```java
@ExcelProperty(value = "状态", converter = StatusConverter.class)
private String status;
```

### 2.2 全局 Converter
```java
EasyExcel.read(fileName, ConverterData.class, listener)
    .registerConverter(new CustomStringStringConverter())  // 全局
    .sheet().doRead();
```

> **官方原文**："registerConverter 来指定自定义转换器， 但是这个转换变成全局了...如果就想单个字段使用请使用@ExcelProperty 指定converter"

### 2.3 自定义 Converter 完整模板

```java
public class CustomStringStringConverter implements Converter<String> {
    @Override
    public Class<?> supportJavaTypeKey() {
        return String.class;
    }

    @Override
    public CellDataTypeEnum supportExcelTypeKey() {
        return CellDataTypeEnum.STRING;
    }

    @Override
    public String convertToJavaData(ReadConverterContext<?> context) {
        return "自定义：" + context.getReadCellData().getStringValue();
    }

    @Override
    public WriteCellData<?> convertToExcelData(WriteConverterContext<String> context) {
        return new WriteCellData<>(context.getValue());
    }
}
```

## 3. 实战：枚举转换器

```java
public class OrderStatusConverter implements Converter<OrderStatus> {
    @Override
    public Class<?> supportJavaTypeKey() { return OrderStatus.class; }

    @Override
    public CellDataTypeEnum supportExcelTypeKey() { return CellDataTypeEnum.STRING; }

    @Override
    public OrderStatus convertToJavaData(ReadConverterContext<?> context) {
        return OrderStatus.fromLabel(context.getReadCellData().getStringValue());
    }

    @Override
    public WriteCellData<?> convertToExcelData(WriteConverterContext<OrderStatus> context) {
        return new WriteCellData<>(context.getValue().getLabel());
    }
}
```

## 4. 实战：通用单位换算转换器

```java
public class CentsToYuanConverter implements Converter<BigDecimal> {
    @Override
    public Class<?> supportJavaTypeKey() { return BigDecimal.class; }

    @Override
    public CellDataTypeEnum supportExcelTypeKey() { return CellDataTypeEnum.NUMBER; }

    @Override
    public BigDecimal convertToJavaData(ReadConverterContext<?> context) {
        BigDecimal cents = context.getReadCellData().getNumberValue();
        return cents.divide(new BigDecimal(100));
    }
}
```

## 5. 全局 vs 字段级选择

| 场景 | 选择 |
|------|------|
| 多个字段用相同转换逻辑 | 全局 `registerConverter` |
| 特定字段特殊处理 | 字段 `@ExcelProperty(converter=X.class)` |
| 类型唯一匹配 | 全局 |
| 涉及业务对象 | 字段级 |

## 6. 性能提示

> 全局 Converter 会拦截**所有匹配类型**的字段，可能影响性能；字段级 Converter 仅影响标注字段。

## 7. 转换异常

转换失败会抛出 `ExcelDataConvertException`，可在 `onException` 中处理：

```java
@Override
public void onException(Exception exception, AnalysisContext context) {
    if (exception instanceof ExcelDataConvertException) {
        ExcelDataConvertException ex = (ExcelDataConvertException) exception;
        log.error("第{}行 第{}列 转换失败: 输入={}",
            ex.getRowIndex(), ex.getColumnIndex(), ex.getCellData());
    }
}
```

## 8. @DateTimeFormat use1904windowing

```java
@DateTimeFormat(value = "yyyy-MM-dd", use1904windowing = true)
@ExcelProperty("日期")
private Date date;
```

- Excel for Mac 1904 起始日期
- 默认自动检测
