# Lombok 实战示例

## 示例 1：MyBatis 实体正确写法（不用 @Builder）

```java
@Data
@TableName("sys_user")
public class SysUser extends BaseEntity<SysUser> {
    private String username;
    private String email;
    // ❌ 不要加 @Builder — MyBatis 需要无参构造器
    // ❌ 不要加 @AllArgsConstructor — @Data 已够用
    // ✅ @Data 自动生成 getter/setter/toString/equals/hashCode
}
```

## 示例 2：API 返回 DTO（用 @Value 不可变 + @Builder）

```java
@Value
@Builder
@Jacksonized  // ← Jackson 反序列化支持，关键！
public class UserVO {
    Long id;
    String username;
    String email;
    @Builder.Default
    Integer age = 0;           // Builder 默认值
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    LocalDateTime createTime;
}

// 使用
UserVO vo = UserVO.builder()
    .id(1L).username("张三").email("zhang@example.com")
    .createTime(LocalDateTime.now()).build();
```

## 示例 3：继承时 callSuper

```java
@Data
@EqualsAndHashCode(callSuper = true)  // ← 必须，否则只比较子类字段
public class AdminUser extends BaseUser {
    private String role;
    // equals/hashCode 会包含 BaseUser 的 id/username 字段
}
```

## 示例 4：@Slf4j 日志

```java
@Slf4j
@Service
public class OrderService {
    public void createOrder(OrderDTO dto) {
        log.info("创建订单: userId={}, amount={}", dto.getUserId(), dto.getAmount());
        try { /* 业务逻辑 */ }
        catch (Exception e) { log.error("订单创建失败: orderId={}", dto.getOrderId(), e); }
    }
}
```

---

> 来源：[https://projectlombok.org/features/](https://projectlombok.org/features/)
