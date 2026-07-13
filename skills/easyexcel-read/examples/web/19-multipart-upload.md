# Web 上传读取

```java
@PostMapping("upload")
@ResponseBody
public String upload(MultipartFile file) throws IOException {
    EasyExcel.read(file.getInputStream(), UploadData.class,
                   new UploadDataListener(uploadDAO)).sheet().doRead();
    return "success";
}
```
