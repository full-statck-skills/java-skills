# EasyExcel 写入 真实业务案例

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
> 综合官方文档、GitHub 仓库示例、社区实践整理

## 案例 1：用户列表导出

```java
public void exportUsers(List<User> users, OutputStream out) {
    List<UserExportVO> data = users.stream().map(this::toVO).collect(Collectors.toList());
    EasyExcel.write(out, UserExportVO.class).sheet("用户列表").doWrite(data);
}
```

## 案例 2：财务报表（含红绿涨跌）

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
                        ? IndexedColors.RED.getIndex()
                        : IndexedColors.GREEN.getIndex());
                    style.setFillPatternType(FillPatternType.SOLID_FOREGROUND);
                }
            }
        })
        .sheet("持仓").doWrite(stocks);
}
```

## 案例 3：分月份多 Sheet 导出

```java
public void exportFinanceByMonth(List<FinanceRecord> all, String fileName) {
    try (ExcelWriter writer = EasyExcel.write(fileName, FinanceRecordVO.class).build()) {
        Map<String, List<FinanceRecordVO>> byMonth = all.stream()
            .collect(Collectors.groupingBy(r -> DateUtil.format(r.getTime(), "yyyy-MM")));
        AtomicInteger sheetNo = new AtomicInteger(0);
        byMonth.forEach((month, records) -> {
            WriteSheet sheet = EasyExcel.writerSheet(sheetNo.getAndIncrement(), month).build();
            writer.write(records, sheet);
        });
    }
}
```

## 案例 4：商品图 + 详情链接导出

```java
public void exportProductWithImages(List<Product> products, String fileName) throws Exception {
    List<ProductExportVO> rows = products.stream().map(p -> {
        ProductExportVO vo = new ProductExportVO();
        vo.setName(p.getName());
        vo.setImageBytes(HttpUtil.downloadBytes(p.getImageUrl()));

        WriteCellData<String> link = new WriteCellData<>("查看详情");
        HyperlinkData hd = new HyperlinkData();
        hd.setAddress("https://shop.example.com/product/" + p.getId());
        hd.setHyperlinkType(HyperlinkType.URL);
        link.setHyperlinkData(hd);
        vo.setDetailLink(link);
        return vo;
    }).collect(Collectors.toList());

    EasyExcel.write(fileName, ProductExportVO.class).sheet("商品").doWrite(rows);
}
```

## 案例 5：用户勾选列动态导出

```java
public void exportWithUserColumns(List<String> userSelected, String fileName, List<UserVO> users) {
    List<List<String>> head = userSelected.stream()
        .map(col -> Collections.singletonList(columnMapping.get(col)))
        .collect(Collectors.toList());

    EasyExcel.write(fileName)
        .head(head)
        .sheet("用户列表")
        .doWrite(users);
}
```

## 案例 6：审计日志（带批注）

```java
public void exportAuditLog(List<AuditLog> logs, OutputStream out) {
    EasyExcel.write(out, AuditLogVO.class)
        .inMemory(true)
        .registerWriteHandler(new CommentWriteHandler())
        .sheet("审计日志")
        .doWrite(logs);
}
```

## 案例 7：异步导出 100 万行

```java
@Async
public String asyncExport(QueryDTO query) {
    String taskId = "EXPORT_" + System.currentTimeMillis();
    String fileName = "/tmp/" + taskId + ".xlsx";

    try (ExcelWriter writer = EasyExcel.write(fileName, OrderExportVO.class).build()) {
        WriteSheet sheet = EasyExcel.writerSheet("订单列表").build();
        int pageNum = 1, pageSize = 2000;
        while (true) {
            List<OrderExportVO> data = orderMapper.pageQuery(query, pageNum, pageSize);
            if (data.isEmpty()) break;
            writer.write(data, sheet);
            data.clear();
            progressService.update(taskId, pageNum);
            pageNum++;
        }
    }
    return fileName;
}
```

## 案例 8：动态复杂表头（按权限显示列）

```java
public void exportWithPermission(List<String> visibleColumns, List<UserVO> users, OutputStream out) {
    List<List<String>> head = visibleColumns.stream()
        .map(col -> {
            List<String> h = new ArrayList<>();
            h.add("用户信息");
            h.add(columnMapping.get(col));
            return h;
        })
        .collect(Collectors.toList());

    EasyExcel.write(out)
        .head(head)
        .sheet("用户列表")
        .doWrite(users);
}
```

## 案例 9：导出 + 上传 OSS

```java
public String exportAndUpload(List<OrderExportVO> orders) throws Exception {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    EasyExcel.write(baos, OrderExportVO.class)
        .sheet("订单").doWrite(orders);

    String ossKey = "exports/orders_" + System.currentTimeMillis() + ".xlsx";
    ossClient.putObject("bucket", ossKey, new ByteArrayInputStream(baos.toByteArray()));
    return ossClient.generatePresignedUrl("bucket", ossKey, 3600).toString();
}
```

## 案例 10：ZIP 多文件批量导出

```java
public void exportMultiSheetAsZip(String zipPath, Map<String, Class<?>> sheetClassMap,
                                  Map<String, List<?>> dataMap) throws IOException {
    String tmpDir = System.getProperty("java.io.tmpdir") + UUID.randomUUID() + "/";
    new File(tmpDir).mkdirs();

    try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipPath))) {
        for (Map.Entry<String, List<?>> entry : dataMap.entrySet()) {
            String xlsx = tmpDir + entry.getKey() + ".xlsx";
            EasyExcel.write(xlsx, sheetClassMap.get(entry.getKey()))
                .sheet(entry.getKey())
                .doWrite(entry.getValue());

            ZipEntry zipEntry = new ZipEntry(entry.getKey() + ".xlsx");
            zos.putNextEntry(zipEntry);
            Files.copy(Paths.get(xlsx), zos);
            zos.closeEntry();
        }
    }
}
```

## 案例 11：失败回 JSON 的 Web 导出

```java
@GetMapping("/api/export/safe")
public void safeExport(HttpServletResponse response) {
    try {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("订单", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition",
            "attachment;filename*=utf-8''" + fileName + ".xlsx");

        try (ExcelWriter writer = EasyExcel.write(response.getOutputStream())
                .autoCloseStream(Boolean.FALSE)
                .head(OrderExportVO.class).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            writer.write(queryOrders(), sheet);
        }
    } catch (Exception e) {
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
