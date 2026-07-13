# 故障排查指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/write
> 综合官方文档 + 社区 Issues

## 1. 导出文件打不开

### 症状
生成的 .xlsx 双击报错"文件格式或扩展名无效"。

### 排查步骤
1. ExcelWriter 是否关闭（用 try-with-resources）
2. 写出过程被中断？
3. 写出文件路径可写？
4. 写出 OutputStream 是否已被关闭？

## 2. 表头不显示

### 症状
打开文件只有数据，没有表头。

### 排查步骤
1. DTO 字段是否标注 `@ExcelProperty("标题")`
2. `.needHead(false)` 是否误设？
3. WriteTable 是否 `needHead(false)`

## 3. 样式不生效

### 症状
注册了样式但颜色/字体没变化。

### 排查步骤
1. `registerWriteHandler(...)` 是否调用
2. 样式对象是否在循环中 new（应该静态缓存）
3. 颜色索引值是否正确
4. 字体名是否支持

## 4. 图片不显示

### 症状
DTO 有 File/byte[] 字段但导出后没图片。

### 排查步骤
1. 字段类型是 `File` / `InputStream` / `byte[]` / `URL` 之一
2. `String` 字段需要 `converter = StringImageConverter.class`
3. 图片路径正确、文件可读
4. 大图片是否 OOM（> 100MB）

## 5. 批注丢失

### 症状
导出的 Excel 打开后没有批注。

### 排查步骤
1. 必须 `inMemory(true)`
2. 03 版批注支持有限
3. 自定义拦截器中 `inMemory` 检查

## 6. 公式不计算

### 症状
写入了 =SUM(A1:A10) 但打开后是 0 或 #NAME。

### 排查步骤
1. 公式用 `FormulaData` 写入
2. Excel 打开时会重算
3. 注意：依赖性公式可能不计算

## 7. 合并单元格错位

### 症状
合并范围不对，单元格错位。

### 排查步骤
1. 注解：`@ContentLoopMerge(eachRow=N)` 在字段上
2. 策略：`LoopMergeStrategy(2, 0)` 注册
3. 03 版不推荐合并

## 8. 中文乱码

### 症状
导出的 Excel 中文显示为 ? 或 乱码。

### 排查步骤
1. 文件名编码：`URLEncoder.encode("中文", "UTF-8")`
2. HTTP header：`response.setCharacterEncoding("utf-8")`
3. CSV 文件：`charset(StandardCharsets.UTF_8)`

## 9. 性能慢

### 症状
10 万行要 1 分钟。

### 排查步骤
1. 分页写入
2. OutputStream 写 Web（不写文件）
3. 静态缓存样式
4. 避免大图片

## 10. OOM

### 症状
`OutOfMemoryError`

### 排查步骤
1. 分页写入 + 清理 list
2. 避免 `inMemory(true)` 除非必要
3. 大图片上传 OSS

## 11. 异步导出任务丢失

### 症状
提交异步任务后无法查询进度。

### 排查步骤
1. 用 Redis/cache 存储进度
2. 任务 ID 持久化
3. 任务完成后清理
