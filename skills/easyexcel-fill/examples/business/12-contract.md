# 业务案例：合同生成

```java
public void generateContract(ContractDTO contract, String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/contract.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        // 1. 填充头部变量
        Map<String, Object> header = new HashMap<>();
        header.put("contractNo", contract.getContractNo());
        header.put("partyA", contract.getPartyA());
        header.put("partyB", contract.getPartyB());
        header.put("signDate", contract.getSignDate());
        writer.fill(header, sheet);

        // 2. 填充商品列表
        writer.fill(contract.getItems(), sheet);

        // 3. 追加合计行（write 不是 fill）
        List<List<String>> totalRow = new ArrayList<>();
        List<String> row = new ArrayList<>();
        row.add(null); row.add(null); row.add(null);
        row.add("合计: " + contract.getTotalAmount());
        totalRow.add(row);
        writer.write(totalRow, sheet);
    }
}
```
