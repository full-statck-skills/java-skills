# 动态表头

```java
@Test
public void dynamicHeadWrite() {
    EasyExcel.write(fileName)
        .head(head())
        .sheet("模板")
        .doWrite(data());
}

private List<List<String>> head() {
    List<List<String>> list = new ArrayList<>();
    List<String> head0 = new ArrayList<>();
    head0.add("字符串" + System.currentTimeMillis());
    list.add(head0);
    return list;
}
```
