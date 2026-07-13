# 数字/日期格式化

```java
@Getter
@Setter
@EqualsAndHashCode
public class ConverterData {
    @ExcelProperty(value = "字符串标题", converter = CustomStringStringConverter.class)
    private String string;
    @DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
    @ExcelProperty("日期标题")
    private Date date;
    @NumberFormat("#.##%")
    @ExcelProperty("数字标题")
    private Double doubleData;
}

@Test
public void converterWrite() {
    EasyExcel.write(fileName, ConverterData.class)
        .sheet("模板")
        .doWrite(data());
}
```
