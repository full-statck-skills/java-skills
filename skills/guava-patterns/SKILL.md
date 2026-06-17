---
name: guava-patterns
description: |
  Google Guava 核心工具库技能。覆盖 Immutable集合选择规则、Cache本地缓存(与Caffeine对比选型)、字符串处理(CharMatcher/Joiner/Splitter/CaseFormat)、Preconditions参数校验、EventBus事件总线、Ordering比较器、Multimap/Multiset/BiMap特殊集合、RateLimiter限流。
  当用户在 Java 项目中需要集合操作、缓存、字符串处理、参数校验、事件解耦时使用。避免 LLM 手写工具方法而不用 Guava。
license: Apache-2.0
---

# Google Guava 核心工具库

> 编码 Guava 的使用规则。LLM 会用 Java 标准库自造轮子，不知道 Guava 已有更优方案。

## Capability Boundaries

### ✅ Strong Suits
1. **Immutable集合** — 不可变 List/Set/Map 创建模式，防御性拷贝
2. **Cache** — LoadingCache/CacheBuilder 本地缓存(与 Caffeine 选型对比)
3. **字符串处理** — Joiner/Splitter/CharMatcher/CaseFormat 替代手写循环
4. **Preconditions** — 参数校验，非空/状态/参数检查
5. **EventBus** — 进程内事件解耦(@Subscribe/@AllowConcurrentEvents)
6. **特殊集合** — Multimap(一对多)/Multiset(计数)/BiMap(双向)/Table(二维)
7. **Ordering** — 排序比较器链式API
8. **RateLimiter** — 单机限流

### ❌ Out of Scope
1. Guava 的反射/Future 等模块已被 Java 标准库替代 → 不要用
2. 缓存场景优先选 **Caffeine**（性能更好，API 兼容）

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 手写 `List<String> list = new ArrayList<>(); list.add(...)` 构建不可变列表 | `ImmutableList.of("a","b","c")` |
| 2 | `map.containsKey(k) ? map.get(k) : defaultVal` | `Objects.firstNonNull(map.get(k), defaultVal)` 或 Java8 `getOrDefault` |
| 3 | 手写 for 循环拼接字符串 | `Joiner.on(",").skipNulls().join(list)` |
| 4 | 手写 split + trim | `Splitter.on(",").trimResults().splitToList(str)` |
| 5 | `return x >= 0 && x <= 100` | `Preconditions.checkArgument(x>=0 && x<=100, "x 需在0-100之间: %s", x)` |
| 6 | 手写缓存(ConcurrentHashMap + 过期逻辑) | 用 Guava Cache 或 Caffeine |
| 7 | `new ArrayList() unchecked cast` | Multimap/BiMap 替代手动维护的一对多映射 |

## 核心规则速查

```java
// ✅ Immutable 集合
ImmutableList.of("a", "b");              // 参数少于12个
ImmutableList.copyOf(existingList);       // 防御性拷贝
ImmutableMap.of("k1","v1","k2","v2");

// ✅ 字符串处理
Joiner.on(",").skipNulls().join(list);    // a,b,c
Splitter.on(",").trimResults().splitToList(str);
CaseFormat.LOWER_CAMEL.to(UPPER_UNDERSCORE, "userName"); // USER_NAME
CharMatcher.inRange('0','9').retainFrom(str); // 保留数字

// ✅ Preconditions
checkNotNull(obj, "参数不能为空");
checkArgument(age > 0, "年龄必须>0: %s", age);
checkState(!closed, "已关闭");

// ✅ Cache
LoadingCache<String, User> cache = CacheBuilder.newBuilder()
    .maximumSize(1000).expireAfterWrite(10, TimeUnit.MINUTES)
    .build(new CacheLoader<String, User>() {
        public User load(String key) { return loadFromDB(key); }
    });
User u = cache.get("key");  // 自动加载+缓存

// ✅ 特殊集合
Multimap<String, String> mm = ArrayListMultimap.create();
mm.put("group1","user1"); mm.put("group1","user2");
mm.get("group1");  // [user1, user2]
BiMap<String,Integer> bimap = HashBiMap.create();
bimap.put("one",1); bimap.inverse().get(1); // "one"
```

## Gotchas
1. **Guava Cache 不能替代 Redis** — 单机缓存，重启丢失，多实例不同步
2. **EventBus 只适合进程内** — 跨服务解耦用 Kafka/RocketMQ
3. **ImmutableList.of() 不接受 null** — 包含 null 会抛 NPE
4. **Guava Refect/ListenableFuture 已被 JDK 替代** — 不要再用
5. **Caffeine 性能优于 Guava Cache** — 新项目优先选 Caffeine，Guava Cache 仅用于旧项目兼容
6. **Preconditions 抛出 RuntimeException** — 不需要显式 try-catch
7. **Cache.get() 在加载异常时抛 ExecutionException** — 需要 try-catch 包装

## Data Privacy
本技能不收集、存储或传输任何用户数据。
