# 性能优化：10万+ 数据分次填充

```java
public void exportLargeOrderList(String outputPath) {
    try (ExcelWriter writer = EasyExcel.write(outputPath)
            .withTemplate("templates/order_list.xlsx").build()) {
        WriteSheet sheet = EasyExcel.writerSheet().build();

        int pageNum = 1;
        int pageSize = 2000;
        while (true) {
            List<OrderDTO> page = orderMapper.findPage(pageNum, pageSize);
            if (page.isEmpty()) break;
            writer.fill(page, sheet);  // 文件缓存
            page.clear();
            pageNum++;
        }
    }
}
```
