# EasyExcel 写入 注解完整参考

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/api/
> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write

## 1. 字段级注解

### @ExcelProperty
**作用**：指定表头/索引/转换器

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| value | String[] | 空 | 表头名称，单/多级表头 |
| order | int | Integer.MAX_VALUE | 字段顺序 |
| index | int | -1 | 列下标（0 开始） |
| converter | Class<? extends Converter> | 自动 | 字段级转换器 |

**优先级**：`index` > `order` > `value`

> **官方原文**："不建议 index 和 name 同时用"

### @ExcelIgnore
**作用**：忽略该字段
```java
@ExcelIgnore
private String password;
```

### @ExcelIgnoreUnannotated
**作用**：类级，未标注 `@ExcelProperty` 的字段不参与读写

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

## 2. 类级 / 字段级 尺寸注解

### @ColumnWidth
### @HeadRowHeight
### @ContentRowHeight

## 3. 样式注解（since 2.2.0-beta1）

### @HeadStyle / @ContentStyle
### @HeadFontStyle / @ContentFontStyle

**示例**：
```java
@Data
@HeadStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 10)
@HeadFontStyle(fontHeightInPoints = 20, color = 20, bold = true)
@ContentStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 17)
@ContentFontStyle(fontHeightInPoints = 20)
public class DemoStyleData {
    @ExcelProperty("字符串标题")
    private String string;
}
```

## 4. 合并单元格注解

### @ContentLoopMerge
```java
@ContentLoopMerge(eachRow = 2)
@ExcelProperty("字符串标题")
private String string;
```

### @OnceAbsoluteMerge
```java
@OnceAbsoluteMerge(firstRowIndex = 1, lastRowIndex = 2, firstColumnIndex = 0, lastColumnIndex = 1)
@ExcelProperty("大标题")
private String bigTitle;
```
