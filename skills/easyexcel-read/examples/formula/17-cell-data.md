# 公式和单元格类型

```java
@Getter
@Setter
@EqualsAndHashCode
public class CellDataReadDemoData {
    private CellData<String> string;
    // 虽然是日期，但类型存储的是 number
    private CellData<Date> date;
    private CellData<Double> doubleData;
    // 依赖性公式可能读不到，后续会修复
    private CellData<String> formulaValue;
}

@Test
public void cellDataRead() {
    EasyExcel.read(fileName, CellDataReadDemoData.class, new CellDataDemoHeadDataListener())
        .sheet().doRead();
}
```

> **官方原文**："依赖性公式可能读不到，后续会修复"
