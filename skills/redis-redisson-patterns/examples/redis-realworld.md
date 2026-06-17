# Redis + Redisson 实战示例

## 示例 1：缓存穿透防护（空值缓存）

```java
@Service
public class UserCacheService {
    @Autowired StringRedisTemplate redis;
    private static final String PREFIX = "cache:user:";
    private static final long NULL_TTL = 5;  // 空值5分钟
    private static final long TTL = 30;      // 正常30分钟

    public User getById(Long id) {
        String key = PREFIX + id;
        String cached = redis.opsForValue().get(key);
        if ("NULL".equals(cached)) return null;   // 空值标记
        if (cached != null) return JSON.parseObject(cached, User.class);

        User user = userMapper.selectById(id);
        if (user == null) {
            redis.opsForValue().set(key, "NULL", NULL_TTL, TimeUnit.MINUTES);
            return null;
        }
        redis.opsForValue().set(key, JSON.toJSONString(user), TTL, TimeUnit.MINUTES);
        return user;
    }
}
```

## 示例 2：Redisson 分布式锁

```java
@Service
public class OrderService {
    @Autowired RedissonClient redisson;
    private static final String LOCK_KEY = "lock:order:";

    @Transactional
    public void createOrder(OrderDTO dto) {
        String key = LOCK_KEY + dto.getProductId();
        RLock lock = redisson.getLock(key);
        try {
            if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {
                // 扣库存 + 创建订单
                inventoryService.deduct(dto.getProductId(), dto.getQuantity());
                orderMapper.insert(buildOrder(dto));
            } else {
                throw new BizException("系统繁忙，请稍后再试");
            }
        } finally {
            if (lock.isHeldByCurrentThread()) lock.unlock();
        }
    }
}
```
