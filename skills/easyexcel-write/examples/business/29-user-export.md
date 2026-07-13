# 业务案例：用户列表导出

```java
@Getter
@Setter
@EqualsAndHashCode
@HeadStyle(fillPatternType = FillPatternType.SOLID_FOREGROUND, fillForegroundColor = 13)
@HeadFontStyle(fontHeightInPoints = 12, bold = true, color = 9)
public class UserExportVO {
    @ExcelProperty("用户ID")
    @ColumnWidth(10)
    private Long id;

    @ExcelProperty("用户名")
    @ColumnWidth(20)
    private String username;

    @ExcelProperty("邮箱")
    @ColumnWidth(30)
    private String email;

    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    @ExcelProperty("注册时间")
    @ColumnWidth(20)
    private LocalDateTime registerTime;
}

public void exportUsers(List<User> users, OutputStream out) {
    List<UserExportVO> data = users.stream().map(this::toVO).collect(Collectors.toList());
    EasyExcel.write(out, UserExportVO.class).sheet("用户列表").doWrite(data);
}
```
