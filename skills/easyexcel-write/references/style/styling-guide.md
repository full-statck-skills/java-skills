# EasyExcel 样式与格式化完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write

## 1. 三种自定义样式方式

### 方式 1：注解
### 方式 2：现有策略（最常用）
```java
WriteCellStyle headStyle = new WriteCellStyle();
headStyle.setFillForegroundColor(IndexedColors.RED.getIndex());
WriteFont headFont = new WriteFont();
headFont.setFontHeightInPoints((short) 20);
headStyle.setWriteFont(headFont);

WriteCellStyle contentStyle = new WriteCellStyle();
contentStyle.setFillPatternType(FillPatternType.SOLID_FOREGROUND);
contentStyle.setFillForegroundColor(IndexedColors.GREEN.getIndex());

HorizontalCellStyleStrategy strategy =
    new HorizontalCellStyleStrategy(headStyle, contentStyle);

EasyExcel.write(fileName, DemoData.class)
    .registerWriteHandler(strategy)
    .sheet("模板").doWrite(data());
```

### 方式 3：自定义拦截器（最灵活）
```java
EasyExcel.write(fileName, StockVO.class)
    .registerWriteHandler(new CellWriteHandler() {
        @Override
        public void afterCellDispose(CellWriteHandlerContext context) {
            if (BooleanUtils.isNotTrue(context.getHead())
                && "涨跌".equals(context.getHeadData().getFieldName())) {
                WriteCellStyle style = context.getFirstCellData().getOrCreateStyle();
                StockVO data = (StockVO) context.getRowData().getRow();
                style.setFillForegroundColor(data.getChange().doubleValue() >= 0
                    ? IndexedColors.RED.getIndex()
                    : IndexedColors.GREEN.getIndex());
                style.setFillPatternType(FillPatternType.SOLID_FOREGROUND);
            }
        }
    }).sheet("持仓").doWrite(stocks);
```

## 2. 日期与数字格式

### @DateTimeFormat
```java
@DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
@ExcelProperty("日期")
private Date date;
```

### @NumberFormat
```java
@NumberFormat("#.##%")
@ExcelProperty("占比")
private Double rate;
```

## 3. 列宽与行高

```java
@Getter
@Setter
@EqualsAndHashCode
@ContentRowHeight(10)
@HeadRowHeight(20)
@ColumnWidth(25)
public class WidthAndHeightData {
    @ExcelProperty("字符串标题")
    private String string;
    @ColumnWidth(50)
    @ExcelProperty("数字标题")
    private Double doubleData;
}
```

## 4. 自动列宽（不太精确）

```java
EasyExcel.write(fileName, LongestMatchColumnWidthData.class)
    .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
    .sheet("模板").doWrite(dataLong());
```

## 5. 性能提示

> **官方原文**："不要一直去创建style 记得缓存起来 最多创建6W个就挂了"

样式对象（`WriteCellStyle` `WriteFont` `HorizontalCellStyleStrategy`）应当：
- 作为静态变量复用
- 不要在循环中 `new`
- 一个 Excel 最多 ~60000 个样式对象
