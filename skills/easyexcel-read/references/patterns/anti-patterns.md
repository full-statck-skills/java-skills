# EasyExcel 读取 反模式

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 综合官方提示 + 社区实践

## 反模式 1：监听器标 @Component / @Service

```java
// ❌ 错误：Spring 单例会污染状态
@Service
public class MyListener { }
```

> **官方原文**："DemoDataListener 不能被spring管理"

```java
// ✅ 正确：自定义 Bean，手动 new
public class MyListener {
    private final UserDAO userDAO;
    public MyListener(UserDAO userDAO) {
        this.userDAO = userDAO;
    }
}
```

## 反模式 2：监听器直接 @Autowired DAO

```java
// ❌ 错误
@Slf4j
@Service
public class MyListener {
    @Autowired
    private UserDAO userDAO;
}
```

```java
// ✅ 正确：通过构造方法注入
public class MyListener {
    private final UserDAO userDAO;
    public MyListener(UserDAO userDAO) {
        this.userDAO = userDAO;
    }
}
```

## 反模式 3：同一 ExcelReader 多次 read() 同一 sheet

```java
// ❌ 错误
try (ExcelReader reader = EasyExcel.read(fileName).build()) {
    reader.read(sheet1);
    reader.read(sheet1);  // 第二次读同一 sheet 报错
}
```

> **官方原文**："一个sheet不能读取多次，多次读取需要重新读取文件"

## 反模式 4：多 sheet 逐个 read()

```java
// ❌ 错误
for (ReadSheet sheet : sheets) {
    excelReader.read(sheet);  // 03 版性能浪费
}
```

```java
// ✅ 正确
excelReader.read(sheet1, sheet2, sheet3);
```

## 反模式 5：大文件用 doReadSync()

```java
// ❌ 错误
List<DemoData> all = EasyExcel.read(fileName).head(DemoData.class)
    .sheet().doReadSync();  // 100万行 → OOM
```

> **官方原文**："不推荐使用，如果数据量大会把数据放到内存里面"

## 反模式 6：onException 直接抛出

```java
// ❌ 错误
@Override
public void onException(Exception exception, AnalysisContext context) throws Exception {
    throw exception;  // 中断后续读取
}
```

```java
// ✅ 正确：收集错误继续读
@Override
public void onException(Exception exception, AnalysisContext context) {
    log.warn("跳过: {}", exception.getMessage());
}
```

## 反模式 7：全局 registerConverter 后字段都被影响

```java
// ❌ 错误：String 字段都被影响
.registerConverter(new MyStringConverter())
```

```java
// ✅ 正确：字段级
@ExcelProperty(converter = MyStringConverter.class)
private String name;
```

## 反模式 8：extraRead 不调用就以为能读到批注

```java
// ❌ 错误：批注/超链接/合并默认不读
EasyExcel.read(fileName, ...).sheet().doRead();
// 监听器 extra() 不会被调用
```

```java
// ✅ 正确
EasyExcel.read(fileName, ...)
    .extraRead(CellExtraTypeEnum.COMMENT)
    .extraRead(CellExtraTypeEnum.HYPERLINK)
    .extraRead(CellExtraTypeEnum.MERGE)
    .sheet().doRead();
```

## 反模式 9：headRowNumber 与表头实际行数不匹配

```java
// ❌ 错误：模板 2 行表头，但 headRowNumber=1
.headRowNumber(1)  // 错！
```

## 反模式 10：Web 上传 InputStream 未关闭

```java
// ❌ 错误
EasyExcel.read(file.getInputStream(), ...).sheet().doRead();
// 文件流没关
```

```java
// ✅ 正确
try (InputStream in = file.getInputStream()) {
    EasyExcel.read(in, ...).sheet().doRead();
}
```

## 反模式 11：03 版多 sheet 浪费性能

```java
// ❌ 错误
for (ReadSheet sheet : sheets) {
    reader.read(sheet);  // 03 版每次都重读
}
```

```java
// ✅ 正确：一次传多个 sheet
reader.read(sheet1, sheet2, sheet3);
```

## 反模式 12：同步读取用在大数据量

```java
// ❌ 错误
List<DemoData> all = EasyExcel.read(fileName).head(DemoData.class)
    .sheet().doReadSync();
```

> 改用监听器（流式）
