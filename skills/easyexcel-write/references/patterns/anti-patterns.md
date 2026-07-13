# EasyExcel 写入 反模式

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
> 综合官方提示 + 社区实践

## 反模式 1：一次性写 10 万行

```java
// ❌ 错误
EasyExcel.write(fileName, DemoData.class)
    .sheet("模板")
    .doWrite(hugeList);  // 5000 以内推荐
```

> **官方原文**："数据量建议 5000 以内"

```java
// ✅ 正确：分页多次写
try (ExcelWriter writer = EasyExcel.write(fileName, DemoData.class).build()) {
    WriteSheet sheet = EasyExcel.writerSheet().build();
    for (int page = 1; page <= 100; page++) {
        List<DemoData> pageData = queryPage(page, 2000);
        writer.write(pageData, sheet);
        pageData.clear();
    }
}
```

## 反模式 2：循环中 new style

```java
// ❌ 错误：每次循环 new style
for (int i = 0; i < 100; i++) {
    HorizontalCellStyleStrategy style = new HorizontalCellStyleStrategy(...);
    EasyExcel.write(...).registerWriteHandler(style)...
}
```

> **官方原文**："不要一直去创建style 记得缓存起来 最多创建6W个就挂了"

```java
// ✅ 正确：静态缓存
private static final HorizontalCellStyleStrategy STYLE = new HorizontalCellStyleStrategy(...);
```

## 反模式 3：Web 导出先写文件再读入 response

```java
// ❌ 错误：先写文件再读
EasyExcel.write("/tmp/orders.xlsx", data).sheet("订单").doWrite(data);
Files.copy(Paths.get("/tmp/orders.xlsx"), response.getOutputStream());
```

```java
// ✅ 正确：直接写 OutputStream
EasyExcel.write(response.getOutputStream(), data).sheet("订单").doWrite(data);
```

## 反模式 4：批注没设 inMemory(true)

```java
// ❌ 错误
EasyExcel.write(fileName, data).sheet("订单").doWrite(data);  // 批注丢失
```

```java
// ✅ 正确
EasyExcel.write(fileName, data)
    .inMemory(true)
    .sheet("订单").doWrite(data);
```

> **官方提示**："inMemory 要设置为true，才能支持批注"

## 反模式 5：大图片全存内存

```java
// ❌ 错误：1000 张大图
List<ImageDemoData> rows = ...;  // 1000 张 1MB 图
EasyExcel.write(fileName, ImageDemoData.class).sheet().doWrite(rows);  // OOM
```

> **官方原文**："图片都会放到内存 暂时没有很好的解法，大量图片的情况下建议…将图片上传到oss"

## 反模式 6：失败回 JSON 仍设 autoCloseStream(true)

```java
// ❌ 错误：catch 块无法写 response
try {
    EasyExcel.write(response.getOutputStream(), data)
        .autoCloseStream(true)  // 默认 true
        .sheet("订单").doWrite(data);
} catch (Exception e) {
    response.getWriter().println("error");  // 流已关
}
```

```java
// ✅ 正确
EasyExcel.write(response.getOutputStream(), data)
    .autoCloseStream(false)
    .sheet("订单").doWrite(data);
```

## 反模式 7：index 和 name 同时用

```java
// ❌ 错误
@ExcelProperty(value = "姓名", index = 0)
private String name;  // index 和 name 同时用
```

> **官方原文**："不建议 index 和 name 同时用，要么只用index，要么只用name匹配"

## 反模式 8：03 版写大文件

```java
// ❌ 错误
EasyExcel.write(fileName, DemoData.class)
    .excelType(ExcelTypeEnum.XLS)
    .sheet("订单").doWrite(hugeList);  // 03 版上限 65536 行
```

## 反模式 9：没关闭 ExcelWriter

```java
// ❌ 错误
ExcelWriter writer = EasyExcel.write(fileName, DemoData.class).build();
writer.write(data, sheet);
// 未关闭 → 文件损坏
```

```java
// ✅ 正确
try (ExcelWriter writer = EasyExcel.write(fileName, DemoData.class).build()) {
    writer.write(data, sheet);
}
```

## 反模式 10：dynamic head 重复执行

```java
// ❌ 错误：每次调用都 new
private List<List<String>> head() {
    return Arrays.asList(...);
}
```

> dynamic head 应当是**静态/可缓存**的。
