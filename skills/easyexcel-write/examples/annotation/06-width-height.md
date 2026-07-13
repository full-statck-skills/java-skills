# 列宽与行高

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

@Test
public void widthAndHeightWrite() {
    EasyExcel.write(fileName, WidthAndHeightData.class)
        .sheet("模板")
        .doWrite(data());
}
```
