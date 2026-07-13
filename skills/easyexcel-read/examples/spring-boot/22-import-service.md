# Spring Boot Service

```java
@Service
public class UserService {
    @Autowired private UserDAO userDAO;

    public ImportResult<UserDTO> importUsers(MultipartFile file) {
        TolerantListener listener = new TolerantListener();
        try (InputStream in = file.getInputStream()) {
            EasyExcel.read(in, UserDTO.class, listener).sheet().doRead();
        } catch (IOException e) {
            throw new BizException("FILE_READ_ERROR", e.getMessage());
        }

        ImportResult result = new ImportResult();
        result.setSuccessCount(listener.getSuccessData().size());
        result.setErrorCount(listener.getErrors().size());
        return result;
    }
}
```
