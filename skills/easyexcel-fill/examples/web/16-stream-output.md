# Web 直接写 OutputStream

```java
@GetMapping("/api/salary/{empId}")
public void downloadSalary(@PathVariable String empId,
                           HttpServletResponse response) throws IOException {
    SalaryDTO data = salaryService.findByEmployee(empId);

    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setCharacterEncoding("utf-8");
    String fileName = URLEncoder.encode("工资条", "UTF-8")
        .replaceAll("\\+", "%20");
    response.setHeader("Content-disposition",
        "attachment;filename*=utf-8''" + fileName + ".xlsx");

    try (InputStream tpl = getClass()
            .getResourceAsStream("/templates/salary.xlsx");
         ExcelWriter writer = EasyExcel.write(response.getOutputStream())
                 .withTemplate(tpl).build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();
        writer.fill(data, sheet);
    }
}
```
