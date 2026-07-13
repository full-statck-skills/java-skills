# 失败回 JSON 模式

```java
@GetMapping("/api/salary/{empId}/safe")
public void downloadSalarySafe(@PathVariable String empId,
                               HttpServletResponse response) {
    try {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("工资条", "UTF-8")
            .replaceAll("\\+", "%20");
        response.setHeader("Content-disposition",
            "attachment;filename*=utf-8''" + fileName + ".xlsx");

        try (InputStream tpl = getClass()
                .getResourceAsStream("/templates/salary.xlsx");
             // autoCloseStream=false 失败时还要 reset 输出 JSON
             ExcelWriter writer = EasyExcel.write(response.getOutputStream())
                     .autoCloseStream(Boolean.FALSE)
                     .withTemplate(tpl).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            SalaryDTO data = salaryService.findByEmployee(empId);
            writer.fill(data, sheet);
        }
    } catch (Exception e) {
        response.reset();
        response.setContentType("application/json");
        response.setCharacterEncoding("utf-8");
        Map<String, String> result = new HashMap<>();
        result.put("status", "failure");
        result.put("message", "下载失败: " + e.getMessage());
        try {
            response.getWriter().println(
                new ObjectMapper().writeValueAsString(result));
        } catch (IOException ignored) {}
    }
}
```
