---
name: kafka
description: |
  Apache Kafka 消息队列技能。覆盖生产者 acks/retries/batch 配置、消费者 group.id/auto-offset 规则、幂等性保证(enable.idempotence+业务去重)、Spring Kafka @KafkaListener使用、DLT死信处理、消息顺序性与分区策略。
  当用户配置 Kafka 生产者/消费者、集成 Spring Kafka、处理消息可靠性时使用。
license: Apache-2.0
---

# Apache Kafka 消息队列

> 编码 Kafka 的使用规则。LLM 不配置acks、offset自动提交漏消息、不处理重复消费。

## Capability Boundaries

### ✅ Strong Suits
1. **生产者配置** — acks(retry/partition)/retries(batchSize/linger)/幂等
2. **消费者配置** — auto-offset-reset/enable-auto-commit/manual commit
3. **幂等性保证** — 生产者 enable.idempotence + 消费者业务去重
4. **Spring Kafka** — @KafkaListener/ConcurrentKafkaListenerContainerFactory
5. **DLT死信** — SeekToCurrentErrorHandler + DeadLetterPublishingRecoverer
6. **顺序消息** — 同一Key发送到同一分区

### ❌ Out of Scope
1. Kafka Streams → 流处理，不属于消息队列范畴
2. Kafka Connect → 数据管道，非LLM代码问题

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | acks=0 或 acks=1 丢消息 | 核心业务 acks=all + min.insync.replicas=2 |
| 2 | enable.auto.commit=true（自动提交offset） | 手动提交，处理完再commitSync |
| 3 | 消费者不处理重复消费 | 业务层幂等(唯一键+Redis去重) |
| 4 | 不配置DLT死信，异常消息无限重试 | SeekToCurrentErrorHandler + DeadLetterPublishingRecoverer |
| 5 | 所有消息发到同一个分区 | 用Key路由到分区，同一Key保证顺序 |
| 6 | 同步发送 `producer.send().get()` | 异步发送 + callback 处理异常 |

## 核心规则速查

```java
// ✅ 生产者配置
@Bean
public ProducerFactory<String, Object> producerFactory() {
    Map<String, Object> config = new HashMap<>();
    config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    config.put(ProducerConfig.ACKS_CONFIG, "all");          // 所有副本确认
    config.put(ProducerConfig.RETRIES_CONFIG, 3);            // 重试3次
    config.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true); // 幂等
    config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
    return new DefaultKafkaProducerFactory<>(config);
}

// ✅ 消费者配置
@Bean
public ConsumerFactory<String, Object> consumerFactory() {
    Map<String, Object> config = new HashMap<>();
    config.put(ConsumerConfig.GROUP_ID_CONFIG, "order-group");
    config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // 从最早未消费开始
    config.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);     // 手动提交
    config.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
    return new DefaultKafkaConsumerFactory<>(config);
}

// ✅ Spring Kafka 消费者 + DLT
@KafkaListener(topics = "order-topic", groupId = "order-group")
public void listen(ConsumerRecord<String, OrderEvent> record,
                   Acknowledgment ack) {
    try {
        processOrder(record.value());
        ack.acknowledge();  // 手动提交offset
    } catch (Exception e) {
        // DLT 自动处理，不要重复ack
    }
}

// ✅ DLT 配置
@Bean
public ConcurrentKafkaListenerContainerFactory<String, Object> factory(
    ConsumerFactory<String, Object> cf, KafkaTemplate<String, Object> kt) {
    ConcurrentKafkaListenerContainerFactory<String, Object> f =
        new ConcurrentKafkaListenerContainerFactory<>();
    f.setConsumerFactory(cf);
    f.setCommonErrorHandler(new DefaultErrorHandler(
        new DeadLetterPublishingRecoverer(kt), new FixedBackOff(1000L, 3L)));
    return f;
}
```

## Gotchas
1. **acks=all 最安全但最慢** — 日志/监控类消息可用 acks=1
2. **幂等性 enable.idempotence=true 要求 acks=all + max.in.flight.requests.per.connection=5**
3. **手动提交 offset 必须 finally 或 Spring Acknowledgment 机制** — 漏提交 = 重复消费
4. **DLT 重试次数有限** — 超过重试次数的消息进入 DLT Topic，需要人工处理
5. **同一 group 内每个分区只被一个消费者消费** — 消费者数 > 分区数 → 多余消费者空闲
6. **offset 从 earliest 开始时重放所有历史消息** — 新消费者组需要注意
7. **生产者和消费者的序列化器要匹配** — 用 JsonSerializer/JsonDeserializer 替代 String
8. **异常重试时可能乱序** — 严格顺序场景用 RabbitMQ 或单分区

## Data Privacy
本技能不收集、存储或传输任何用户数据。
