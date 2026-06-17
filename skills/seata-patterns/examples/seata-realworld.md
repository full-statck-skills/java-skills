# Seata AT 模式示例

```java
@GlobalTransactional(timeoutMills = 300000)
public void createOrder(OrderDTO dto) {
    orderService.create(dto);        // 本地
    inventoryService.deduct(dto);    // 远程
    accountService.debit(dto);       // 远程
    // 任一失败→全部回滚
}
// 前提：每个业务库建 undo_log 表
```

---

> 来源：[https://seata.io/](https://seata.io/)
