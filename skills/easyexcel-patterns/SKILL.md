---
name: easyexcel-patterns
description: |
  EasyExcel Excel读写技能。覆盖监听器模式(大批量读)vs同步模式(小批量)、写模式选择(模板填充/动态表头/自定义样式)、百万级数据导出内存优化、@ExcelProperty/@ExcelIgnore/@ContentStyle注解。
  当用户需要Java处理Excel导入导出、处理大文件时使用。避免LLM手写POI样板代码。
license: Apache-2.0
---

# EasyExcel Excel 处理

> 编码 EasyExcel 的使用规则。LLM 用 Apache POI 手写 50 行代码做简单导入导出，不知道 EasyExcel。

## Capability Boundaries

### ✅ Strong Suits
1. **读取** — 监听器模式(大文件/流式)vs 同步模式(小文件)
2. **写入** — 模板填充/动态表头/自定义样式/多次写入
3. **百万级优化** — 分批写入+flush策略

### ❌ Out of Scope
1. 复杂Word/PPT操作 → Apache POI(少量场景)
2. CSV文件 → commons-csv 或 OpenCSV

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 手写 POI Workbook/Sheet/Row/Cell 样板代码 | EasyExcel一行 read/write |
| 2 | 大文件一次性加载到内存 OOM | 监听器模式，每1000行处理一次 |
| 3 | 导出不关闭流 | try-with-resources 自动关闭 |
| 4 | 不知道模板填充 | `EasyExcel.write().withTemplate()` 一行 |

## 核心规则速查

```java
// ✅ 同步读(小文件<1000行)
List<UserDTO> list = EasyExcel.read(file).head(UserDTO.class).sheet().doReadSync();

// ✅ 监听器读(大文件)
EasyExcel.read(file, UserDTO.class, new ReadListener<UserDTO>() {
    private List<UserDTO> batch = new ArrayList<>();
    public void invoke(UserDTO dto, AnalysisContext ctx) {
        batch.add(dto);
        if (batch.size() >= 1000) { saveBatch(batch); batch.clear(); }
    }
    public void doAfterAllAnalysed(AnalysisContext ctx) { saveBatch(batch); }
}).sheet().doRead();

// ✅ 写
EasyExcel.write(file, UserDTO.class).sheet("用户列表").doWrite(list);

// ✅ 模板填充
EasyExcel.write(file).withTemplate("template.xlsx").sheet().doFill(data);

// ✅ 实体定义
@Data
public class UserDTO {
    @ExcelProperty(value = "用户名", index = 0)
    private String username;
    @ExcelProperty("年龄")
    @ContentStyle(dataFormat = 1)  // 整数格式
    private Integer age;
    @ExcelIgnore  // 不导出
    private String password;
    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
```

## Gotchas
1. **大文件(>10万行)必须用监听器模式** — 同步模式一次性加载 OOM
2. **监听器中不能自动注入 Spring Bean** — 手动 new 需要传参
3. **模板填充的 {} 占位符语法** — `{name}`或`{.name}`两种方式
4. **@ExcelProperty 的 index 从0开始** — 确保和Excel列对应
5. **EasyExcel 基于反射** — 字段名变更后Excel映射失效
6. **日期格式化需要 @DateTimeFormat** — 否则默认 yyyy-MM-dd HH:mm:ss

## Data Privacy
本技能不收集、存储或传输任何用户数据。
