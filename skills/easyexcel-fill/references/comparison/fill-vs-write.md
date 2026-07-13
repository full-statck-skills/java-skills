# fill vs write 对比

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill

## 模式对比

| 模式 | 入口 | 是否需要模板 | 数据来源 | 适合 |
|------|------|------------|---------|------|
| **简单写入** | `EasyExcel.write().sheet().doWrite()` | ❌ | List | 程序化生成 |
| **模板写入** | `EasyExcel.write().withTemplate().sheet().doWrite()` | ✅ | List | 模板当表头参考 |
| **模板填充** | `EasyExcel.write().withTemplate().sheet().doFill()` | ✅ | Map/DTO/List | 变量替换 |
| **读取** | `EasyExcel.read().sheet().doRead()` | —— | —— | 解析 Excel |

## fill 模式特点

1. **保留模板原样式**（合并、公式、图章）
2. 用 `{var}` `{var.}` 占位符
3. 适合报表、合同、发票等
4. 数据规模大时分次 fill

## write 模式特点

1. **完全程序化生成**
2. 用 `@ExcelProperty` 等注解定义表头
3. 适合订单、用户、库存等结构化数据
4. 数据规模大时多次 `excelWriter.write()`

## 如何选择

```
有预制模板 + 填变量 → fill
无模板 + 程序化生成 → write
有模板 + 表头参考 + 数据追加 → withTemplate + doWrite
```
