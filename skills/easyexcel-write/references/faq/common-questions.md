# EasyExcel 写入 常见问题 FAQ

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
> 来源：https://github.com/alibaba/easyexcel/issues

## Q1：导出的 Excel 打不开？

**A**：
1. 检查 ExcelWriter 是否关闭（用 try-with-resources）
2. 模板文件本身损坏
3. 写出过程被中断

## Q2：表头不显示？

**A**：
1. 检查 `@ExcelProperty("标题")` 注解
2. `.needHead(true)` 没设？
3. WriteTable 中 `needHead(false)` 会跳过表头

## Q3：日期显示为数字？

**A**：
1. 字段加 `@DateTimeFormat("yyyy-MM-dd")`
2. Excel 单元格格式设为"日期"

## Q4：数字显示为科学计数法？

**A**：
1. 字段加 `@NumberFormat("#.##")`
2. 全局 `useScientificFormat(false)`

## Q5：图片不显示？

**A**：
1. 字段类型是 `File` / `InputStream` / `byte[]` / `URL` 之一
2. 路径正确、文件存在
3. 用 `StringImageConverter` 配合 String 路径

## Q6：批注丢失？

**A**：
1. 必须 `inMemory(true)`
2. EasyExcel 对 03 版批注支持有限

## Q7：合并单元格不生效？

**A**：
1. 注解方式：`@ContentLoopMerge(eachRow=N)` 在字段上
2. 策略方式：注册 `LoopMergeStrategy`
3. 03 版不推荐合并

## Q8：动态列导出？

**A**：
```java
EasyExcel.write(fileName)
    .head(dynamicHead)  // List<List<String>>
    .sheet("模板")
    .doWrite(data);
```

## Q9：异步导出进度如何更新？

**A**：
```java
writer.write(data, sheet);
progressService.update(taskId, pageNum);
```

## Q10：导出的 CSV 中文乱码？

**A**：
```java
EasyExcel.write(fileName, DemoData.class)
    .excelType(ExcelTypeEnum.CSV)
    .charset(StandardCharsets.UTF_8)
    .sheet("模板").doWrite(data);
```

## Q11：图片不驻内存？

**A**：
官方提示："大量图片的情况下建议…将图片上传到oss…然后直接放链接"

## Q12：自定义样式不生效？

**A**：
1. `registerWriteHandler(...)` 注册
2. 样式对象不要在循环中 new
3. 检查样式对象缓存上限 6W

## Q13：导出后 Excel 提示修复？

**A**：可能是流没正确关闭。检查 try-with-resources。

## Q14：百万级数据如何优化？

**A**：
1. 分页 `excelWriter.write()`，每页 2000~5000
2. 用 OutputStream 写 Web，不要先写文件
3. 避免大图片、超大字符串
