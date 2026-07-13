# 合并单元格 - 注解

```java
public class DemoMergeData {
    @ContentLoopMerge(eachRow = 2)
    @ExcelProperty("字符串标题")
    private String string;
    @ContentLoopMerge(eachRow = 2)
    @ExcelProperty("日期标题")
    private Date date;
}

@Test
public void mergeAnnotationWrite() {
    EasyExcel.write(fileName, DemoMergeData.class)
        .sheet("模板")
        .doWrite(data());
}
```
