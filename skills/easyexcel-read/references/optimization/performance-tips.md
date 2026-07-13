# 性能优化完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 综合官方文档 + 社区实践

## 1. 模式选择决策

```
数据规模？
├── < 1000 行 + 一次性返回 → 同步模式：doReadSync()
├── < 1 万行 + 简单处理 → PageReadListener
├── > 1 万行 + 入库 → ReadListener + 批量入库（每 2000 行）
└── 不需要对象 + 动态列 → ReadListener<Map<Integer, String>>

需要额外信息？
├── 批注 → extraRead(CellExtraTypeEnum.COMMENT)
├── 超链接 → extraRead(CellExtraTypeEnum.HYPERLINK)
└── 合并单元格 → extraRead(CellExtraTypeEnum.MERGE)
```

## 2. 性能数据

> **官方原文**："16M内存23秒读取75M(46W行25列)的Excel（3.2.1+版本）"

## 3. 关键优化点

### 3.1 监听器 new 而不是 Spring
> **官方原文**："DemoDataListener 不能被spring管理，要每次读取excel都要new"

### 3.2 03 版多 sheet 一次性传入
> **官方原文**："必须把sheet1 sheet2 一起传进去，不然03版excel会读取多次浪费性能"

### 3.3 分批入库
```java
private static final int BATCH_COUNT = 2000;

@Override
public void invoke(DemoData data, AnalysisContext context) {
    cachedList.add(data);
    if (cachedList.size() >= BATCH_COUNT) {
        saveData();  // 批量入库
        cachedList = ListUtils.newArrayListWithExpectedSize(BATCH_COUNT);
    }
}
```

### 3.4 doReadSync 慎用
> **官方原文**："不推荐使用，如果数据量大会把数据放到内存里面"

### 3.5 缓存配置
- 默认 < 5M 用内存
- > 5M 用 EhCache
- 自定义 `readCacheSelector`

## 4. 性能对比

| 模式 | 数据量 | 内存 | 速度 |
|------|--------|------|------|
| `doReadSync()` | < 1000 | 中 | 快 |
| `PageReadListener` | < 1 万 | 中 | 快 |
| `ReadListener` + 批量 | 1~10 万 | 低 | 中 |
| `ReadListener` + 分批 | 10 万+ | 低 | 中 |

## 5. 优化建议

1. **首选 ReadListener + 批量入库** —— 避免 OOM
2. **不要 doReadSync** —— 除非小文件
3. **不要注册成 Spring Bean** —— 状态污染
4. **多 sheet 一次传** —— 03 版性能
5. **异常不要直接抛出** —— 收集错误继续读
6. **Web 上传流要关** —— 避免资源泄漏
7. **表头校验提前** —— 在 invokeHead 中检查
