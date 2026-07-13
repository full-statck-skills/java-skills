# 额外信息（批注/超链接/合并单元格）

```java
@Slf4j
public class DemoExtraListener implements ReadListener<DemoExtraData> {
    @Override public void invoke(DemoExtraData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}

    @Override
    public void extra(CellExtra extra, AnalysisContext context) {
        switch (extra.getType()) {
            case COMMENT:
                log.info("批注 row={}, col={}, 内容={}",
                    extra.getRowIndex(), extra.getColumnIndex(), extra.getText());
                break;
            case HYPERLINK:
                log.info("超链接 row={}, col={}, 内容={}",
                    extra.getRowIndex(), extra.getColumnIndex(), extra.getText());
                break;
            case MERGE:
                log.info("合并 firstRow={}, lastRow={}, firstCol={}, lastCol={}",
                    extra.getFirstRowIndex(), extra.getLastRowIndex(),
                    extra.getFirstColumnIndex(), extra.getLastColumnIndex());
                break;
        }
    }
}

@Test
public void extraRead() {
    EasyExcel.read(fileName, DemoExtraData.class, new DemoExtraListener())
        .extraRead(CellExtraTypeEnum.COMMENT)
        .extraRead(CellExtraTypeEnum.HYPERLINK)
        .extraRead(CellExtraTypeEnum.MERGE)
        .sheet().doRead();
}
```

> **官方原文**："批注、超链接、合并单元格信息默认不读取，需显式调用"
