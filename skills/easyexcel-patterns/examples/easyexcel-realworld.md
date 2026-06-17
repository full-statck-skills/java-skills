# EasyExcel 大文件导出示例

```java
// 监听器模式：100万数据不OOM
EasyExcel.read(file, DataDTO.class, new ReadListener<DataDTO>() {
    private List<DataDTO> batch = new ArrayList<>();
    public void invoke(DataDTO d, AnalysisContext c) {
        batch.add(d);
        if (batch.size() >= 5000) { save(batch); batch.clear(); }
    }
    public void doAfterAllAnalysed(AnalysisContext c) { save(batch); }
}).sheet().doRead();

// 写
EasyExcel.write("users.xlsx", UserDTO.class).sheet("用户").doWrite(list);
```

> 来源：[https://github.com/alibaba/easyexcel](https://github.com/alibaba/easyexcel)
