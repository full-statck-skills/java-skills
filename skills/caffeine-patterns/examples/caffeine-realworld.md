# Caffeine + Spring Cache 示例

```java
@Configuration
public class CacheConfig {
    @Bean public CacheManager cacheManager() {
        CaffeineCacheManager mgr = new CaffeineCacheManager();
        mgr.setCaffeine(Caffeine.newBuilder().expireAfterWrite(10, TimeUnit.MINUTES).maximumSize(10000));
        return mgr;
    }
}

@Service
public class UserService {
    @Cacheable(value = "users", key = "#id")
    public User getUser(Long id) { return userMapper.selectById(id); }
    @CacheEvict(value = "users", key = "#id")
    public void update(Long id, UserDTO dto) { userMapper.updateById(...); }
}
```

---

> 来源：[https://github.com/ben-manes/caffeine](https://github.com/ben-manes/caffeine)
