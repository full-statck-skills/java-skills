---
name: kafka-patterns
description: |
  Apache Kafka 消息队列技能。覆盖生产者 acks=all/1/0 选择决策、幂等性(enable.idempotence + acks=all)配置、消费者手动提交 offset(enable.auto.commit=false)、DLT死信处理(@RetryableTopic/@DltHandler)、@KafkaListener + 异常处理器(DefaultErrorHandler)、顺序消息(同一Key发同一分区)、事务消息。
  纠正 LLM：acks=0 丢消息、auto.commit 漏消息、不处理重复消费、不配置 DLT。
license: Apache-2.0
---

# Apache Kafka 消息队列

> 来源：[https://kafka.apache.org/documentation/](https://kafka.apache.org/documentation/)  
> Spring Kafka：[https://docs.spring.io/spring-kafka/reference/](https://docs.spring.io/spring-kafka/reference/)

## Capability Boundaries

### ✅ Strong Suits
1. **生产者配置** — acks(retry/partition)/retries(batchSize/linger)/幂等
2. **消费者配置** — auto-offset-reset/enable-auto-commit/manual commit
3. **幂等性保证** — 生产者 enable.idempotence + acks=all + 消费者业务去重
4. **Spring Kafka** — @KafkaListener / @RetryableTopic / @DltHandler
5. **DLT死信** — DefaultErrorHandler + DeadLetterPublishingRecoverer
6. **顺序消息** — 同一Key发送到同一分区
7. **事务消息** — @Transactional + KafkaTransactionManager

### ❌ Out of Scope
1. Kafka Streams → 流处理，不属于消息队列范畴
2. Kafka Connect → 数据管道，非 LLM 代码问题
3. Schema Registry → 序列化方案选型

## 生产者 acks 选择决策

| acks值 | 可靠性 | 延迟 | 适用场景 |
|--------|--------|------|---------|
| `acks=all`(-1) | ⭐⭐⭐ 最高 | 高 | 核心业务(订单/支付/交易) ✅ |
| `acks=1` | ⭐⭐ 中 | 中 | 默认值，一般业务 |
| `acks=0` | ⭐ 最低 | 低 | 日志/监控/不重要的指标 |

> 核心业务必须: `acks=all` + `min.insync.replicas=2`(Broker配置) + `replication.factor=3`

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | acks=0 或 acks=1 丢消息 | 核心业务 acks=all + min.insync.replicas=2 |
| 2 | enable.auto.commit=true（自动提交offset） | 手动提交，处理完再 acknowledge |
| 3 | 消费者不处理重复消费 | 业务层幂等(唯一键+数据库去重) |
| 4 | 不配置DLT死信，异常消息无限重试 | DefaultErrorHandler + DeadLetterPublishingRecoverer |
| 5 | 所有消息发到同一个分区 | 用Key路由到分区，同一Key保证顺序 |
| 6 | 同步发送 `producer.send().get()` | 异步发送 + callback 处理异常 |
| 7 | 不配置 enable.idempotence=true | 幂等生产防止重试导致重复消息 |
| 8 | 监听器内异常不处理 | 配置 ErrorHandler，异常→DLT |

## 核心模式

### 模式 1: 生产者配置（核心业务）
```java
@Bean
public ProducerFactory<String, Object> producerFactory() {
    Map<String, Object> config = new HashMap<>();
    config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    config.put(ProducerConfig.ACKS_CONFIG, "all");                    // ✅ 所有副本确认
    config.put(ProducerConfig.RETRIES_CONFIG, 3);                      // 重试3次
    config.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);        // ✅ 幂等
    config.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
    config.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 120_000);    // 投递超时
    config.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "zstd");        // 压缩
    config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
    return new DefaultKafkaProducerFactory<>(config);
}
```

### 模式 2: 消费者手动提交 + DLT
```java
@Bean
public ConsumerFactory<String, Object> consumerFactory() {
    Map<String, Object> config = new HashMap<>();
    config.put(ConsumerConfig.GROUP_ID_CONFIG, "order-group");
    config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");   // 从最早未消费开始
    config.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);       // ✅ 手动提交
    config.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
    config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
    config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
    return new DefaultKafkaConsumerFactory<>(config);
}

// ✅ DLT 配置
@Bean
public ConcurrentKafkaListenerContainerFactory<String, Object> kafkaListenerContainerFactory(
        ConsumerFactory<String, Object> cf, KafkaTemplate<String, Object> kt) {
    ConcurrentKafkaListenerContainerFactory<String, Object> factory =
        new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(cf);
    // 重试3次，每次间隔1秒，之后进DLT
    factory.setCommonErrorHandler(new DefaultErrorHandler(
        new DeadLetterPublishingRecoverer(kt),
        new FixedBackOff(1000L, 3L)));
    return factory;
}
```

### 模式 3: Spring Kafka 监听器 + DLT
```java
// 方式一：直接 @KafkaListener + DLT ErrorHandler
@KafkaListener(topics = "order-topic", groupId = "order-group")
public void listen(ConsumerRecord<String, OrderEvent> record, Acknowledgment ack) {
    try {
        processOrder(record.value());
        ack.acknowledge();          // ✅ 手动提交 offset
    } catch (Exception e) {
        log.error("处理订单失败: key={}", record.key(), e);
        throw e;                    // 抛出 → ErrorHandler → 重试 → DLT
    }
}

// 方式二：@RetryableTopic 自动重试 + DLT
@RetryableTopic(
    attempts = "4",
    backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000),
    kafkaTemplate = "kafkaTemplate")
@KafkaListener(topics = "order-topic", groupId = "order-group")
public void processOrder(OrderEvent event) {
    // 业务逻辑，失败自动重试(1s→2s→4s→...)
}

@DltHandler
public void handleDlt(OrderEvent event) {
    log.error("消息进入死信队列: {}", event);
    // 人工处理或告警
}
```

### 模式 4: 消息发送（异步 + callback）
```java
@Service
public class OrderEventPublisher {
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishOrderCreated(OrderEvent event) {
        String key = String.valueOf(event.getOrderId());  // ✅ 同一订单→同一分区
        ListenableFuture<SendResult<String, Object>> future =
            kafkaTemplate.send("order-topic", key, event);

        // ✅ 异步处理发送结果
        future.addCallback(result -> log.debug("发送成功: {}", result.getRecordMetadata().offset()),
            ex -> log.error("发送失败: key={}", key, ex));
    }
}
```

### 模式 5: 业务幂等(消费者端去重)
```java
@KafkaListener(topics = "order-topic")
public void listen(OrderEvent event) {
    // ✅ 业务幂等：用事件ID去重
    String eventId = event.getEventId();
    Boolean existed = redisTemplate.opsForValue().setIfAbsent(
        "kafka:dedup:" + eventId, "1", Duration.ofHours(24));
    if (Boolean.FALSE.equals(existed)) {
        log.debug("重复事件跳过: {}", eventId);
        return;
    }
    // 处理业务
    processOrder(event);
}
```

## Gotchas
1. **acks=all 最安全但最慢** — 日志/监控类消息可用 acks=1
2. **幂等性 enable.idempotence=true 要求 acks=all + max.in.flight.requests.per.connection<=5**
3. **手动提交 offset 必须 finally 或 Spring Acknowledgment** — 漏提交 = 重复消费
4. **DLT 重试次数有限** — 超过重试次数的消息进入 DLT Topic，需要人工处理
5. **同一 group 内每个分区只被一个消费者消费** — 消费者数 > 分区数 → 多余消费者空闲
6. **offset 从 earliest 开始时重放所有历史消息** — 新消费者组需要注意
7. **生产者和消费者的序列化器要匹配** — 用 JsonSerializer/JsonDeserializer 替代 String
8. **异常重试时可能乱序** — 严格顺序场景用单分区或 RabbitMQ
9. **@RetryableTopic 会创建额外 retry topic** — 注意 Topic 数量膨胀
10. **压缩(zstd/snappy) 降低网络带宽** — 推荐 zstd(压缩比高)
11. **max.poll.records 控制每批拉取数量** — 匹配处理速度，避免 rebalance
12. **大消息(>1MB)需要配置 max.message.bytes** — 建议 < 10MB

## Data Privacy
本技能不收集、存储或传输任何用户数据。
