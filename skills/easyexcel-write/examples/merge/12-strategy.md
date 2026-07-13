# 合并单元格 - 策略

```java
@Test
public void mergeStrategyWrite() {
    LoopMergeStrategy loopMergeStrategy = new LoopMergeStrategy(2, 0);
    EasyExcel.write(fileName, DemoData.class)
        .registerWriteHandler(loopMergeStrategy)
        .sheet("模板")
        .doWrite(data());
}
```
