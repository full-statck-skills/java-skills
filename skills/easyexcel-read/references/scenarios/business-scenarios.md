# EasyExcel 读取 真实业务案例

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 综合官方文档、GitHub 仓库示例、社区实践整理

## 案例 1：用户批量导入（Web + 监听器 + 容错）

```java
@PostMapping("/api/users/import")
public Result<ImportResult> importUsers(@RequestParam MultipartFile file) {
    return Result.ok(userService.importUsers(file));
}

public ImportResult<UserDTO> importUsers(MultipartFile file) {
    TolerantListener listener = new TolerantListener();
    try (InputStream in = file.getInputStream()) {
        EasyExcel.read(in, UserDTO.class, listener).sheet().doRead();
    } catch (IOException e) {
        throw new BizException("FILE_READ_ERROR", e.getMessage());
    }

    ImportResult result = new ImportResult();
    result.setSuccessCount(listener.getSuccessData().size());
    result.setErrorCount(listener.getErrors().size());
    result.setErrors(listener.getErrors());
    return result;
}
```

## 案例 2：订单导入（多 Sheet）

```java
public void importOrders(MultipartFile file) {
    try (ExcelReader excelReader = EasyExcel.read(file.getInputStream()).build()) {
        ReadSheet orderSheet = EasyExcel.readSheet(0)
            .head(OrderDTO.class)
            .registerReadListener(new OrderListener())
            .build();

        ReadSheet itemSheet = EasyExcel.readSheet(1)
            .head(OrderItemDTO.class)
            .registerReadListener(new OrderItemListener())
            .build();

        // 一次传多个 sheet（03版避免重复解析）
        excelReader.read(orderSheet, itemSheet);
    } catch (IOException e) {
        throw new BizException("FILE_READ_ERROR", e.getMessage());
    }
}
```

## 案例 3：对账文件解析（容错 + 错误报告导出）

```java
public ReconciliationResult parseReconciliation(MultipartFile file) {
    ReconciliationListener listener = new ReconciliationListener();
    EasyExcel.read(file.getInputStream(), ReconciliationItemDTO.class, listener)
        .sheet().doRead();

    ReconciliationResult result = new ReconciliationResult();
    result.setItems(listener.getItems());
    result.setErrorRows(listener.getErrors());
    return result;
}
```

## 案例 4：动态列读取（无 DTO）

```java
public List<Map<String, String>> readDynamicColumns(MultipartFile file) {
    List<Map<String, String>> result = new ArrayList<>();
    AtomicReference<List<String>> headers = new AtomicReference<>();

    try (InputStream in = file.getInputStream()) {
        EasyExcel.read(in, new ReadListener<Map<Integer, String>>() {
            @Override
            public void invokeHead(Map<Integer, String> headMap, AnalysisContext context) {
                headers.set(new ArrayList<>(headMap.values()));
            }

            @Override
            public void invoke(Map<Integer, String> data, AnalysisContext context) {
                Map<String, String> row = new LinkedHashMap<>();
                for (int i = 0; i < headers.get().size(); i++) {
                    row.put(headers.get().get(i), data.get(i));
                }
                result.add(row);
            }

            @Override
            public void doAfterAllAnalysed(AnalysisContext context) {}
        }).sheet().doRead();
    } catch (IOException e) {
        throw new BizException("FILE_READ_ERROR", e.getMessage());
    }
    return result;
}
```

## 案例 5：含批注/超链接的 Excel 解析

```java
public void parseExtraInfo(MultipartFile file) {
    EasyExcel.read(file.getInputStream(), DemoExtraData.class, new ReadListener<DemoExtraData>() {
        @Override
        public void invoke(DemoExtraData data, AnalysisContext context) {}

        @Override
        public void extra(CellExtra extra, AnalysisContext context) {
            switch (extra.getType()) {
                case COMMENT: /* 批注 */ break;
                case HYPERLINK: /* 超链接 */ break;
                case MERGE: /* 合并 */ break;
            }
        }

        @Override
        public void doAfterAllAnalysed(AnalysisContext context) {}
    })
    .extraRead(CellExtraTypeEnum.COMMENT)
    .extraRead(CellExtraTypeEnum.HYPERLINK)
    .extraRead(CellExtraTypeEnum.MERGE)
    .sheet().doRead();
}
```

## 案例 6：百万级导入（分批入库）

```java
public void importLargeExcel(String filePath) {
    EasyExcel.read(filePath, OrderDTO.class, new ReadListener<OrderDTO>() {
        private static final int BATCH_COUNT = 2000;
        private List<OrderDTO> cachedList = new ArrayList<>(BATCH_COUNT);

        @Override
        public void invoke(OrderDTO data, AnalysisContext context) {
            cachedList.add(data);
            if (cachedList.size() >= BATCH_COUNT) {
                orderDAO.batchInsert(cachedList);
                cachedList.clear();
            }
        }

        @Override
        public void doAfterAllAnalysed(AnalysisContext context) {
            if (!cachedList.isEmpty()) orderDAO.batchInsert(cachedList);
        }
    }).sheet().doRead();
}
```

## 案例 7：读取表头做校验

```java
@Slf4j
class HeaderValidateListener extends AnalysisEventListener<UserDTO> {
    private static final List<String> EXPECTED_HEADERS = Arrays.asList("用户名", "邮箱", "年龄");

    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        Map<Integer, String> stringMap =
            ConverterUtils.convertToStringMap(headMap, context);
        List<String> actualHeaders = new ArrayList<>(stringMap.values());
        if (!actualHeaders.equals(EXPECTED_HEADERS)) {
            throw new BizException("INVALID_HEADER",
                "期望: " + EXPECTED_HEADERS + ", 实际: " + actualHeaders);
        }
    }
}
```

## 案例 8：枚举转换器

```java
public class OrderStatusConverter implements Converter<OrderStatus> {
    @Override
    public Class<?> supportJavaTypeKey() { return OrderStatus.class; }
    @Override
    public CellDataTypeEnum supportExcelTypeKey() { return CellDataTypeEnum.STRING; }

    @Override
    public OrderStatus convertToJavaData(ReadConverterContext<?> context) {
        return OrderStatus.fromLabel(context.getReadCellData().getStringValue());
    }
}
```

## 案例 9：财务对账（容错 + 部分成功 + 错误导出）

```java
public ReconciliationReport importReconciliation(MultipartFile file) {
    ReconciliationListener listener = new ReconciliationListener();
    EasyExcel.read(file.getInputStream(), ReconciliationDTO.class, listener)
        .sheet().doRead();

    // 错误行单独导出
    if (!listener.getErrors().isEmpty()) {
        List<ReconciliationErrorVO> errorVOs = listener.getErrors().stream()
            .map(ReconciliationErrorVO::from)
            .collect(Collectors.toList());
        // 用 write 单独导出错误报告
        // EasyExcel.write(...).sheet("错误明细").doWrite(errorVOs);
    }

    return new ReconciliationReport(listener.getItems(), listener.getErrors());
}
```

## 案例 10：CSV 读取

```java
public List<DemoData> readCsv(String fileName) {
    return EasyExcel.read(fileName, DemoData.class, new DemoDataListener())
        .excelType(ExcelTypeEnum.CSV)
        .charset(StandardCharsets.UTF_8)
        .sheet()
        .doReadSync();
}
```

> **官方提示**：EasyExcel 通过 `excelType(ExcelTypeEnum.CSV)` 支持 CSV 文件。
