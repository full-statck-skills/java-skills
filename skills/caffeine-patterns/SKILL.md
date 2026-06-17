---
name: caffeine-patterns
description: |
  Caffeine JVM 本地缓存技能。覆盖本地缓存 vs 远程缓存(Redis)选择决策树、expireAfterWrite vs expireAfterAccess vs refreshAfterWrite 三种过期策略对比与组合规则(refresh < expire)、CacheLoader加载与reload异步刷新模式、Spring Cache @Cacheable集成、maximumSize驱逐策略、recordStats缓存统计。
  纠正 LLM：用 ConcurrentHashMap+手动过期、所有缓存走Redis、refreshAfterWrite > expireAfterWrite导致永远不刷新、CacheLoader返回null导致缓存穿透。
license: Apache-2.0
---

# Caffeine JVM 本地缓存

> 来源：[https://github.com/ben-manes/caffeine/wiki](https://github.com/ben-manes/caffeine/wiki)  
> GitHub：[https://github.com/ben-manes/caffeine](https://github.com/ben-manes/caffeine)

## Capability Boundaries

### ✅ Strong Suits
1. **本地 vs 远程选择** — 单服务高频数据用Caffeine，多服务共享用Redis
2. **过期策略** — expireAfterWrite(写入后) vs expireAfterAccess(访问后) vs refreshAfterWrite(异步刷新)
3. **CacheLoader** — 自动加载缺失数据 + reload 异步刷新 + 优雅降级(返回旧值)
4. **Spring Cache 集成** — @Cacheable/@CacheEvict + CaffeineCacheManager
5. **驱逐策略** — maximumSize(数量)/maximumWeight(权重)/Window TinyLFU
6. **记录统计** — recordStats() + CacheStats 监控命中率

### ❌ Out of Scope
1. 分布式缓存/共享数据 → **redis-redisson-patterns**
2. Redis + Caffeine 两级缓存 → **redis-redisson-patterns**（已覆盖）

## 过期策略选择决策

| 策略 | 行为 | 适用场景 |
|------|------|---------|
| **expireAfterWrite** | 写入后固定时间过期 | ✅ 推荐(大多数业务)，可预测的数据刷新 |
| **expireAfterAccess** | 最后访问后固定时间过期 | 会话缓存/用户登录状态 |
| **refreshAfterWrite** | 写后固定时间异步刷新(返回旧值) | 热点数据免阻塞刷新 |
| **expireAfterWrite + refreshAfterWrite** | 刷新在过期前执行，永不阻塞 | ⭐ 推荐组合 |

> ⚠️ `refreshAfterWrite` 必须 < `expireAfterWrite`，否则刷新永远不触发

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `ConcurrentHashMap<String, Object>` + 手动过期 | Caffeine CacheBuilder 窗口 TinyLFU 算法 |
| 2 | 所有缓存都走 Redis | 单服务高频缓存走 Caffeine(纳秒级，Redis 毫秒级) |
| 3 | 不设置 maximumSize | `maximumSize(10000)` 防止内存溢出 |
| 4 | refreshAfterWrite 设置后不处理加载异常 | 旧值仍可用，加载失败不影响服务 |
| 5 | refreshAfterWrite > expireAfterWrite | 永远不刷新(过期就直接删除了) |
| 6 | CacheLoader.load() 返回 null | 返回 null = 缓存穿透(每次查都走 load) |
| 7 | 只设置 refreshAfterWrite 不设 maximumSize | 无界缓存 → OOM |
| 8 | 修改缓存返回的对象 | 缓存对象被外部修改 → 数据不一致 |

## 核心模式

### 模式 1: Caffeine 常用配置(推荐组合)
```java
// ✅ expireAfterWrite + refreshAfterWrite 组合(推荐)
Cache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(5, TimeUnit.MINUTES)   // 5分钟过期
    .refreshAfterWrite(3, TimeUnit.MINUTES)  // 3分钟后台刷新(返回旧值)
    .recordStats()                            // 记录命中率
    .build(key -> loadFromDB(key));           // CacheLoader
```

### 模式 2: CacheLoader + reload 优雅降级
```java
LoadingCache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(5, TimeUnit.MINUTES)
    .refreshAfterWrite(3, TimeUnit.MINUTES)
    .build(new CacheLoader<String, User>() {
        @Override
        public @Nullable User load(String key) {
            // 缓存未命中时加载
            User user = userMapper.selectById(Long.parseLong(key));
            // ✅ 不要返回 null！使用 Optional 或空对象占位
            return user != null ? user : NULL_USER;
        }

        @Override
        public @Nullable User reload(String key, User oldValue) {
            // ✅ 刷新时优雅降级：加载失败返回旧值
            try {
                return load(key);
            } catch (Exception e) {
                log.error("刷新缓存失败, key={}", key, e);
                return oldValue;  // ← 返回旧值，不影响服务
            }
        }
    });

// 使用
User user = cache.get("user:1");  // 自动加载
```

### 模式 3: Spring Cache 集成
```java
@Configuration
@EnableCaching  // ← 必须！
public class CacheConfig {
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager mgr = new CaffeineCacheManager();
        mgr.setCaffeine(Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .maximumSize(10_000)
            .recordStats());
        return mgr;
    }
}

@Service
public class UserService {
    @Cacheable(value = "users", key = "#id", unless = "#result == null")
    public User getUser(Long id) {
        return userMapper.selectById(id);
    }

    @CacheEvict(value = "users", key = "#id")
    public void updateUser(Long id, UserDTO dto) {
        userMapper.updateById(dto.toEntity(id));
    }

    @CacheEvict(value = "users", allEntries = true)  // 清空整个缓存
    public void refreshAll() { }
}
```

### 模式 4: 异步加载(AsyncCache)
```java
AsyncCache<String, User> asyncCache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(5, TimeUnit.MINUTES)
    .refreshAfterWrite(1, TimeUnit.MINUTES)  // 异步刷新
    .buildAsync(key -> loadFromDB(key));

// 异步获取
CompletableFuture<User> future = asyncCache.get("user:1");
future.thenAccept(user -> System.out.println(user));
```

### 模式 5: 手动缓存操作 + 统计
```java
Cache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(10, TimeUnit.MINUTES)
    .recordStats()  // 启用统计
    .build();

// 手动写入
cache.put("user:1", user);
// 手动失效
cache.invalidate("user:1");

// 统计数据
CacheStats stats = cache.stats();
log.info("命中率: {}, 加载次数: {}, 驱逐次数: {}",
    stats.hitRate(), stats.loadCount(), stats.evictionCount());
```

## Gotchas
1. **Caffeine 是进程内缓存** — 多实例部署每个实例有独立缓存，数据不一致
2. **expireAfterAccess 适合会话缓存** — 写入后频率很高就设置 access
3. **refreshAfterWrite 必须 < expireAfterWrite** — 否则刷新没意义
4. **CacheLoader.load() 不能返回 null** — 返回空占位对象或抛异常
5. **Spring Cache 的 @Cacheable 返回值必须可序列化** — 如果用 Redis 作为后端
6. **maximumSize 驱逐可能丢失数据** — 重要数据用数据库作为最终保障
7. **与 Redisson 配合** — Caffeine(L1) + Redis(L2) 是经典的两级缓存组合
8. **缓存对象可变时注意防御性拷贝** — 外部修改缓存对象导致数据不一致
9. **recordStats() 不影响性能** — 生产环境建议开启
10. **expireAfter(Expiry) 支持自定义过期时间** — 根据 value 动态决定 TTL
11. **Caffeine 3.x 与 2.x 兼容性** — Spring Boot 2.x 使用 Caffeine 2.x，Spring Boot 3.x 使用 3.x
12. **weakKeys/softValues 慎用** — GC 触发的驱逐不可预测

## Data Privacy
本技能不收集、存储或传输任何用户数据。
