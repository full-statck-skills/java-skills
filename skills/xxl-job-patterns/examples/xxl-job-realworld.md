# XXL-Job 分布式任务示例

```java
@Component
public class CloseOrderJob {
    @XxlJob("closeExpiredOrders")
    public void execute() {
        int shardIndex = XxlJobHelper.getShardIndex();
        int shardTotal = XxlJobHelper.getShardTotal();
        List<Long> ids = orderService.getExpiredOrderIds(shardIndex, shardTotal);
        ids.forEach(orderService::closeOrder);
        XxlJobHelper.handleSuccess("处理完成: " + ids.size() + " 笔");
    }
}
```

---

> 来源：[https://github.com/xuxueli/xxl-job](https://github.com/xuxueli/xxl-job)
