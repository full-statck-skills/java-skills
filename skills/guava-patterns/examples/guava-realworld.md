# Guava 实战示例

## 示例 1：Immutable 集合防御性拷贝

```java
@Component
public class ConfigService {
    // ✅ 静态常量用 of()
    private static final ImmutableSet<String> ALLOWED_ORIGINS =
        ImmutableSet.of("https://app.example.com", "https://admin.example.com");

    // ✅ 防御性拷贝：外部传入的集合不可变
    private final ImmutableList<Rule> rules;

    public ConfigService(List<Rule> rules) {
        this.rules = ImmutableList.copyOf(rules); // 外部修改不影响内部
    }

    public boolean isAllowedOrigin(String origin) {
        return ALLOWED_ORIGINS.contains(origin);
    }
}
```

## 示例 2：Cache + 异步刷新模式

```java
@Service
public class DictionaryService {
    private final LoadingCache<String, List<DictItem>> cache = CacheBuilder.newBuilder()
        .maximumSize(100)
        .refreshAfterWrite(5, TimeUnit.MINUTES)    // 5分钟后触发刷新
        .expireAfterWrite(30, TimeUnit.MINUTES)    // 30分钟强制过期
        .build(new CacheLoader<>() {
            public List<DictItem> load(String type) { return loadFromDB(type); }
            public ListenableFuture<List<DictItem>> reload(String type, List<DictItem> old) {
                return executor.submit(() -> loadFromDB(type)); // 异步刷新
            }
        });

    public List<DictItem> getDict(String type) {
        return cache.getUnchecked(type);  // 自动加载+缓存
    }
}
```

## 示例 3：Joiner/Splitter 管道模式

```java
@RestController
public class ExportController {
    private static final Joiner CSV_JOINER = Joiner.on(",").useForNull("");
    private static final Splitter TAG_SPLITTER = Splitter.on("#").trimResults().omitEmptyStrings();

    @GetMapping("/export/users")
    public String export() {
        List<User> users = userService.getAll();
        return users.stream()
            .map(u -> CSV_JOINER.join(u.getId(), u.getName(), u.getEmail()))
            .collect(Collectors.joining("\n"));
    }

    @PostMapping("/users/batch")
    public void batchCreate(@RequestParam String tags) {
        List<String> tagList = TAG_SPLITTER.splitToList(tags);
        userService.createWithTags(tagList);
    }
}
```

## 示例 4：CharMatcher 清理输入

```java
public class InputSanitizer {
    // 只保留数字
    public static String keepDigits(String input) {
        return CharMatcher.digit().retainFrom(input);
    }
    // 清理控制字符(避免注入)
    public static String removeControlChars(String input) {
        return CharMatcher.javaIsoControl().removeFrom(input);
    }
    // 规范化空白(多空格→单空格)
    public static String normalizeWhitespace(String input) {
        return CharMatcher.whitespace().trimAndCollapseFrom(input, ' ');
    }
}
```

---

> 来源：[https://github.com/google/guava/wiki](https://github.com/google/guava/wiki)
