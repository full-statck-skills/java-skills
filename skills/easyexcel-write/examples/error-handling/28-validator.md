# 验证流程

```java
// 1. 验证数据非空
if (data == null || data.isEmpty()) {
    throw new BizException("EMPTY_DATA");
}

// 2. dry-run 测试
List<DemoData> testData = Collections.singletonList(new DemoData());
String testFile = "/tmp/test_" + System.currentTimeMillis() + ".xlsx";
EasyExcel.write(testFile, DemoData.class)
    .sheet("test").doWrite(testData);
// 打开 testFile 人工验证

// 3. 检查文件大小
File file = new File(fileName);
if (file.length() > 100 * 1024 * 1024) {
    log.warn("导出文件过大: {}MB", file.length() / 1024 / 1024);
}
```
