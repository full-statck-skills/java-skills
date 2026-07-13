# 复杂头写入（多级表头）

```java
@Getter
@Setter
@EqualsAndHashCode
public class ComplexHeadData {
    @ExcelProperty({"主标题", "字符串标题"})
    private String string;
    @ExcelProperty({"主标题", "日期标题"})
    private Date date;
    @ExcelProperty({"主标题", "数字标题"})
    private Double doubleData;
}

@Test
public void complexHeadWrite() {
    EasyExcel.write(fileName, ComplexHeadData.class)
        .sheet("模板")
        .doWrite(data());
}
```
