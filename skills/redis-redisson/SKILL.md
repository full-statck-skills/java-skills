---
name: redis-redisson
description: |
  Redis + Redisson 缓存与分布式锁技能。覆盖缓存Key命名规范、过期时间设置原则、RedisTemplate序列化选择(JSON vs JDK)、Redisson分布式锁规则(看门狗/WatchDog)、缓存穿透/击穿/雪崩防护、本地缓存(Caffeine)vs分布式缓存(Redis)选择决策。
  当用户使用Redis做缓存、使用Redisson做分布式锁、解决缓存一致性问题时使用。
license: Apache-2.0
---

# Redis + Redisson 缓存与分布式锁

> 编码 Redis 的使用规则。LLM 混用 StringRedisTemplate/RedisTemplate、不设过期时间、不防缓存穿透。

## Capability Boundaries

### ✅ Strong Suits
1. **缓存Key规范** — 格式 `{业务名}:{类型}:{ID}`，统一前缀
2. **过期时间原则** — 热点数据长TTL、非热点短TTL、永远不设-1
3. **序列化选择** — JSON vs JDK vs String 三种方案对比
4. **Redisson分布式锁** — tryLock/watchDog/leaseTime/可重入/公平锁
5. **缓存三大问题防护** — 穿透(布隆/空值)/击穿(互斥锁)/雪崩(随机TTL)
6. **Caffeine vs Redis选择** — 什么时候用本地缓存什么时候用Redis

### ❌ Out of Scope
1. 消息队列/发布订阅 → **kafka** / RabbitMQ
2. Spring Session 共享 → **spring-security**
3. Jedis/Lettuce 客户端选择 → 本文档推荐 Lettuce(Spring Boot默认)

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 缓存不设过期时间 | 必须设 TTL，防止内存溢出 |
| 2 | StringRedisTemplate 和 RedisTemplate 混用 | 统一用一个，推荐 RedisTemplate 配置 JSON 序列化 |
| 3 | 缓存穿透(查不存在数据直接透到DB) | 空值缓存(Boolean.FALSE, TTL 5分钟) 或布隆过滤器 |
| 4 | Redis 做高频热点缓存(每次1000qps以上) | 加 Caffeine 本地缓存层(L1本地 + L2 Redis) |
| 5 | Redisson lock.lock() 不用 try-finally | `lock.lock()` 必须配 `finally { lock.unlock() }` |
| 6 | 缓存Key没有命名规范 | 统一格式：`saas:user:10001`、`saas:order:list` |

## 核心规则速查

```java
// ✅ 缓存Key规范
private static final String USER_CACHE_KEY = "saas:user:%s";
String key = String.format(USER_CACHE_KEY, userId);

// ✅ 缓存穿透防护(空值缓存)
public User getUser(Long id) {
    String key = String.format("saas:user:%s", id);
    User user = (User) redisTemplate.opsForValue().get(key);
    if (user == BooleanFlag.NULL) return null; // 空值标记
    if (user != null) return user;

    user = userMapper.selectById(id);
    if (user == null) {
        redisTemplate.opsForValue().set(key, BooleanFlag.NULL, 5, TimeUnit.MINUTES);
        return null;
    }
    redisTemplate.opsForValue().set(key, user, 30, TimeUnit.MINUTES);
    return user;
}

// ✅ Redisson 分布式锁
RLock lock = redissonClient.getLock("lock:order:" + orderId);
try {
    if (lock.tryLock(10, 30, TimeUnit.SECONDS)) { // 等待10s，自动释放30s
        // 业务处理
    }
} finally {
    if (lock.isHeldByCurrentThread()) lock.unlock();
}

// ✅ RedisTemplate 配置(JSON序列化)
@Bean
public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
    RedisTemplate<String, Object> template = new RedisTemplate<>();
    template.setConnectionFactory(factory);
    Jackson2JsonRedisSerializer<Object> serializer = new Jackson2JsonRedisSerializer<>(Object.class);
    template.setKeySerializer(new StringRedisSerializer());
    template.setValueSerializer(serializer);
    template.setHashValueSerializer(serializer);
    return template;
}
```

## Gotchas
1. **缓存必须设过期时间** — 永不设TTL = 内存泄漏
2. **Redisson lock 必须 try-finally unlock** — 否则死锁
3. **watchDog 看门狗自动续期** — 未指定 leaseTime 时默认30s，每10s续一次
4. **指定了 leaseTime 看门狗不生效** — 需要自动续期就别指定 leaseTime
5. **Redis 集群不能用批量 mget(跨Slot)** — 改为循环 get 或 hash tag 固定 Slot
6. **缓存雪崩：同一时间大量Key同时过期** — TTL 加随机值(±30%)
7. **缓存击穿：热点Key过期瞬间大量请求穿透** — 互斥锁或永不过期+异步更新
8. **Caffeine更适合单服务高频缓存** — Redis用于分布式共享，Caffeine用于本地加速

## Data Privacy
本技能不收集、存储或传输任何用户数据。
