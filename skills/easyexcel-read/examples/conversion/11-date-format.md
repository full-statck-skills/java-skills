# 日期/数字格式

```java
@Getter
@Setter
@EqualsAndHashCode
public class ConverterData {
    @ExcelProperty(converter = CustomStringStringConverter.class)
    private String string;
    @DateTimeFormat("yyyy年MM月dd日HH时mm分ss秒")
    private String date;
    @NumberFormat("#.##%")
    private String doubleData;
}

@Test
public void converterRead() {
    EasyExcel.read(fileName, ConverterData.class, new ConverterDataListener())
        .sheet().doRead();
}
```

> **官方原文**："registerConverter 会变成全局，所有java为string,excel为string都会用这个转换器；如果就想单个字段使用请使用@ExcelProperty 指定converter"
