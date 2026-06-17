---
name: guava-patterns
description: |
  Google Guava 最佳实践模式。从官方 wiki 提炼，覆盖 Immutable集合的 of/copyOf/builder 三模式与防御性拷贝规则、Cache 选择决策(LoadingCache vs Cache vs Caffeine)、Joiner/Splitter 不可变流水线、CharMatcher 替代正则、Preconditions 格式化消息校验、CaseFormat 命名互转。
  纠正 LLM 误用：手写不可变集合、ConcurrentHashMap 替代 Cache、不知 CharMatcher。
license: Apache-2.0
---

# Google Guava 最佳实践模式

> 来源: [Guava Wiki](https://github.com/google/guava/wiki) | GitHub: [google/guava](https://github.com/google/guava)

## Capability Boundaries

### ✅ Strong Suits
1. **Immutable集合三模式** — `of()`静态常量 / `copyOf()`防御性拷贝 / `builder()`渐进构建
2. **Cache模式选择** — Cache(无默认加载) vs LoadingCache(有默认加载函数) vs Caffeine(高性能)
3. **Joiner/Splitter流水线** — 函数式组合，实例线程安全可作 static final 常量
4. **CharMatcher** — 预定义字符类操作，比正则更可读更安全
5. **Preconditions** — checkArgument/checkNotNull/checkState 三剑客，格式化消息(类似printf)
6. **CaseFormat** — LOWER_CAMEL/UPPER_UNDERSCORE 等 ASCII 命名风格互转

### ❌ Out of Scope
1. ListenableFuture → 已被 Java8 CompletableFuture 替代，不要再用
2. EventBus → 仅进程内，跨服务用 **kafka-patterns**
3. 高性能缓存 → **caffeine-patterns**(API兼容Guava，性能更好)

## 核心模式

### 模式 1: Immutable 集合三选择

```java
// ✅ of() — 编译期已知元素(作静态常量)
public static final ImmutableSet<String> COLORS = ImmutableSet.of("red","green","blue");

// ✅ copyOf() — 防御性拷贝(接收外部集合)
class Foo {
    final ImmutableSet<Bar> bars;
    Foo(Set<Bar> bars) { this.bars = ImmutableSet.copyOf(bars); }
}

// ✅ builder() — 渐进构建(合并多来源)
ImmutableSet<Color> colors = ImmutableSet.<Color>builder()
    .addAll(WEBSAFE_COLORS).add(new Color(0,191,255)).build();

// ❌ Collections.unmodifiableXXX — 冗长/不安全(持有引用仍可改)/低效(保留并发检查)
```

### 模式 2: Cache 选择决策

```
有明确的"未命中→加载"函数 → LoadingCache (get(key)自动加载)
加载函数因key而异 → Cache (get(key, callable)每次指定)
高频+高并发+追求性能 → Caffeine (API兼容,窗口TinyLFU)
多实例共享 → Redis
```

```java
// ✅ LoadingCache: 统一加载函数
LoadingCache<String, User> cache = CacheBuilder.newBuilder()
    .maximumSize(1000).expireAfterWrite(10, TimeUnit.MINUTES)
    .build(new CacheLoader<>() { public User load(String k) { return loadDB(k); }});
User u = cache.get("user:1");  // 自动加载+缓存

// ✅ 异步刷新(旧值仍可用，后台加载新值)
LoadingCache<String, Config> cfg = CacheBuilder.newBuilder()
    .refreshAfterWrite(1, TimeUnit.MINUTES)
    .build(new CacheLoader<>() { public Config load(String k) { ... }});

// ✅ RemovalListener: 异步拆除资源避免阻塞缓存
RemovalListener<String, Conn> listener = RemovalListeners.asynchronous(
    notif -> notif.getValue().close(), executor);
```

### 模式 3: Joiner/Splitter 不可变流水线

```java
// Joiner: 实例不可变，可作 static final 常量
private static final Joiner JOINER = Joiner.on(",").skipNulls();
JOINER.join(list);                                    // "a,b,c"
Joiner.on("; ").useForNull("N/A").join("a",null,"c");  // "a; N/A; c"

// Splitter: 链式修饰 trimResults → omitEmptyStrings → limit
List<String> parts = Splitter.on(',').trimResults()
    .omitEmptyStrings().splitToList("foo,bar,,  qux");  // ["foo","bar","qux"]

// Map Splitter: URL参数解析
Map<String,String> m = Splitter.on('&')
    .withKeyValueSeparator('=').split("id=123&name=foo");

// 固定长度切分
Splitter.fixedLength(3).splitToList("abcdefg");  // ["abc","def","g"]
```

### 模式 4: CharMatcher 替代正则

```java
// ✅ CharMatcher — 编译期类型安全，比正则更可读
CharMatcher.digit().retainFrom("abc123");           // "123"
CharMatcher.javaIsoControl().removeFrom(string);     // 删除控制字符
CharMatcher.whitespace().trimAndCollapseFrom(" foo   bar ", ' '); // "foo bar"
CharMatcher.inRange('a','z').or(CharMatcher.is('_')).matchesAllOf(input);

// ❌ 反模式：Pattern.compile("\\d+") — CharMatcher 更优
```

### 模式 5: Preconditions vs Objects

```java
// ✅ Guava Preconditions: 格式化消息(类似printf)
checkNotNull(obj, "参数不能为空: %s", userId);
checkArgument(age > 0, "年龄必须>0: %s", age);

// ✅ Java Objects: 简单非空(无格式化)
Objects.requireNonNull(obj, "参数不能为空");
// 选择: 需要消息格式化 → Preconditions; 简单判空 → Objects
```

## Gotchas
1. **ImmutableList.of() 不接受 null** — 含null抛NPE，需null用Collections.unmodifiableList
2. **Cache.get() 加载异常抛 ExecutionException** — 需要try-catch或getUnchecked()
3. **expireAfterAccess vs expireAfterWrite** — access适合频繁读(会话)，write适合稳定数据
4. **refreshAfterWrite 必须小于 expireAfterWrite** — 否则刷新在过期后执行，无意义
5. **Guava Reflect/ListenableFuture 已被 JDK 替代** — Java8+ 不要再用Guava版本
6. **Caffeine 性能优于 Guava Cache** — 新项目优先Caffeine，仅旧项目兼容用Guava
7. **CharMatcher 只匹配单个字符** — 多字符模式(如关键词匹配)仍需正则

## Data Privacy
本技能不收集、存储或传输任何用户数据。
