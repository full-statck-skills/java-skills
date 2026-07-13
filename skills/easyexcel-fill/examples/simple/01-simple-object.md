# 简单对象填充 - DTO

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

# 简单对象填充 - 对象方式

```java
@Test
public void simpleFillByObject() {
    String templateFileName = "templates/simple.xlsx";
    String fileName = "output/simpleFill_object_" + System.currentTimeMillis() + ".xlsx";

    FillData fillData = new FillData();
    fillData.setName("张三");
    fillData.setNumber(5.2);
    fillData.setDate(new Date());

    EasyExcel.write(fileName).withTemplate(templateFileName)
        .sheet().doFill(fillData);
}
```

# 简单对象填充 - Map 方式

```java
@Test
public void simpleFillByMap() {
    String templateFileName = "templates/simple.xlsx";
    String fileName = "output/simpleFill_map_" + System.currentTimeMillis() + ".xlsx";

    Map<String, Object> map = new HashMap<>();
    map.put("name", "张三");
    map.put("number", 5.2);
    map.put("date", new Date());

    EasyExcel.write(fileName).withTemplate(templateFileName)
        .sheet().doFill(map);
}
```
