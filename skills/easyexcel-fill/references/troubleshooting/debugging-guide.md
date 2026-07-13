# 故障排查指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 综合官方文档 + 社区 Issues

## 1. 模板变量没替换

### 症状
打开生成的 Excel，`{name}` 还在那里。

### 排查步骤
1. 检查模板变量语法：`{name}` `{number}` `{date}` `{.}`
2. 检查 Map key / DTO 字段名一致（区分大小写）
3. 模板中含 `{` `}` 字符？用 `\{` `\`}
4. 模板路径正确？
5. 模板是 07 版（.xlsx）？

### 修复示例
```java
// 模板：{name} {date}
// DTO 字段：name date ← 必须完全匹配
```

## 2. 列表不展开

### 症状
模板中 `{.}` 只显示一行。

### 排查步骤
1. 模板中 `{.}` 占位行**只画一行**（EasyExcel 自动展开）
2. List 是否非空
3. 模板路径正确？

### 修复示例
```java
// 模板
// ┌────┬────┐
// │ ID │ 名称│
// ├────┼────┤
// │{.id}│{.name}│  ← 只画一行，EasyExcel 会自动展开
// └────┴────┘

// 代码
List<DTO> list = ...;
writer.fill(list, sheet);  // 列表展开多行
```

## 3. OOM 异常

### 症状
`java.lang.OutOfMemoryError: Java heap space`

### 排查步骤
1. `forceNewRow=true` + 大数据？改用 `complexFillWithTable`
2. 模板文件太大（>几十 MB）？拆分模板
3. 分次 fill 但仍然 OOM？减小批次

### 修复
```java
// ✅ 改用 complexFillWithTable
// 1. 模板中删除 list 之后的合计行
// 2. list 放最后一行
// 3. 合计行用 write 追加
```

## 4. 复杂填充数据错位

### 症状
填充后，list 行错位，与合计行重叠。

### 排查步骤
1. 模板中 list 后有内容？用 `forceNewRow=true` 或 `complexFillWithTable`
2. 合计行用 fill？改用 write

## 5. 03 版不支持

### 症状
03 版（.xls）做复杂填充报错或结果异常。

### 排查步骤
1. 03 版不支持复杂/大数据量/横向
2. 改用 07 版（.xlsx）

## 6. 公式丢失

### 症状
模板中预置的公式 =SUM() 没了。

### 排查步骤
1. 公式在 fill 时保留，但**不会重算**
2. 打开 Excel 时由 Excel 自动计算

## 7. 图片消失

### 症状
模板中预置的图章/图片在生成的 Excel 中没有。

### 排查步骤
1. fill 不会改变图片位置/大小
2. 检查模板中图片位置是否在变量范围内
3. 用 write 模式重新生成 Excel 可能丢失图片

## 8. Spring Bean 注入问题

### 症状
fill 入口的 service 拿不到 Spring Bean。

### 排查步骤
1. fill 入口是写操作，可以正常注入 service
2. fill 内部用 try-with-resources 关闭

## 9. 性能慢

### 症状
填充 1 万行要 30 秒。

### 排查步骤
1. 是否在循环中创建 FillConfig / WriteSheet
2. 是否在循环中 new 模板流
3. 改用分次 fill（文件缓存）

## 10. 文件损坏

### 症状
生成的 Excel 打开报错。

### 排查步骤
1. ExcelWriter 未关闭（用 try-with-resources）
2. 模板文件本身损坏
3. 写入过程被中断
