# 验证流程

```java
// 1. 验证模板存在
ClassPathResource resource = new ClassPathResource("/templates/salary.xlsx");
if (!resource.exists()) {
    throw new BizException("TEMPLATE_NOT_FOUND");
}

// 2. 验证输出目录可写
File outputFile = new File(outputPath);
File parentDir = outputFile.getParentFile();
if (!parentDir.exists() && !parentDir.mkdirs()) {
    throw new BizException("OUTPUT_DIR_NOT_WRITABLE");
}

// 3. dry-run 测试
SalaryDTO test = new SalaryDTO();
test.setName("测试");
excelFillService.fill("/templates/salary.xlsx", test,
    new FileOutputStream("/tmp/dryrun.xlsx"));
// 打开 /tmp/dryrun.xlsx 人工验证
```
