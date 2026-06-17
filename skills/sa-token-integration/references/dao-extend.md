# Redis 持久化 + Alone-Redis

> 来源：
> - [dao-extend.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/dao-extend.md)
> - [integ-redis.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/integ-redis.md)（212行）
> - [alone-redis.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/alone-redis.md)（170行）

## 两种序列化方式

```xml
<!-- JDK默认序列化(兼容性好，不可读) -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis</artifactId>
    <version>1.45.0</version>
</dependency>

<!-- RedisTemplate JSON序列化(推荐，数据可读) -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis-template</artifactId>
    <version>1.45.0</version>
</dependency>
```

两种都需要连接池：
```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```

## Redis配置

```yaml
spring:
  redis:
    database: 1
    host: 127.0.0.1
    port: 6379
    timeout: 1000ms
    lettuce:
      pool:
        max-active: 200
        max-idle: 10
        min-idle: 0
```

## Alone-Redis（独立Redis）

将Sa-Token的Redis与业务Redis隔离，互不影响。

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-alone-redis</artifactId>
    <version>1.45.0</version>
</dependency>
```

```yaml
sa-token-alone-redis:
  host: 192.168.0.10
  port: 6379
  database: 2
  password: xxxx
  lettuce:
    pool:
      max-active: 200
      max-idle: 10
```

## JSON序列化扩展

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-jackson</artifactId>
    <version>1.45.0</version>
</dependency>
<!-- 或 fastjson / fastjson2 / snack3 / snack4 -->
```

## 注意

引入Redis后框架自动保存会话数据，上层API不变，无需手动操作Redis。
