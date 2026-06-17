# Kafka 实战示例

```java
// 生产者
@Service
public class OrderProducer {
    @Autowired KafkaTemplate<String, OrderEvent> kafka;
    public void send(OrderEvent event) {
        kafka.send("order-topic", event.getOrderId().toString(), event)
            .addCallback(
                result -> log.info("发送成功: offset={}", result.getRecordMetadata().offset()),
                ex -> log.error("发送失败: orderId={}", event.getOrderId(), ex));
    }
}

// 消费者 + DLT
@Component
public class OrderConsumer {
    @KafkaListener(topics = "order-topic", groupId = "order-group")
    public void consume(ConsumerRecord<String, OrderEvent> record, Acknowledgment ack) {
        try {
            orderService.process(record.value());
            ack.acknowledge();
        } catch (Exception e) {
            log.error("消费失败, 将进入DLT: {}", record.key(), e);
            throw e; // DLT 自动处理
        }
    }
}
```

---

> 来源：[https://kafka.apache.org/documentation/](https://kafka.apache.org/documentation/)
