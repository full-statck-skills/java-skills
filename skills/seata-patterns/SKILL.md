---
name: seata-patterns
description: |
  Seata 分布式事务技能。覆盖 AT/TCC/SAGA/XA 四模式选择决策树、AT模式 undo_log 表必备、TCC 模式 useTCCFence 解决幂等/悬挂/空回滚、SAGA 状态机长流程、全局事务超时配置(@GlobalTransactional timeoutMills)、读隔离增强(@GlobalLock + FOR UPDATE)。
  纠正 LLM：不知道 AT/TCC/SAGA选哪个、不建 undo_log 表、TCC Confirm非幂等、不看门狗处理。
license: Apache-2.0
---

# Seata 分布式事务

> 来源：[https://seata.apache.org/docs/](https://seata.apache.org/docs/)  
> GitHub：[https://github.com/apache/incubator-seata](https://github.com/apache/incubator-seata)

## Capability Boundaries

### ✅ Strong Suits
1. **AT模式(推荐起始)** — 基于数据源代理，零侵入，覆盖80%场景
2. **TCC模式** — 自定义Try/Confirm/Cancel，性能更好，适合高并发核心业务
3. **SAGA模式** — 长流程事务(>10s)，状态机驱动，最终一致性
4. **XA模式** — 强一致，标准协议，适合金融核心
5. **undo_log表** — AT模式必须建立(每个业务库)
6. **@GlobalTransactional** — 全局事务入口
7. **@GlobalLock** — 读隔离增强

### ❌ Out of Scope
1. 单数据库事务 → Spring @Transactional
2. 最终一致性(不要求强一致) → Kafka/RocketMQ 事务消息

## 四模式选择决策树

```
需要分布式事务?
├── 需要强一致性(金融核心) → XA模式(性能差)
├── 最终一致即可
│   ├── 事务执行时间 > 10秒 → SAGA模式(状态机)
│   ├── 高并发 + 愿意写Confirm/Cancel → TCC模式
│   └── 80%场景(默认推荐) → AT模式(零侵入)
```

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 不知道 AT 模式需要 undo_log 表 | 每个业务数据库建 `undo_log` 表 |
| 2 | AT 模式用非 ACID 数据库 | AT 依赖本地事务，必须 MySQL/PostgreSQL/Oracle |
| 3 | 全局事务超时不设置(默认60s可能不够) | 配置 `@GlobalTransactional(timeoutMills = 300000)` |
| 4 | TCC 模式 Confirm 失败不处理幂等 | Confirm 必须幂等(全局唯一ID+去重索引) |
| 5 | TCC 模式不处理空回滚 | 用 `useTCCFence = true`(Seata 1.5.1+) |
| 6 | 读隔离不处理(读到全局事务未提交的数据) | 查询加 `FOR UPDATE` + `@GlobalLock` |
| 7 | SAGA 模式以为会自动回滚 | SAGA 需手动写补偿逻辑 |
| 8 | 全局事务用时过长(锁冲突) | 设置合理超时(建议15~30秒) |

## 核心模式

### 模式 1: AT 模式(零侵入，推荐)
```sql
-- ✅ 每个业务数据库必须建 undo_log 表
CREATE TABLE IF NOT EXISTS undo_log (
    id BIGINT NOT NULL AUTO_INCREMENT,
    branch_id BIGINT NOT NULL,
    xid VARCHAR(128) NOT NULL,
    context VARCHAR(128) NOT NULL,
    rollback_info LONGBLOB NOT NULL,
    log_status INT NOT NULL,
    log_created DATETIME NOT NULL,
    log_modified DATETIME NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY ux_undo_log (xid, branch_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
```

```java
// ✅ AT 模式：只需注解，零业务侵入
@Service
public class OrderService {
    @GlobalTransactional(timeoutMills = 300000, rollbackFor = Exception.class)
    public void createOrder(OrderDTO dto) {
        orderService.create(dto);           // 远程服务A(本地事务)
        inventoryService.deduct(dto);       // 远程服务B(本地事务)
        accountService.debit(dto);          // 远程服务C(本地事务)
        // 任一失败 → 全部自动回滚(基于 undo_log)
    }
}
```

### 模式 2: TCC 模式(高并发核心业务)
```java
@LocalTCC
public interface AccountTccAction {
    @TwoPhaseBusinessAction(
        name = "accountTcc",
        commitMethod = "confirm",
        rollbackMethod = "cancel",
        useTCCFence = true  // ← Seata 1.5.1+ 自动处理幂等/悬挂/空回滚
    )
    boolean prepare(BusinessActionContext ctx,
        @BusinessActionContextParameter(paramName = "accountDTO") AccountDTO dto);

    // ✅ Confirm 必须幂等(可重复执行不改变结果)
    boolean confirm(BusinessActionContext ctx);

    // ✅ Cancel 必须是幂等补偿(可能先于 Try 执行=空回滚)
    boolean cancel(BusinessActionContext ctx);
}
```

### 模式 3: SAGA 模式(长流程状态机)
```java
// SAGA 使用状态机引擎，通过 JSON 配置编排长事务
// 每个步骤有正向(serviceMethod)和补偿(compensateMethod)

// 适用场景：订单履约、审批流、物流追踪
// 补偿顺序必须严格反向执行
// 补偿操作必须幂等且可重试
```

### 模式 4: 读隔离增强(@GlobalLock + FOR UPDATE)
```java
@GlobalLock
@Transactional
public Order getOrder(Long orderId) {
    // ✅ FOR UPDATE + @GlobalLock 解决 AT 模式脏读
    return orderMapper.selectForUpdate(orderId);
}
```

```xml
<select id="selectForUpdate" resultMap="BaseResultMap">
    SELECT * FROM orders WHERE id = #{id} FOR UPDATE
</select>
```

## Gotchas
1. **AT 模式不支持非 ACID 数据库** — MySQL/PostgreSQL/Oracle 可，Redis/Mongo 不可
2. **undo_log 表必须和业务表在同一数据库** — 不同库回滚不了
3. **TCC 的 Confirm 必须是幂等的** — 可重复执行不改变结果
4. **TCC 的 Cancel 必须处理空回滚** — Try 未执行但 Cancel 已收到
5. **SAGA 模式没有自动回滚** — 需手动写补偿逻辑(状态机配置)
6. **全局锁可能导致死锁** — 设置合理的超时时间(timeoutMills)
7. **@GlobalTransactional 默认60s超时** — 超时后自动回滚，长事务手动调整
8. **Seata TC 必须集群部署至少3节点** — 防单点故障
9. **undo_log 表定期清理** — 已完成的undo_log可删除(常驻内存)
10. **监控全局事务成功率/失败率** — 使用 Seata Dashboard 或 Prometheus

## Data Privacy
本技能不收集、存储或传输任何用户数据。
