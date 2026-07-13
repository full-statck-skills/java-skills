# 指定写入的列

```java
@Getter
@Setter
@EqualsAndHashCode
public class IndexData {
    @ExcelProperty(value = "字符串标题", index = 0)
    private String string;
    @ExcelProperty(value = "日期标题", index = 1)
    private Date date;
    @ExcelProperty(value = "数字标题", index = 3)  // 跳过一列
    private Double doubleData;
}

@Test
public void indexWrite() {
    EasyExcel.write(fileName, IndexData.class)
        .sheet("模板")
        .doWrite(data());
}
```
