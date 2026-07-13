# 业务案例：工资条批量打包

```java
public byte[] batchExportSalary(List<String> employeeIds) throws IOException {
    ByteArrayOutputStream zipBaos = new ByteArrayOutputStream();
    try (ZipOutputStream zos = new ZipOutputStream(zipBaos)) {
        for (String empId : employeeIds) {
            SalaryDTO data = salaryMapper.findByEmployee(empId);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            try (InputStream tpl = getClass()
                    .getResourceAsStream("/templates/salary.xlsx");
                 ExcelWriter writer = EasyExcel.write(baos)
                         .withTemplate(tpl).build()) {
                WriteSheet sheet = EasyExcel.writerSheet().build();
                writer.fill(data, sheet);
            }

            ZipEntry entry = new ZipEntry("salary_" + empId + ".xlsx");
            zos.putNextEntry(entry);
            zos.write(baos.toByteArray());
            zos.closeEntry();
        }
    }
    return zipBaos.toByteArray();
}
```
