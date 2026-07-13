# 富文本

```java
WriteCellData<String> richText = new WriteCellData<>();
richText.setType(CellDataTypeEnum.RICH_TEXT_STRING);
writeCellDemoData.setRichText(richText);
RichTextStringData richTextStringData = new RichTextStringData();
richText.setRichTextStringDataValue(richTextStringData);
richTextStringData.setTextString("红色绿色默认");

WriteFont writeFont = new WriteFont();
writeFont.setColor(IndexedColors.RED.getIndex());
richTextStringData.applyFont(0, 2, writeFont);  // 0~2 红色

writeFont = new WriteFont();
writeFont.setColor(IndexedColors.GREEN.getIndex());
richTextStringData.applyFont(2, 4, writeFont);  // 2~4 绿色
```
