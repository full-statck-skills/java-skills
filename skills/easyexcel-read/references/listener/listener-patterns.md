# EasyExcel 4 种监听器模式详解

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read

## 监听器对比

| 监听器 | 复杂度 | 灵活度 | 适用 |
|--------|-------|-------|------|
| `PageReadListener<T>` | ★☆☆ | ★★☆ | 简单分批处理 |
| `ReadListener<T>` 匿名 | ★★☆ | ★★★ | 一次性 |
| `AnalysisEventListener<T>` | ★★☆ | ★★★ | 需要监听 head |
| `ReadListener<T>` 自定义类 | ★★★ | ★★★★★ | 完整业务（推荐） |

## 模式 1：PageReadListener（since 3.0.0-beta1，最简洁）

```java
import com.alibaba.excel.read.listener.PageReadListener;

EasyExcel.read(fileName, DemoData.class, new PageReadListener<DemoData>(dataList -> {
    // 每 100 条回调一次
    for (DemoData data : dataList) {
        log.info("读取到数据: {}", JSON.toJSONString(data));
    }
})).sheet().doRead();

// 自定义批大小
new PageReadListener<DemoData>(500, dataList -> {
    // 每 500 条回调
});
```

> **官方原文**："这里默认每次会读取100条数据 然后返回过来 直接调用使用数据就行"

## 模式 2：匿名 ReadListener

```java
EasyExcel.read(fileName, DemoData.class, new ReadListener<DemoData>() {
    private static final int BATCH_COUNT = 100;
    private List<DemoData> cachedDataList =
        ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        cachedDataList.add(data);
        if (cachedDataList.size() >= BATCH_COUNT) {
            saveData();
            cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) { saveData(); }
}).sheet().doRead();
```

## 模式 3：自定义 ReadListener（标准模板，官方推荐）

```java
@Slf4j
public class DemoDataListener implements ReadListener<DemoData> {
    private static final int BATCH_COUNT = 100;
    private List<DemoData> cachedDataList =
        ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
    private DemoDAO demoDAO;

    public DemoDataListener() {
        demoDAO = new DemoDAO();
    }

    public DemoDataListener(DemoDAO demoDAO) {
        this.demoDAO = demoDAO;
    }

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        cachedDataList.add(data);
        if (cachedDataList.size() >= BATCH_COUNT) {
            saveData();
            cachedDataList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
        saveData();
    }
}
```

## 模式 4：extends AnalysisEventListener（可重写 head/extra）

```java
@Slf4j
public class DemoHeadDataListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        log.info("解析到一条头数据:{}", JSON.toJSONString(headMap));
    }
    @Override public void invoke(DemoData data, AnalysisContext context) {}
    @Override public void doAfterAllAnalysed(AnalysisContext context) {}
}
```

## 关键原则

> **官方原文**："DemoDataListener 不能被spring管理，要每次读取excel都要new，然后里面用到spring可以构造方法传进去"

### 监听器为什么不能被 Spring 管理？
1. 监听器内部有状态（cachedDataList 缓存列表）
2. 复用会导致状态污染
3. Spring 默认单例，多线程读取会冲突

### 正确做法
```java
@Service
public class ImportService {
    @Autowired private UserDAO userDAO;

    public void importUsers(MultipartFile file) {
        DemoDataListener listener = new DemoDataListener(userDAO);
        EasyExcel.read(file.getInputStream(), UserDTO.class, listener)
            .sheet().doRead();
    }
}
```

## 监听器进阶：完整回调

```java
@Slf4j
public class FullListener extends AnalysisEventListener<DemoData> {
    @Override
    public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
        log.info("表头: {}", headMap);
    }

    @Override
    public void invoke(DemoData data, AnalysisContext context) {
        log.info("第 {} 行: {}", context.getCurrentRowNum(), data);
    }

    @Override
    public void extra(CellExtra extra, AnalysisContext context) {
        log.info("额外信息: {}", extra);
    }

    @Override
    public void onException(Exception exception, AnalysisContext context) {
        if (exception instanceof ExcelDataConvertException) {
            ExcelDataConvertException ex = (ExcelDataConvertException) exception;
            log.error("第{}行 第{}列 解析异常: 数据={}",
                ex.getRowIndex(), ex.getColumnIndex(), ex.getCellData());
        }
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {}

    @Override
    public boolean hasNext(AnalysisContext context) {
        return true;
    }
}
```

## 选择建议

| 场景 | 推荐 |
|------|------|
| 简单分批入库 | `PageReadListener` |
| 需要重写 head/extra | `AnalysisEventListener` |
| 复杂业务 + Spring | 自定义 `ReadListener` + 构造方法注入 |
| 一次性脚本 | 匿名 `ReadListener` |
