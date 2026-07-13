# EasyExcel 读取 常见问题 FAQ

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 来源：https://github.com/alibaba/easyexcel/issues

## Q1：监听器怎么注入 Spring Bean？

**A**：
```java
// 通过构造方法
public class MyListener {
    private final UserDAO userDAO;
    public MyListener(UserDAO userDAO) {
        this.userDAO = userDAO;
    }
}
```

## Q2：批注/超链接/合并读不到？

**A**：默认不读取，需显式调用：
```java
.extraRead(CellExtraTypeEnum.COMMENT)
.extraRead(CellExtraTypeEnum.HYPERLINK)
.extraRead(CellExtraTypeEnum.MERGE)
```

## Q3：读取公式为空？

**A**：用 `CellData<T>` 类型。依赖性公式可能读不到。

## Q4：onException 抛出还是不抛出？

**A**：
- 不抛出 → 继续读下一行
- 抛出 → 停止读

## Q5：03 版多 sheet 性能慢？

**A**：把多个 sheet 一次性传入 `excelReader.read(s1, s2, s3)`，避免逐个 read。

## Q6：怎么验证表头？

**A**：重写 `invokeHead` 监听器：
```java
@Override
public void invokeHead(Map<Integer, ReadCellData<?>> headMap, AnalysisContext context) {
    // 验证表头
}
```

## Q7：动态列 Excel 怎么读？

**A**：用 `ReadListener<Map<Integer, String>>` 不创建对象。

## Q8：headRowNumber 不指定会怎样？

**A**：
- 传入 class → 按 `@ExcelProperty#value()` 表头数量
- 不传入 class → 默认 1
- 显式指定 → 以指定值为准

## Q9：读取的日期是数字？

**A**：用 `CellData<Date>` 包装，excel 存储的是 number。

## Q10：多线程并发读取？

**A**：每个线程独立 listener + ExcelReader。监听器不能共享。

## Q11：doReadSync 性能？

**A**：同步读取全量入内存。100 万行 → OOM。改用监听器。

## Q12：读取 CSV 文件？

**A**：
```java
EasyExcel.read(fileName, DemoData.class, listener)
    .excelType(ExcelTypeEnum.CSV)
    .charset(StandardCharsets.UTF_8)
    .sheet().doRead();
```

## Q13：监听器内能调用 Spring 吗？

**A**：不能直接 @Autowired，但可通过构造方法注入。

## Q14：PageReadListener 默认多少行？

**A**：默认 100 行 / 批。可在构造函数自定义。

## Q15：多 sheet 监听器能不同吗？

**A**：可以，每个 sheet 可以用不同 listener。
