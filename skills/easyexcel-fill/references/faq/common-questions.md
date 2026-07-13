# EasyExcel 填充 常见问题 FAQ

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 来源：https://github.com/alibaba/easyexcel/issues

## Q1：模板变量没被替换？

**A**：检查 5 件事：
1. 模板占位符是 `{name}` 不是 `name`
2. Java Map 的 key / DTO 字段名**严格一致**（区分大小写）
3. 模板中含 `{` `}` 字符已用 `\{` `\}` 转义
4. 模板是 07 版（.xlsx）不是 03 版（.xls）
5. 模板文件路径正确

## Q2：列表没展开 / 只展开一行？

**A**：检查 3 件事：
1. 模板中 `{.}` 占位行**只画一行**
2. List 的元素不是 null
3. Map 填充时包含了所有 list key（可为 null）

## Q3：复杂填充 OOM？

**A**：
1. 改用 `complexFillWithTable` 模式（list 放最后一行 + write 追加）
2. 减少 `forceNewRow=true` 场景
3. 模板文件不能太大（>几十 MB 会 OOM）

## Q4：03 版 Excel 不支持？

**A**：03 版（.xls）不支持复杂填充/大数据量/横向多列，改用 07 版（.xlsx）。

## Q5：如何保留模板样式？

**A**：使用 fill 模式（不是 write）。write 模式会重新生成样式。

## Q6：模板中含图章被替换了？

**A**：图章是图片，fill 不会改变图片位置/大小。检查模板中图章是否被 `{}` 包围了。

## Q7：公式没生效？

**A**：EasyExcel 不会重算公式，模板中预置的公式由 Excel 在打开时计算。

## Q8：如何知道模板用 fill 还是 write？

**A**：
- 保留模板原样 + 填变量 → 用 **fill**
- 程序化生成 + 模板只作参考 → 用 **write**

## Q9：分次 fill 性能比一次 fill 慢？

**A**：是的，分次 fill 有文件缓存开销，但对**大 list** 更友好（避免 OOM）。

## Q10：监听器能用于 fill 吗？

**A**：不能。fill 是模板替换，没有监听器机制。

## Q11：如何用现有 Excel 修改后重新填充？

**A**：把原文件当作模板 → `EasyExcel.write(output).withTemplate(input).sheet().doFill(data)`

## Q12：spring bean 能在 fill 中自动注入吗？

**A**：可以，通过 `EasyExcel.write().withTemplate(inputStream)` + 业务 service 注入即可。fill 入口本身就是写操作，不是监听器，所以可以注入。
