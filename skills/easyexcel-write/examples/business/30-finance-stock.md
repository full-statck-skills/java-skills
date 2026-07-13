# 业务案例：股票报表（红绿涨跌）

```java
public void exportFinanceReport(List<Stock> stocks, OutputStream out) {
    EasyExcel.write(out, StockVO.class)
        .registerWriteHandler(new CellWriteHandler() {
            @Override
            public void afterCellDispose(CellWriteHandlerContext context) {
                if (BooleanUtils.isNotTrue(context.getHead())
                    && "涨跌".equals(context.getHeadData().getFieldName())) {
                    WriteCellStyle style = context.getFirstCellData().getOrCreateStyle();
                    StockVO data = (StockVO) context.getRowData().getRow();
                    style.setFillForegroundColor(data.getChange().doubleValue() >= 0
                        ? IndexedColors.RED.getIndex()    // 涨：红
                        : IndexedColors.GREEN.getIndex()); // 跌：绿
                    style.setFillPatternType(FillPatternType.SOLID_FOREGROUND);
                }
            }
        })
        .sheet("持仓").doWrite(stocks);
}
```
