# Spring Boot Controller 简单下载

```java
@RestController
@RequestMapping("/excel")
public class ExcelFillController {

    @Autowired private ExcelFillService service;

    @GetMapping("/download/salary/{empId}")
    public void downloadSalary(@PathVariable String empId,
                               HttpServletResponse response) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("工资条", "UTF-8")
            .replaceAll("\\+", "%20");
        response.setHeader("Content-disposition",
            "attachment;filename*=utf-8''" + fileName + ".xlsx");

        service.fillSalary(empId, response.getOutputStream());
    }
}
```
