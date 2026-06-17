# Guava 参考资源

## 官方文档

| 资源 | 链接 |
|------|------|
| GitHub | https://github.com/google/guava |
| Wiki 首页 | https://github.com/google/guava/wiki |
| ImmutableCollections | https://github.com/google/guava/wiki/ImmutableCollectionsExplained |
| Caches | https://github.com/google/guava/wiki/CachesExplained |
| Strings | https://github.com/google/guava/wiki/StringsExplained |
| Preconditions | https://github.com/google/guava/wiki/PreconditionsExplained |
| EventBus | https://github.com/google/guava/wiki/EventBusExplained |
| Javadoc | https://guava.dev/releases/snapshot-jre/api/docs/ |

## 关键版本说明

| 版本 | 变化 |
|------|------|
| 33.0+ | JSpecify 注解标记，建议使用 Java8+ |
| 30.0 | 最后的 Android 支持版本 |
| 21.0 | Java8 最低要求，引入 java.time 适配 |

## 与 Java 标准库的替代关系

| Guava 类 | Java 替代 |
|----------|----------|
| ListenableFuture | CompletableFuture (Java 8) |
| MoreExecutors | Executors (Java 5) |
| Joiner | String.join (Java 8) |
| Charsets | StandardCharsets (Java 7) |
| Objects.toStringHelper | 不再需要(用 Lombok @ToString) |

---

> 来源：[https://github.com/google/guava/wiki](https://github.com/google/guava/wiki)
