# 故障排查指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/read
> 综合官方文档 + 社区 Issues

## 1. 字段值都是 null

### 症状
读取数据全为 null 或 0。

### 排查步骤
1. DTO 字段名 vs Excel 表头不一致
2. `@ExcelProperty("表头名")` 大小写不匹配
3. 用了 `index` 和 `value` 冲突
4. `headRowNumber` 错位

## 2. 监听器没被调用

### 症状
`.doRead()` 完但 listener.invoke 没触发。

### 排查步骤
1. 监听器是否 new（不是 Spring Bean）
2. 是否 `doRead()` 触发的（不是 build）
3. 监听器是否注册到 `excelReader.read(sheet)`

## 3. 监听器 @Autowired 失败

### 症状
NullPointerException on dao.

### 排查步骤
1. 监听器不能 `@Component` / `@Service`
2. 用构造方法注入

## 4. 重复 read 同一 sheet 报错

### 症状
`ExcelAnalysisException: sheet already read`

### 排查步骤
1. 一个 sheet 不能重复 read
2. 重新 build ExcelReader

## 5. 多 sheet 性能慢

### 症状
读取 5 sheet 的 03 版要 30 秒。

### 排查步骤
1. 逐个 read → 一次传多个
2. 用 `excelReader.read(s1, s2, s3)`

## 6. 公式读不到

### 症状
formulaValue 字段为 null。

### 排查步骤
1. 用 `CellData<T>` 类型
2. 依赖性公式可能不读得到

## 7. 批注/超链接读不到

### 症状
extra() 监听器没被调用。

### 排查步骤
1. 默认不读取
2. 必须 `.extraRead(CellExtraTypeEnum.X)`

## 8. onException 不触发

### 症状
行解析失败但 onException 没调用。

### 排查步骤
1. 监听器必须 implements ReadListener / extends AnalysisEventListener
2. override `onException`

## 9. 同步读取 OOM

### 症状
100 万行 `doReadSync` OOM。

### 排查步骤
1. 改用监听器
2. 分批入库

## 10. 转换异常位置

### 症状
想知道哪行哪列出错。

### 排查步骤
1. 在 `onException` 中取 `ExcelDataConvertException`
2. 用 `getRowIndex()` `getColumnIndex()` `getCellData()`

## 11. CSV 中文乱码

### 症状
CSV 中文是 ???。

### 排查步骤
1. `.charset(StandardCharsets.UTF_8)`
2. 检查文件本身编码

## 12. 文件结构错误

### 症状
`ExcelAnalysisException: File is not a valid zip file`

### 排查步骤
1. 文件不是 .xlsx/.xls
2. 文件损坏
3. 文件加密（需 password 参数）

## 13. 监听器状态污染

### 症状
并发读取时数据错乱。

### 排查步骤
1. 监听器不能共享
2. 每个请求 new 监听器

## 14. Web 上传读不到

### 症状
`MultipartFile.getInputStream()` 报错。

### 排查步骤
1. 检查 Spring multipart 配置
2. 文件大小 < 限制
3. try-with-resources 关闭流
