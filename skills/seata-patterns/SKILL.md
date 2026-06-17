---
name: seata-patterns
description: |
  Seata 分布式事务技能。覆盖 AT/TCC/SAGA 模式选择决策、undo_log表设计、全局事务超时配置、与Spring Cloud集成、事务回滚处理。
  当用户需要分布式事务、跨服务数据一致性时使用。
license: Apache-2.0
---

# Seata 分布式事务

> 编码 Seata 的使用规则。LLM 不知道 AT/TCC/SAGA 选哪个，不建 undo_log 表。

## Capability Boundaries

### ✅ Strong Suits
1. **AT模式(推荐起始)** — 基于数据源代理，零侵入
2. **TCC模式** — 自定义Try/Confirm/Cancel，性能更好
3. **SAGA模式** — 长流程事务(>10s)，最终一致性
4. **undo_log表** — AT模式必须建立
5. **@GlobalTransactional** — 全局事务入口

### ❌ Out of Scope
1. 单数据库事务 → Spring @Transactional
2. 最终一致性(不要求强一致) → Kafka/RocketMQ 事务消息

## 三模式选择决策

```
分布式事务选型：
├── 改数据库(Insert/Update/Delete) + 要求自动回滚 → AT模式(推荐)
├── 读写分离 + 性能敏感 + 愿意写Confirm/Cancel → TCC模式
└── 流程长(>10秒) + 允许中间状态 → SAGA模式
```

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 不知道 AT 模式需要 undo_log 表 | 每个业务数据库建 `undo_log` 表 |
| 2 | AT 模式用非 ACID 数据库 | AT 依赖本地事务，必须 ACID 数据库 |
| 3 | 全局事务超时不设置 | 配置 `global.tx.timeout` |
| 4 | TCC 模式 Confirm 失败不处理 | Confirm 必须幂等，Cancel 必须空回滚处理 |

## 核心规则速查

```sql
-- ✅ AT 模式必须建 undo_log 表
CREATE TABLE undo_log (
    id BIGINT NOT NULL AUTO_INCREMENT,
    branch_id BIGINT NOT NULL,
    xid VARCHAR(128) NOT NULL,
    rollback_info LONGBLOB NOT NULL,
    log_status INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY ux_undo_log (xid, branch_id)
);
```

```java
// ✅ AT 模式(零业务侵入)
@GlobalTransactional(timeoutMills = 300000)  // 5分钟超时
public void createOrder(OrderDTO dto) {
    orderService.create(dto);           // 远程服务A
    inventoryService.deduct(dto);       // 远程服务B
    accountService.debit(dto);         // 远程服务C
    // 任一失败→全部回滚(AT模式自动)
}

// ✅ TCC 模式(需要实现Confirm/Cancel)
@LocalTCC
public interface OrderTccAction {
    @TwoPhaseBusinessAction(name = "orderTcc", commitMethod = "confirm", rollbackMethod = "cancel")
    boolean prepare(@BusinessActionContextParameter(paramName = "orderId") Long id);

    boolean confirm(BusinessActionContext ctx);
    boolean cancel(BusinessActionContext ctx);
}
```

## Gotchas
1. **AT 模式不支持非 ACID 数据库** — MySQL/PostgreSQL/Oracle 可，Redis/Mongo 不可
2. **undo_log 表必须和业务表在同一数据库** — 不同库回滚不了
3. **TCC 的 Confirm 必须是幂等的** — 可重复执行不改变结果
4. **Cancel 必须处理空回滚** — 事务已提交后收到 Cancel 请求
5. **SAGA 模式没有自动回滚** — 需手动写补偿逻辑
6. **全局锁可能导致死锁** — 设置合理的超时时间

## Data Privacy
本技能不收集、存储或传输任何用户数据。
