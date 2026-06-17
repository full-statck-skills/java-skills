# XXL-Job 实战示例（基于 xxljob-spring-boot-starter）

## 示例 1: @XxlJobCron 自动注册任务

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class CloseOrderJob {
    private final OrderService orderService;

    @XxlJobCron(value = "closeExpiredOrders", cron = "0 0 2 * * ?",
                desc = "关闭24小时未支付订单", author = "system",
                selfStarting = true, failRetryCount = 3, timeout = 30)
    public void execute() {
        try {
            int count = orderService.closeExpiredOrders();
            XxlJobHelper.handleSuccess("关闭了" + count + "笔订单");
        } catch (Exception e) {
            log.error("CloseOrderJob failed", e);
            XxlJobHelper.handleFail(e.getMessage());
        }
    }
}
```

## 示例 2: XxlJobTemplate 编程式管理

```java
@Service
@RequiredArgsConstructor
public class JobBootstrap {
    private final XxlJobTemplate xxlJobTemplate;

    @PostConstruct
    public void ensureJobs() {
        // 幂等创建（描述相同不重复）
        createJob("closeOrders", "0 0 2 * * ?", "关闭过期订单");
        createJob("syncData", "0/30 * * * * ?", "同步数据");
    }

    private void createJob(String handler, String cron, String desc) {
        XxlJobInfo job = new XxlJobInfo();
        job.setJobGroup(1);  // 执行器组ID
        job.setExecutorHandler(handler);
        job.setScheduleConf(cron);
        job.setJobDesc(desc);
        job.setScheduleType("CRON");
        job.setGlueType("BEAN");
        job.setAuthor("system");
        job.setExecutorRouteStrategy("LEAST_FREQUENTLY_USED");
        job.setMisfireStrategy("DO_NOTHING");
        job.setExecutorBlockStrategy("COVER_EARLY");
        job.setExecutorTimeout(30);
        job.setExecutorFailRetryCount(3);
        xxlJobTemplate.addUniqueJob(job);
    }
}
```

## 示例 3: Maven 依赖

```xml
<dependency>
    <groupId>io.github.hiwepy</groupId>
    <artifactId>xxljob-spring-boot-starter</artifactId>
</dependency>
```

---

> 来源：[https://github.com/hiwepy/xxljob-spring-boot-starter](https://github.com/hiwepy/xxljob-spring-boot-starter)
