# 公式

```java
WriteCellData<String> formula = new WriteCellData<>();
writeCellDemoData.setFormulaData(formula);
FormulaData formulaData = new FormulaData();
formula.setFormulaData(formulaData);
formulaData.setFormulaValue("REPLACE(123456789,1,1,2)");
```

> 支持的 Excel 公式与 Excel 原生一致：SUM、AVERAGE、IF、VLOOKUP 等
