# 性能优化完整指南

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill

## 1. 4 种数据规模的最优方案

| 数据规模 | 推荐方案 | 内存 | 模板要求 |
|---------|---------|------|---------|
| < 1 万行 | `doFill(list)` 一次 | 中 | 无 |
| 1 万 ~ 10 万行 | `excelWriter.fill(list, sheet)` 分次 | 低 | list 必须最后一行 |
| 10 万+ 行 | 先 fill 列表 + 后 write 合计行 | 低 | list 必须是最后一行 |
| 复杂 list + 后续内容 | `forceNewRow=true` | **高** | list 后有内容（慎用） |

## 2. 性能对比

| 方案 | 内存占用 | 速度 | 适用 |
|------|---------|------|------|
| `doFill(list)` 一次 | 中 | 快 | < 1 万行 |
| `excelWriter.fill(list, sheet)` 分次 | **低** | 中 | 1~10 万行 |
| `complexFillWithTable` + write 合计 | 低 | 快 | 10 万+ 行 |
| `forceNewRow=true` | **高** | 快 | 1~5 万行（特殊场景） |

## 3. 性能陷阱

> **官方原文**："forceNewRow 如果设置了true,有个缺点 就是他会把所有的数据都放到内存了，所以慎用"

> **官方原文**："withTemplate 的模板文件会全量存储在内存里面，所以尽量不要用于追加文件，如果文件模板文件过大会OOM"

> **官方原文**："03版本 不支持大量数据的复杂填充"

## 4. 实测数据

> **官方原文**："16M内存23秒读取75M(46W行25列)的Excel（3.2.1+版本）"

## 5. 优化建议

1. **首选分次填充**（文件缓存）—— `excelWriter.fill(list, sheet)` 多次
2. **大数据 list 放模板最后一行** —— 避免 forceNewRow
3. **追加行用 write** —— 不要用 fill
4. **避免在循环中创建 FillConfig** —— 静态缓存
5. **try-with-resources 关闭 ExcelWriter** —— 避免文件句柄泄漏
