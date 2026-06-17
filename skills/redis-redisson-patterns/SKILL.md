---
name: redis-redisson-patterns
description: |
  Redis + Redisson 缓存与分布式锁技能。覆盖缓存Key命名规范、过期时间设置原则、RedisTemplate序列化选择(JSON vs JDK vs String)、Redisson分布式锁三大模式(watchDog/tryLock 有leaseTime/无leaseTime 决策)、缓存穿透(布隆/空值缓存)/击穿(互斥锁)/雪崩(随机TTL)防护、Caffeine vs Redis选择决策。
  纠正 LLM：不设过期时间、StringRedisTemplate和RedisTemplate混用、Redisson锁不 try-finally unlock、看门狗在指定 leaseTime 时不生效。
license: Apache-2.0
---

# Redis + Redisson 缓存与分布式锁

> 来源：[https://redisson.org/docs/](https://redisson.org/docs/)  
> GitHub：[https://github.com/redisson/redisson](https://github.com/redisson/redisson)  
> Redis：[https://redis.io/documentation](https://redis.io/documentation)

## Capability Boundaries

### ✅ Strong Suits
1. **缓存Key规范** — 格式 `{业务名}:{类型}:{ID}`，统一前缀
2. **过期时间原则** — 热点数据长TTL、非热点短TTL、永远不设-1
3. **序列化选择** — JSON vs JDK vs String 三种方案对比与配置
4. **Redisson分布式锁** — tryLock/watchDog/leaseTime/可重入/公平锁/红锁
5. **缓存三大问题防护** — 穿透(布隆/空值)/击穿(互斥锁)/雪崩(随机TTL)
6. **Caffeine vs Redis选择** — 什么时候用本地缓存什么时候用Redis
7. **RedisTemplate 正确配置** — 统一 Key/Value 序列化

### ❌ Out of Scope
1. 消息队列/发布订阅 → **kafka** / RabbitMQ
2. Spring Session 共享 → **spring-security**
3. Jedis/Lettuce 客户端选择 → 本文档推荐 Lettuce(Spring Boot默认)

## 序列化选择决策

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **StringRedisTemplate** | 简单、可读 | 只能存 String，对象需手动序列化 | 纯字符串缓存 |
| **RedisTemplate + Jackson2JsonRedisSerializer** | 可读、跨语言 | 性能略低 | ✅ 推荐(适用于大部分场景) |
| **RedisTemplate + JdkSerializationRedisSerializer** | 默认(含类型信息) | 不可读、体积大、只限Java | ❌ 避免(默认就是它) |
| **RedisTemplate + GenericJackson2JsonRedisSerializer** | 含@class类型 | 冗余字段多 | 缓存复杂对象 |

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 缓存不设过期时间(永久) | 必须设 TTL，防止内存溢出 |
| 2 | StringRedisTemplate 和 RedisTemplate 混用 | 统一用一个，推荐 RedisTemplate + JSON 序列化 |
| 3 | 缓存穿透(查不存在数据直接透到DB) | 空值缓存(Boolean.FALSE, TTL 5分钟) 或布隆过滤器 |
| 4 | Redis 做高频热点缓存(每次1000qps以上) | 加 Caffeine 本地缓存层(L1本地 + L2 Redis) |
| 5 | `lock.lock()` 不用 try-finally | 必须 `finally { lock.unlock() }` |
| 6 | 缓存Key没有命名规范 | 统一格式：`saas:user:10001`、`saas:order:list` |
| 7 | Redisson 指定 leaseTime 还期待看门狗续期 | 指定 leaseTime 看门狗不生效！ |
| 8 | 缓存雪崩不处理(大量Key同时过期) | TTL 加随机值(±30%) |
| 9 | 热点Key缓存击穿 | 互斥锁或永不过期+异步更新 |
| 10 | 使用 RedisTemplate 默认 JDK 序列化 | 改为 JSON 序列化(可读、跨语言) |

## 核心模式

### 模式 1: RedisTemplate 统一配置(JSON序列化)
```java
@Configuration
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);

        // ✅ 推荐：Jackson2JsonRedisSerializer
        Jackson2JsonRedisSerializer<Object> serializer =
            new Jackson2JsonRedisSerializer<>(Object.class);
        ObjectMapper mapper = new ObjectMapper();
        mapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        mapper.activateDefaultTyping(LazySerializationTypeValidator.getDefaultTyper(),
            ObjectMapper.DefaultTyping.NON_FINAL);
        serializer.setObjectMapper(mapper);

        template.setKeySerializer(new StringRedisSerializer());     // Key: String
        template.setValueSerializer(serializer);                    // Value: JSON
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);
        template.afterPropertiesSet();
        return template;
    }
}
```

### 模式 2: 缓存穿透防护（空值缓存）
```java
public User getUser(Long id) {
    String key = String.format("saas:user:%s", id);
    User user = (User) redisTemplate.opsForValue().get(key);

    // 空值标记，直接返回
    if (user == NULL_PLACEHOLDER) return null;
    // 缓存命中
    if (user != null) return user;

    // 查询DB
    user = userMapper.selectById(id);
    if (user == null) {
        // ✅ 空值缓存(防穿透)，TTL 5分钟
        redisTemplate.opsForValue().set(key, NULL_PLACEHOLDER, 5, TimeUnit.MINUTES);
        return null;
    }
    // ✅ 正常缓存，30分钟
    redisTemplate.opsForValue().set(key, user, 30, TimeUnit.MINUTES);
    return user;
}
```

### 模式 3: Redisson 分布式锁三大模式

**模式A: tryLock + watchDog(推荐) — 有等待时间 + 自动续期**
```java
RLock lock = redissonClient.getLock("lock:order:" + orderId);
// ✅ 只指定 waitTime，不指定 leaseTime → watchDog 生效(默认30s续期)
if (lock.tryLock(10, TimeUnit.SECONDS)) {  // 等10秒获取锁
    try {
        // 业务处理(可能超过30秒，watchDog自动续期)
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

**模式B: tryLock + leaseTime — 硬超时(看门狗不生效)**
```java
RLock lock = redissonClient.getLock("lock:order:" + orderId);
// ⚠️ 指定了 leaseTime → watchDog 不生效
if (lock.tryLock(10, 30, TimeUnit.SECONDS)) {
    try {
        // 必须在30秒内完成，否则锁自动释放
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

**模式C: lock() — 阻塞等待 + watchDog**
```java
RLock lock = redissonClient.getLock("lock:order:" + orderId);
lock.lock();  // 阻塞直到获取锁，watchDog 生效
try {
    // 业务处理
} finally {
    if (lock.isHeldByCurrentThread()) {
        lock.unlock();
    }
}
```

### 模式 4: 缓存雪崩防护(随机TTL)
```java
// 相同业务场景的缓存 TTL 加随机值，避免同时过期
int baseTtl = 3600;  // 1小时
int randomTtl = baseTtl + new Random().nextInt(600);  // +0~10分钟随机
redisTemplate.opsForValue().set(key, value, randomTtl, TimeUnit.SECONDS);
```

### 模式 5: 缓存Key规范
```java
// 命名格式: {业务}:{领域}:{实体}:{唯一标识}
private static final String USER_CACHE_KEY = "saas:user:detail:%s";
private static final String ORDER_LIST_KEY = "saas:order:list:%s:%d"; // userId + page
private static final String CONFIG_KEY = "saas:config:global";

String key = String.format(USER_CACHE_KEY, userId);
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
9. **isHeldByCurrentThread() 必须在 unlock 前检查** — 避免 IllegalMonitorStateException
10. **RedisTemplate 默认 JDK 序列化** — 改为 JSON 序列化(可读、跨语言)
11. **Lettuce(Spring Boot 默认) 比 Jedis 更推荐** — 异步、连接池、社区活跃
12. **布隆过滤器(RedissonBloomFilter)用于防穿透** — 适用于 key 数量大、不要求100%精确

## Data Privacy
本技能不收集、存储或传输任何用户数据。
