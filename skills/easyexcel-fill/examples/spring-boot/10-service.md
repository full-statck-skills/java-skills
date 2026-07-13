# Spring Boot Service 通用填充入口

```java
@Service
public class ExcelFillService {

    public void fillSalary(String empId, OutputStream out) throws IOException {
        try (InputStream templateIn = getClass()
                .getResourceAsStream("/templates/salary.xlsx");
             ExcelWriter writer = EasyExcel.write(out)
                     .withTemplate(templateIn).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            SalaryDTO data = salaryMapper.findByEmployee(empId);
            writer.fill(data, sheet);
        }
    }

    public void fillContract(Long contractId, OutputStream out) throws IOException {
        try (InputStream templateIn = getClass()
                .getResourceAsStream("/templates/contract.xlsx");
             ExcelWriter writer = EasyExcel.write(out)
                     .withTemplate(templateIn).build()) {
            WriteSheet sheet = EasyExcel.writerSheet().build();
            ContractDTO contract = contractService.findWithItems(contractId);

            Map<String, Object> header = new HashMap<>();
            header.put("contractNo", contract.getContractNo());
            header.put("partyA", contract.getPartyA());
            writer.fill(header, sheet);
            writer.fill(contract.getItems(), sheet);
        }
    }
}
```
