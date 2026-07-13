---
name: easyexcel-fill
description: 基于 Alibaba EasyExcel（com.alibaba:easyexcel:4.0.3）的 Excel 模板填充技能。覆盖简单对象填充、列表填充（{.}+forceNewRow）、横向多列组合填充（FillWrapper+WriteDirectionEnum.HORIZONTAL）、复杂填充（含合计行/统计行/先 fill 后 write）、Spring Boot 集成、模板设计规范、转义字符、03版/07版差异、性能优化（分次 fill、文件缓存）。当用户需要把 Java 对象或 Map 数据按预制 .xlsx 模板（变量语法 {var}、{.}、{prefix.}）填充生成报表（工资条/合同/对账单/发票/财务报表/统计表/汇总表）时使用此技能，不适用于不基于模板的"程序生成 Excel"场景（改用 easyexcel-write）。
license: Apache-2.0
---

# EasyExcel 模板填充（Fill）

> 官方文档：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
> 官方示例：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/fill/FillTest.java
> 当前版本：`com.alibaba:easyexcel:4.0.3`（Apache-2.0，仓库已归档，仅做 Bug 修复）

本技能专注于 **"按预制模板填充"** 场景。当用户给出一份已经画好样式的 `.xlsx` 模板，要求把数据库/接口里的数据填进去（工资条、合同、发票、报表、统计单等），应当使用本技能。

## Capability Boundaries

### ✅ 强项
1. 简单对象填充（Map / 单个 DTO）
2. 列表填充（模板 `{.}` 语法，单向纵向）
3. 复杂填充（list 后还有内容 → `forceNewRow=true`）
4. 大数据量复杂填充（list 必须放最后一行，后续统计行用 `write` 追加）
5. 横向多列组合填充（`WriteDirectionEnum.HORIZONTAL` + `FillWrapper`）
6. 模板转义字符处理（`\{` `\}`）
7. Spring Boot 集成（模板文件可来自 resources/ 或 OSS）

### ⚠️ 限制
1. 仅支持 `.xlsx`（07 版），03 版（`.xls`）不支持复杂/大数据量填充
2. `forceNewRow=true` 会全量驻内存，数据量大时慎用
3. `withTemplate` 模板会全量加载到内存，模板文件过大（>几十 MB）会 OOM
4. Map 填充 list 时必须包含所有 list 的 key，否则报 NPE

### ❌ Out of Scope（不该用本技能的场景，请改用其它技能）
1. **不基于模板的程序化生成 Excel**（无预制模板）→ **不适用**本技能，使用 `easyexcel-write`
2. **读取 Excel 数据** → **不适用**本技能，使用 `easyexcel-read`
3. **CSV 文件处理** → **不适用**本技能，自行使用 commons-csv / OpenCSV
4. **Word/PPT** → **不适用**本技能，使用 Apache POI / Apache POI-XML

## Data Privacy

本技能不收集、存储或传输任何用户数据。所有代码示例仅用于本地开发参考。

## When to use this skill

- 用户说"按模板生成 Excel"、"填充 Excel 模板"、"导出工资条/合同/发票"
- 用户提供 `.xlsx` 模板文件，要求把数据写进变量占位符
- 报表存在固定格式，需要保留样式/合并单元格/函数/图表
- 业务上有"先 fill 列表，再追加合计行/统计行"的需求

## Quick Start

**典型调用方式（4 选 1，按文件大小递增）**：

```java
// 方案 A：最简单的对象填充（since 2.1.1）
String fileName = "output_simple.xlsx";
EasyExcel.write(fileName).withTemplate("templates/simple.xlsx")
    .sheet().doFill(fillData);

// 方案 B：列表填充（一次放入内存）
EasyExcel.write(fileName).withTemplate("templates/list.xlsx")
    .sheet().doFill(list);

// 方案 C：列表分次填充（文件缓存，省内存）
try (ExcelWriter excelWriter = EasyExcel.write(fileName)
        .withTemplate("templates/list.xlsx").build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet().build();
    excelWriter.fill(list, writeSheet);  // 多次 fill，自动文件缓存
    excelWriter.fill(list, writeSheet);
}

// 方案 D：先 fill 列表 + 后 write 追加合计行（推荐：复杂报表 + 大数据量）
try (ExcelWriter excelWriter = EasyExcel.write(fileName)
        .withTemplate("templates/complex.xlsx").build()) {
    WriteSheet writeSheet = EasyExcel.writerSheet().build();
    excelWriter.fill(list, writeSheet);          // 1. 填列表
    excelWriter.fill(headerMap, writeSheet);     // 2. 填头部变量
    excelWriter.write(totalListList, writeSheet);// 3. 手动追加合计行
}
```

## Workflow

Step 1. **确认场景** — 用户是否提供了 `.xlsx` 模板？模板里是否有 `{var}` `{.}` `{prefix.}` 占位符？
Step 2. **评估数据量** — < 1 万行：方案 A/B；> 1 万行：方案 C/D（list 必须放最后一行）
Step 3. **选择填充模式** — 单对象 / 列表 / 复杂 / 横向多列
Step 4. **构造数据** — Map / DTO / List；Map 填充 list 必须包含所有 key
Step 5. **执行填充** — try-with-resources 关闭 `ExcelWriter`
Step 6. **验证输出** — 打开生成的 `.xlsx` 检查占位符是否被替换、有无残留 `{.}` `{}`

## Critical: 模板语法速查

| 模板占位符 | 含义 | Java 数据结构 |
|------------|------|---------------|
| `{name}` `{number}` `{date}` | 单值占位符 | `Map.put("name", value)` 或 DTO 字段 |
| `{.}` | 列表占位符（默认纵向） | `List<DTO>` 整体作为 fill 第一个参数 |
| `{data1.}` `{data2.}` | 带前缀的列表（多列表区分） | `new FillWrapper("data1", list)` |
| `\{` `\}` | 转义：当模板中真有 `{` `}` 字符时 | —— |

> **官方原文**："{} 普通变量，{.} list 的变量。如果本来就有'{'、'}' 特殊字符 用'\\{'、'\\}' 代替。{.前缀可以区分不同的list。"

## Critical: 4 种填充场景完整示例

### 场景 1：简单对象填充

**DTO**：
```java
@Getter
@Setter
@EqualsAndHashCode
public class FillData {
    private String name;
    private double number;
    private Date date;
}
```

**模板**（`templates/simple.xlsx`）：单元格含 `{name}` `{number}` `{date}`

**代码**：
```java
@Test
public void simpleFill() {
    String templateFileName = "templates/simple.xlsx";
    String fileName = "output_simpleFill_" + System.currentTimeMillis() + ".xlsx";

    // 方案 1：根据对象填充
    FillData fillData = new FillData();
    fillData.setName("张三");
    fillData.setNumber(5.2);
    EasyExcel.write(fileName).withTemplate(templateFileName).sheet().doFill(fillData);

    // 方案 2：根据 Map 填充
    Map<String, Object> map = new HashMap<>();
    map.put("name", "张三");
    map.put("number", 5.2);
    EasyExcel.write(fileName).withTemplate(templateFileName).sheet().doFill(map);
}
```

### 场景 2：列表填充（模板 `{.}` 占位一行）

**模板**（`templates/list.xlsx`）：一行单元格含 `{.}` 表示 list 起点

**代码**：
```java
@Test
public void listFill() {
    String templateFileName = "templates/list.xlsx";
    String fileName = "output_listFill_" + System.currentTimeMillis() + ".xlsx";

    // 方案 1：一次性放入内存
    EasyExcel.write(fileName).withTemplate(templateFileName).sheet().doFill(data());

    // 方案 2：分次填充（文件缓存，省内存，推荐）
    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        excelWriter.fill(data(), writeSheet);
        excelWriter.fill(data(), writeSheet);
    }
}
```

> **官方提示**："分多次 填充 会使用文件缓存"

### 场景 3：复杂填充（list 后还有合计行/总计行）

**场景特征**：模板中 `{.}` 列表行下面还有非列表内容（如"总计：xxx"）。

```java
@Test
public void complexFill() {
    String templateFileName = "templates/complex.xlsx";
    String fileName = "output_complexFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        // ⚠️ 关键：forceNewRow=true 才能让 list 后面再追加内容
        FillConfig fillConfig = FillConfig.builder().forceNewRow(Boolean.TRUE).build();

        excelWriter.fill(data(), fillConfig, writeSheet);
        excelWriter.fill(data(), fillConfig, writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        map.put("total", 1000);
        excelWriter.fill(map, writeSheet);
    }
}
```

> **官方原文**："在 02 版上面 模板 list 不是最后一行 下面还有数据 需要设置 `forceNewRow=true` 但是有一个缺点 就是他会把所有的数据都放到内存了 慎用"
> **官方原文**："如果数据量大 list不是最后一行 参照下一个（complexFillWithTable）"

### 场景 4：数据量大的复杂填充（list 放最后一行 + write 追加）

**最佳实践模板设计**：删除模板中 list 之后的"合计行"占位行，让 list 占最后一行；后续"统计行"用 `write` 手动追加。

```java
@Test
public void complexFillWithTable() {
    String templateFileName = "templates/complexFillWithTable.xlsx";
    String fileName = "output_complexFillWithTable_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();

        // 1. 写入 list 数据
        excelWriter.fill(data(), writeSheet);
        excelWriter.fill(data(), writeSheet);

        // 2. 写入 list 之前的变量
        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        excelWriter.fill(map, writeSheet);

        // 3. list 后面手动 write 统计行
        List<List<String>> totalListList = new ArrayList<>();
        List<String> totalList = new ArrayList<>();
        totalListList.add(totalList);
        totalList.add(null);
        totalList.add(null);
        totalList.add(null);
        totalList.add("统计:1000");
        excelWriter.write(totalListList, writeSheet);
    }
}
```

> **官方原文**："这里是write 别和fill 搞错了"

### 场景 5：横向填充（多列横向并列）

```java
@Test
public void horizontalFill() {
    String templateFileName = "templates/horizontal.xlsx";
    String fileName = "output_horizontalFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        // 横向：列方向展开
        FillConfig fillConfig = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();
        excelWriter.fill(data(), fillConfig, writeSheet);
        excelWriter.fill(data(), fillConfig, writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", "2019年10月9日13:28:28");
        excelWriter.fill(map, writeSheet);
    }
}
```

### 场景 6：多列表组合填充（同时填多个 list）

**模板**：包含 `{data1.}` `{data2.}` `{data3.}` 三种带前缀的列表

```java
@Test
public void compositeFill() {
    String templateFileName = "templates/composite.xlsx";
    String fileName = "output_compositeFill_" + System.currentTimeMillis() + ".xlsx";

    try (ExcelWriter excelWriter = EasyExcel.write(fileName)
            .withTemplate(templateFileName).build()) {
        WriteSheet writeSheet = EasyExcel.writerSheet().build();
        FillConfig fillConfig = FillConfig.builder()
            .direction(WriteDirectionEnum.HORIZONTAL).build();

        // ⚠️ 关键：多个 list 必须用 FillWrapper 包裹，prefix 必须与模板占位符前缀一致
        excelWriter.fill(new FillWrapper("data1", data()), fillConfig, writeSheet);
        excelWriter.fill(new FillWrapper("data2", data()), writeSheet);  // data2 纵向
        excelWriter.fill(new FillWrapper("data3", data()), writeSheet);

        Map<String, Object> map = new HashMap<>();
        map.put("date", new Date());
        excelWriter.fill(map, writeSheet);
    }
}
```

> **官方原文**："多个 list 必须用 `FillWrapper` 包裹；`{前缀.}` 前缀可以区分不同的 list；不同 list 可以指定不同方向（HORIZONTAL/VERTICAL）"

## Critical: Spring Boot 集成

### 1) 模板放在 `resources/templates/`
```java
@Service
public class SalaryFillService {

    public void fillSalary(String employeeId, OutputStream out) {
        InputStream templateIn = getClass()
            .getResourceAsStream("/templates/salary.xlsx");
        SalaryDTO data = salaryMapper.findByEmployee(employeeId);

        // 模板以流方式加载，避免临时文件
        try (ExcelWriter writer = EasyExcel.write(out)
                .withTemplate(templateIn).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            writer.fill(data, sheet);
        }
    }
}
```

### 2) Controller 返回
```java
@GetMapping("/export/salary/{employeeId}")
public void exportSalary(@PathVariable String employeeId,
                         HttpServletResponse response) throws IOException {
    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setCharacterEncoding("utf-8");
    String fileName = URLEncoder.encode("工资条", "UTF-8").replaceAll("\\+", "%20");
    response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

    salaryFillService.fillSalary(employeeId, response.getOutputStream());
}
```

### 3) 复杂场景：工资条批量打包
```java
public void batchExportSalary(List<String> employeeIds, OutputStream zipOut) {
    try (ZipOutputStream zos = new ZipOutputStream(zipOut);
         ExcelWriter writer = EasyExcel.write(/* unused */).build()) {  // 实际逐个写入临时文件
        for (String id : employeeIds) {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            fillSalary(id, baos);
            ZipEntry entry = new ZipEntry("salary_" + id + ".xlsx");
            zos.putNextEntry(entry);
            zos.write(baos.toByteArray());
            zos.closeEntry();
        }
    }
}
```

## Critical: 业务模板设计规范

| 业务场景 | 推荐模板设计 | 关键代码 |
|---------|------------|---------|
| **工资条** | 单对象 `{name}` `{base}` `{bonus}` `{total}` | 简单填充 方案 1 |
| **员工合同** | 头部 `{company}` `{name}` `{id}` + 列表 `{items.}` | 简单 + 列表 |
| **对账单** | 头部 `{date}` `{account}` + 列表 `{details.}` + 底部"合计" | complexFillWithTable（先 fill 列表再 write 合计行） |
| **财务报表** | 横向多列 `{months.}` + 纵向 `{rows.}` | compositeFill（多个 FillWrapper） |
| **发票** | 单对象 + 函数 `=SUM()` | 简单填充（公式由模板预置） |
| **商品清单** | 列表 `{products.}` + 图片 | 列表 + 图片（图片需读为 byte[]） |
| **汇总表（按月）** | 头部 `{year}` + 列表 `{data1.}`（横向多列展开） | horizontalFill |

## Gotchas（常见错误）

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | Map 填充 list 漏掉某些 key | Map 填充时必须 put 所有 list 的 key（可 value=null） |
| 2 | 模板有 `{` `}` 字符未转义 | 用 `\{` `\}` 转义 |
| 3 | 复杂填充忘记 `forceNewRow=true` | list 下面还有内容时必须设置 |
| 4 | `forceNewRow=true` 用在百万级数据 | 改用 complexFillWithTable（list 放最后一行） |
| 5 | 03 版（`.xls`）做复杂填充 | 改用 07 版（`.xlsx`） |
| 6 | list 后追加合计行用 `fill` | 用 `write`（"这里是write 别和fill 搞错了"） |
| 7 | 横向多列忘了 `FillWrapper` | 多 list 必须用 `new FillWrapper("prefix", list)` |
| 8 | 横向多列方向忘了配 | 必须 `FillConfig.builder().direction(HORIZONTAL)` |
| 9 | 模板文件 `withTemplate(InputStream)` 用完未关 | 模板流是缓存的，try-with-resources 关闭 |
| 10 | 关闭 `ExcelWriter` 时漏掉 `finish()` | 用 try-with-resources 让 `ExcelWriter.close()` 触发 finish |
| 11 | 模板文件 > 几十 MB | 改用多个小模板分批填充 |
| 12 | 模板变量写错（大小写 / 漏 `{` `}`） | 模板变量名必须与 Map key / DTO 字段完全一致 |

## Key Classes / Methods

| 类型 | 名称 | 用途 |
|------|------|------|
| 入口 | `EasyExcel.write(path).withTemplate(template)` | 指定模板路径或流 |
| 入口 | `EasyExcel.write(OutputStream).withTemplate(stream)` | Web 输出流场景 |
| 核心 | `ExcelWriter` | 多次 fill 的容器，需 try-with-resources |
| 核心 | `WriteSheet` | 单个 sheet 配置 |
| 配置 | `FillConfig.builder().forceNewRow(true)` | 复杂填充（list 后还有内容） |
| 配置 | `FillConfig.builder().direction(HORIZONTAL)` | 横向填充 |
| 包装 | `FillWrapper("prefix", list)` | 多列表分组，前缀匹配模板 `{prefix.}` |
| 工具 | `EasyExcel.writerSheet().build()` | 创建默认 WriteSheet |
| 工具 | `EasyExcel.writerSheet(0, "sheet名").build()` | 指定 sheetNo 和名称 |

## References

- **官方文档**：https://easyexcel.opensource.alibaba.com/docs/current/quickstart/fill
- **官方示例**：https://github.com/alibaba/easyexcel/blob/master/easyexcel-test/src/test/java/com/alibaba/easyexcel/test/demo/fill/FillTest.java
- **项目主页**：https://easyexcel.opensource.alibaba.com/
- **GitHub**：https://github.com/alibaba/easyexcel
- **API 参考**：https://easyexcel.opensource.alibaba.com/docs/current/api/
- [references/api-reference.md](references/api-reference.md) — 完整 API 与注解索引
- [references/template-design.md](references/template-design.md) — 模板设计规范与真实业务模板
- [references/business-scenarios.md](references/business-scenarios.md) — 工资条/合同/对账单/发票等真实案例
- [examples/real-cases.md](examples/real-cases.md) — 6 种填充模式完整可复制代码
- [examples/spring-boot-integration.md](examples/spring-boot-integration.md) — Spring Boot 集成完整示例
