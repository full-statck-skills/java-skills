---
name: caffeine-patterns
description: |
  Caffeine JVM 本地缓存技能。覆盖本地缓存vs远程缓存(Redis)选择决策树、expireAfterWrite vs expireAfterAccess vs refreshAfterWrite、CacheLoader加载模式、与Spring Cache注解集成、缓存大小驱逐策略。
  当用户需要Java本地缓存、加速热点数据访问时使用。避免LLM直接写 ConcurrentHashMap 或所有缓存都走 Redis。
license: Apache-2.0
---

# Caffeine JVM 本地缓存

> 编码 Caffeine 的使用规则。LLM 要么自己写 ConcurrentHashMap+过期逻辑，要么全走 Redis 不知道本地缓存。

## Capability Boundaries

### ✅ Strong Suits
1. **本地 vs 远程选择** — 单服务高频数据用Caffeine，多服务共享用Redis
2. **过期策略** — expireAfterWrite(写入后) vs expireAfterAccess(访问后) vs refreshAfterWrite
3. **CacheLoader** — 自动加载缺失数据的回源函数
4. **Spring Cache 集成** — @Cacheable/@CacheEvict + CaffeineCacheManager
5. **驱逐策略** — maximumSize(数量)/maximumWeight(权重)/Window TinyLFU

### ❌ Out of Scope
1. 分布式缓存/共享数据 → **redis-redisson**
2. Redis + Caffeine 两级缓存 → **redis-redisson**（已覆盖）

## 缓存选择决策树

```
需要缓存？
├── 单服务 + 热点数据(1000qp+) + 不怕重启丢失 → Caffeine(本地)
├── 多服务共享 + 需要持久化 + 数据一致 → Redis(远程)
└── 超高并发 + 允许不一致 → Caffeine(L1) + Redis(L2) 两级
```

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | ConcurrentHashMap<String,Object> + 手动过期 | Caffeine CacheBuilder 窗口TinyLFU算法 |
| 2 | 所有缓存都走 Redis | 单服务高频缓存走 Caffeine(纳秒级，Redis毫秒级) |
| 3 | 不设置最大容量 | maximumSize(10000) 防止内存溢出 |
| 4 | refreshAfterWrite 设置后不处理加载异常 | 旧值仍可用，加载失败不影响服务 |

## 核心规则速查

```java
// ✅ Caffeine 基本用法
Cache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(10, TimeUnit.MINUTES)
    .build();
User u = cache.get("user:1", key -> loadFromDB(key)); // 自动加载

// ✅ 异步加载
AsyncCache<String, User> asyncCache = Caffeine.newBuilder()
    .refreshAfterWrite(1, TimeUnit.MINUTES)  // 异步刷新
    .buildAsync(key -> loadFromDB(key));

// ✅ Spring Cache 集成
@Configuration
public class CacheConfig {
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager mgr = new CaffeineCacheManager();
        mgr.setCaffeine(Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .maximumSize(10_000));
        return mgr;
    }
}

@Service
public class UserService {
    @Cacheable(value = "users", key = "#id")
    public User getUser(Long id) { return userMapper.selectById(id); }

    @CacheEvict(value = "users", key = "#id")
    public void updateUser(Long id, UserDTO dto) { ... }
}
```

## Gotchas
1. **Caffeine 是进程内缓存** — 多实例部署每个实例有独立缓存，数据不一致
2. **expireAfterAccess 适合会话缓存** — 写入后频率很高就设置 access
3. **refreshAfterWrite < expireAfterWrite** — 否则刷新没意义
4. **异步 CacheLoader 不能返回 null** — 返回 Optional 或抛异常
5. **Spring Cache 的 @Cacheable 返回值必须可序列化** — 如果用 Redis 作为后端
6. **maximumSize 驱逐可能丢失数据** — 重要数据用数据库作为最终保障
7. **与 Redisson 配合** — Caffeine(L1)+Redis(L2)是经典的缓存组合

## Data Privacy
本技能不收集、存储或传输任何用户数据。
