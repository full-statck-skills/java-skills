# EasyExcel 模板填充 真实业务案例

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 综合官方文档、GitHub 仓库示例、社区实践整理

## 案例 1：工资条批量导出（简单对象 + 循环 + ZIP 打包）

```java
@Service
public class SalaryFillService {

    public byte[] batchExport(List<String> employeeIds) throws IOException {
        ByteArrayOutputStream zipBaos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(zipBaos)) {
            for (String empId : employeeIds) {
                SalaryDTO salary = salaryMapper.findByEmployee(empId);
                ByteArrayOutputStream xlsxBaos = new ByteArrayOutputStream();

                // 直接写入 OutputStream，模板以流方式加载
                try (InputStream templateIn = getClass()
                        .getResourceAsStream("/templates/salary.xlsx");
                     ExcelWriter writer = EasyExcel.write(xlsxBaos)
                             .withTemplate(templateIn).build()) {
                    WriteSheet sheet = EasyExcel.writerSheet().build();
                    writer.fill(salary, sheet);
                }

                ZipEntry entry = new ZipEntry("salary_" + empId + ".xlsx");
                zos.putNextEntry(entry);
                zos.write(xlsxBaos.toByteArray());
                zos.closeEntry();
            }
        }
        return zipBaos.toByteArray();
    }
}
```

## 案例 2：合同生成（多变量 + 列表组合）

```java
public void generateContract(ContractDTO contract, String outputPath) {
    // 合同模板：头部 {contractNo} {partyA} {partyB} + 列表 {items.}
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/contract.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        // 填充头部变量
        Map<String, Object> header = new HashMap<>();
        header.put("contractNo", contract.getContractNo());
        header.put("partyA", contract.getPartyA());
        header.put("partyB", contract.getPartyB());
        header.put("signDate", contract.getSignDate());
        writer.fill(header, sheet);

        // 填充商品列表
        writer.fill(contract.getItems(), sheet);

        // 追加合计行
        List<List<String>> totalRow = new ArrayList<>();
        List<String> row = new ArrayList<>();
        row.add(null); row.add(null); row.add(null);
        row.add("合计: " + contract.getTotalAmount());
        totalRow.add(row);
        writer.write(totalRow, sheet);
    }
}
```

## 案例 3：财务报表（多列表横向）

```java
public void exportFinanceReport(List<MonthlyFinance> data, String outputPath) {
    // 模板：{months.} 横向展开 12 个月份 + {totals.} 横向展开合计
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/finance_report.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        FillConfig horizontalCfg = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();

        // 月份明细横向填充
        writer.fill(new FillWrapper("months", data), horizontalCfg, sheet);
        // 合计行横向填充
        writer.fill(new FillWrapper("totals", data), horizontalCfg, sheet);
    }
}
```

## 案例 4：对账单（list 放最后一行 + write 追加合计）

```java
public void exportReconciliation(List<ReconciliationItem> items,
                                 ReconciliationHeader header,
                                 String outputPath) {
    // 模板：{date} {accountNo} 头部 + 列表 {items.} 在最后一行
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/reconciliation.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        // 1. 填充列表
        writer.fill(items, sheet);

        // 2. 填充头部变量
        Map<String, Object> headerMap = new HashMap<>();
        headerMap.put("date", header.getDate());
        headerMap.put("accountNo", header.getAccountNo());
        writer.fill(headerMap, sheet);

        // 3. 写合计行（这里是 write 不是 fill）
        BigDecimal totalAmount = items.stream()
            .map(ReconciliationItem::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        List<List<String>> totalRow = new ArrayList<>();
        List<String> row = new ArrayList<>();
        row.add(null); row.add(null); row.add("合计");
        row.add(totalAmount.toString());
        totalRow.add(row);
        writer.write(totalRow, sheet);
    }
}
```

## 案例 5：Web 单条数据下载

```java
@GetMapping("/api/contract/{id}/download")
public void downloadContract(@PathVariable Long id,
                             HttpServletResponse response) throws IOException {
    ContractDTO contract = contractService.findById(id);

    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setCharacterEncoding("utf-8");
    String fileName = URLEncoder.encode("合同_" + contract.getContractNo(), "UTF-8")
        .replaceAll("\\+", "%20");
    response.setHeader("Content-disposition",
        "attachment;filename*=utf-8''" + fileName + ".xlsx");

    try (InputStream templateIn = getClass()
            .getResourceAsStream("/templates/contract.xlsx");
         ExcelWriter writer = EasyExcel.write(response.getOutputStream())
                 .withTemplate(templateIn).build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        Map<String, Object> header = new HashMap<>();
        header.put("contractNo", contract.getContractNo());
        header.put("partyA", contract.getPartyA());
        writer.fill(header, sheet);
        writer.fill(contract.getItems(), sheet);
    }
}
```

## 案例 6：大数据量（10万+）分次填充

```java
public void exportLargeOrderList(String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/order_list.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        int pageNum = 1;
        int pageSize = 2000;
        while (true) {
            List<OrderDTO> page = orderMapper.findPage(pageNum, pageSize);
            if (page.isEmpty()) break;

            // 分次 fill —— 自动使用文件缓存，省内存
            writer.fill(page, sheet);
            page.clear();
            pageNum++;
        }

        // 写头部变量
        Map<String, Object> header = new HashMap<>();
        header.put("exportTime", new Date());
        header.put("totalCount", orderMapper.count());
        writer.fill(header, sheet);
    }
}
```

## 案例 7：失败回 JSON 模式（Web 增强版）

```java
@GetMapping("/api/salary/export")
public void exportSalary(@RequestParam String empId,
                         HttpServletResponse response) {
    try {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("工资条", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition",
            "attachment;filename*=utf-8''" + fileName + ".xlsx");

        try (InputStream tpl = getClass()
                .getResourceAsStream("/templates/salary.xlsx");
             // autoCloseStream=false 失败时还要 reset 输出 JSON
             ExcelWriter writer = EasyExcel.write(response.getOutputStream())
                     .autoCloseStream(Boolean.FALSE)
                     .withTemplate(tpl).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            SalaryDTO data = salaryMapper.findByEmployee(empId);
            writer.fill(data, sheet);
        }
    } catch (Exception e) {
        // 失败时 reset + 改写 JSON
        response.reset();
        response.setContentType("application/json");
        response.setCharacterEncoding("utf-8");
        Map<String, String> result = new HashMap<>();
        result.put("status", "failure");
        result.put("message", "下载失败: " + e.getMessage());
        try {
            response.getWriter().println(new ObjectMapper().writeValueAsString(result));
        } catch (IOException ignored) {}
    }
}
```

> **官方提示**："失败返回 JSON 增强版"需要 `autoCloseStream(Boolean.FALSE)`，否则在 catch 块中无法再写 response。

## 案例 8：嵌套列表（多级填充）

EasyExcel 不直接支持嵌套列表（如订单下的多个商品），需要拆解为多列表：

```
模板设计：
{order.id}  {order.customer}
{product.id} {product.name}  ← 商品列表（与订单列表平铺）
```

```java
// 1. 把嵌套结构摊平为多 list
List<OrderDTO> orders = ...;
List<ProductDTO> allProducts = orders.stream()
    .flatMap(o -> o.getProducts().stream())
    .collect(Collectors.toList());

// 2. 多个 list 填充
writer.fill(orders, sheet);     // 订单列表
writer.fill(allProducts, sheet); // 商品列表
```

> 注意：这种平铺需要模板里两个 list 的位置上下相邻。

## 案例 9：模板里含图章/图片

图片是 Excel 模板原生资源，填充不会改变图片位置/大小。

```java
// 模板里预置公司图章
// 填充时只填文字变量，图章保持原位
try (ExcelWriter writer = EasyExcel.write(outputPath)
        .withTemplate("templates/contract_with_seal.xlsx").build()) {
    WriteSheet sheet = EasyExcel.writerSheet().build();
    Map<String, Object> data = new HashMap<>();
    data.put("contractNo", "HT-2024-001");
    data.put("partyA", "甲方公司");
    writer.fill(data, sheet);
}
```

## 案例 10：模板放在 OSS / 远程

```java
public void exportWithRemoteTemplate(String tplUrl, String outputPath) {
    try (InputStream tplStream = new URL(tplUrl).openStream();
         ExcelWriter writer = EasyExcel.write(outputPath)
                 .withTemplate(tplStream).build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        writer.fill(data, sheet);
    }
}
```

## 性能对比

| 方案 | 数据量 | 内存占用 | 速度 |
|------|--------|---------|------|
| `doFill(list)` 一次 | < 1 万 | 中（list 全量） | 快 |
| `excelWriter.fill(list, sheet)` 分次 | 1~10 万 | 低（文件缓存） | 中 |
| `complexFillWithTable` + write 合计 | 10 万+ | 低 | 快 |
| `forceNewRow=true` | 1~5 万 | **高**（全量驻内存） | 快 |

> 官方建议：10 万行+ 数据优先用 `complexFillWithTable` 模式。
