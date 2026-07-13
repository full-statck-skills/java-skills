# 策略方式自定义样式

```java
@Test
public void styleStrategyWrite() {
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
        .sheet("模板")
        .doWrite(data());
}
```

> **官方原文**："不要一直去创建style 记得缓存起来 最多创建6W个就挂了"
