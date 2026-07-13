# EasyExcel 填充 反模式

> 来源：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 综合官方提示 + 社区实践

## 反模式 1：list 后用 fill 追加内容

```java
// ❌ 错误
try (ExcelWriter writer = EasyExcel.write(fileName)
        .withTemplate(templateFileName).build()) {
    writer.fill(list, sheet);
    writer.fill(totalList, sheet);  // 错！合计行应用 write
}

// ✅ 正确
try (ExcelWriter writer = EasyExcel.write(fileName)
        .withTemplate(templateFileName).build()) {
    writer.fill(list, sheet);
    writer.write(totalList, sheet);  // 用 write
}
```

> **官方原文**："这里是write 别和fill 搞错了"

## 反模式 2：大数据用 forceNewRow=true

```java
// ❌ 错误：百万级数据 + forceNewRow
FillConfig cfg = FillConfig.builder().forceNewRow(true).build();
writer.fill(hugeList, cfg, sheet);  // OOM 风险
```

> **官方原文**："forceNewRow 如果设置了true,有个缺点 就是他会把所有的数据都放到内存了，所以慎用"

## 反模式 3：Map 填充 list 漏 key

```java
// ❌ 错误
Map<String, Object> map = new HashMap<>();
map.put("name", "张三");
// 漏掉其他 list 的 key
writer.fill(map, sheet);  // NPE
```

> **官方原文**："如果是用 map，必须包涵所有 list 的 key"

## 反模式 4：横向多列忘了 FillWrapper

```java
// ❌ 错误
excelWriter.fill(data1List, horizontalCfg, sheet);
excelWriter.fill(data2List, horizontalCfg, sheet);
// 两个 list 都会被当成 .，混在一起
```

> **官方原文**："多个 list 必须用 FillWrapper 包裹"

## 反模式 5：03 版做复杂填充

```java
// ❌ 错误
String fileName = "output.xls";  // 03 版
EasyExcel.write(fileName).withTemplate(tpl).sheet().doFill(list);
// 不支持复杂/大数据量
```

> **官方原文**："03版本 不支持大量数据的复杂填充"

## 反模式 6：模板中含 `{` `}` 未转义

```java
// ❌ 错误：模板中含 JSON 字面量
// 模板：{"id":{id}}  ← 第一个 { 被认为是变量
// 替换结果：错误
```

```java
// ✅ 正确
// 模板：\{"id":{id}\}  ← 第一个 { 转义
```

> **官方原文**："如果本来就有'{'、'}' 特殊字符 用'\\{'、'\\}' 代替"

## 反模式 7：模板中变量名错（大小写）

```java
// 模板：{UserName}
// DTO:  userName  ← 不匹配
```

> DTO 字段与模板变量必须**完全一致**（区分大小写）。

## 反模式 8：ExcelWriter 未关闭

```java
// ❌ 错误
ExcelWriter writer = EasyExcel.write(fileName).withTemplate(tpl).build();
writer.fill(data, sheet);
// 未关闭 → 文件损坏
```

> 必须用 try-with-resources 自动关闭（触发 finish()）。

## 反模式 9：withTemplate 模板文件过大

```java
// ❌ 错误：100 MB 模板
String templateFileName = "huge_template.xlsx";
EasyExcel.write(fileName).withTemplate(templateFileName).sheet().doFill(data);
// 模板全量驻内存 → OOM
```

> **官方原文**："withTemplate 的模板文件会全量存储在内存里面，所以尽量不要用于追加文件"
