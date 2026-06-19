---
name: xxl-job-patterns
description: |
  XXL-JOB 最佳实践模式。基于 hiwepy/xxljob-spring-boot-starter 定制封装，覆盖 @XxlJobCron 注解替代原生 @XxlJob(代码即配置/cron写在代码里/启动时自动注册到admin)、XxlJobTemplate 编程式任务管理(CRUD/启停/触发/session自动续期)、执行器自动配置(Unirest SSL/端口兜底/Nacos适配)、Micrometer指标集成、v2/v3双版本兼容。
  纠正 LLM 误用：用 @Scheduled 替代分布式调度、不知道 XxlJobTemplate 的编程式管理、不知道 @XxlJobCron 的 selfStarting 自动注册模式。
license: Apache-2.0
---

# XXL-JOB 最佳实践模式

> 来源：[https://github.com/xuxueli/xxl-job](https://github.com/xuxueli/xxl-job)  
> 基于 [hiwepy/xxljob-spring-boot-starter](https://github.com/hiwepy/xxljob-spring-boot-starter)（Spring Boot Starter 封装）

## Capability Boundaries

### ✅ Strong Suits
1. **@XxlJobCron 注解** — 100%替代@XxlJob，代码即配置（cron/desc/author/selfStarting 全部在代码中）
2. **启动自动注册** — selfStarting=true 时，执行器启动自动将任务注册到Admin（无需手动在UI创建）
3. **XxlJobTemplate** — 编程式管理任务（添加/更新/删除/启动/停止/触发），session自动续期
4. **v2/v3双版本兼容** — Admin版本参数差异(v3用ids[]、v2用id)，自动适配
5. **Micrometer指标** — 自动采集任务执行次数/成功/失败/耗时，对接Prometheus
6. **Unirest HTTP客户端** — 自动配置SSL（trust-all）/Cookie管理/超时

### ❌ Out of Scope
1. 简单单机定时任务 → @Scheduled
2. 替代方案：PowerJob(功能更强)、ElasticJob(无中心化)

## 核心模式

### 模式 1: @XxlJobCron — 代码即配置（推荐）

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class CompensationJobHandler {
    private final AigcTaskCompensationScheduler compensationScheduler;

    // ✅ 一行注解 = @XxlJob + cron + desc + author + selfStarting(自动注册到Admin)
    @XxlJobCron(value = "compensateStaleTextTasks",
                cron = "0/30 * * * * ?",
                desc = "文本回调超时补偿",
                author = "wandl",
                selfStarting = true,   // ← 启动时自动注册，无需在Admin UI手动创建
                failRetryCount = 3,
                timeout = 30)  // 30秒超时
    public void compensateStaleTextTasks() {
        try {
            compensationScheduler.compensateStaleTextTasks();
            XxlJobHelper.handleSuccess("compensation completed");
        } catch (Exception e) {
            log.error("XXL-Job failed", e);
            XxlJobHelper.handleFail("failed: " + e.getMessage());
        }
    }
}
```

### 模式 2: XxlJobTemplate — 编程式任务管理

```java
@Service
public class JobManager {
    @Autowired XxlJobTemplate xxlJobTemplate;

    // 创建/更新任务(幂等)
    public void ensureJobRegistered(Long jobGroupId, String handlerName, String cron, String desc) {
        XxlJobInfo jobInfo = new XxlJobInfo();
        jobInfo.setJobGroup(jobGroupId.intValue());
        jobInfo.setExecutorHandler(handlerName);
        jobInfo.setScheduleConf(cron);
        jobInfo.setJobDesc(desc);
        jobInfo.setScheduleType("CRON");
        jobInfo.setGlueType("BEAN");
        jobInfo.setAuthor("system");
        jobInfo.setExecutorRouteStrategy("LEAST_FREQUENTLY_USED");
        jobInfo.setMisfireStrategy("DO_NOTHING");
        jobInfo.setExecutorBlockStrategy("COVER_EARLY");
        jobInfo.setExecutorTimeout(30);
        jobInfo.setExecutorFailRetryCount(3);
        xxlJobTemplate.addUniqueJob(jobInfo);  // 幂等：描述相同不重复创建
    }

    // 手动触发
    public void triggerJob(Integer jobId, String param) {
        xxlJobTemplate.triggerJob(jobId, param);
    }

    // 暂停/恢复
    public void pauseJob(Integer jobId) { xxlJobTemplate.stopJob(jobId); }
    public void resumeJob(Integer jobId) { xxlJobTemplate.startJob(jobId); }
}
```

### 模式 3: 配置结构

```yaml
xxl:
  job:
    accessToken: xxx                      # 通信Token
    admin:
      version: V3_X                       # Admin版本（V2_X / V3_X）
      addresses: http://xxx:9991/xxl-job-admin
      username: admin
      password: xxxxx                     # Admin登录密码
      cookie:                             # Session管理
        maximum-size: 1000
        expire-after-write: 5s
    executor:
      enabled: true
      appname: agent-job-executor         # 执行器名称（与Admin注册一致）
      title: 智能体 - 任务执行器            # 执行器显示名称
      ip: 172.16.0.152                    # 执行器IP（多网卡时指定）
      port: 0                             # 0=自动探测，-1=不启动
      log-path: /logs/xxl-job/jobhandler
      log-retention-days: 30
```

### 模式 4: SLF4J + RequiredArgsConstructor 依赖注入

```java
// ✅ DDD4J 风格：Lombok + 构造器注入
@Slf4j
@Component
@RequiredArgsConstructor  // final字段自动构造器注入
public class MyJobHandler {
    private final OrderService orderService;        // 构造器注入
    private final NotificationService notifyService;

    @XxlJobCron(value = "closeExpiredOrders", cron = "0 0 2 * * ?",
                desc = "关闭过期订单", author = "system", selfStarting = true)
    public void execute() { ... }
}
```

### 模式 5: 错误处理统一模式

```java
@XxlJobCron(...)
public void execute() {
    try {
        // 业务逻辑
        doWork();
        XxlJobHelper.handleSuccess("处理完成");  // ← 显式标记成功
    } catch (Exception e) {
        log.error("XXL-Job {} failed", getJobName(), e);
        XxlJobHelper.handleFail("失败: " + e.getMessage());  // ← 显式标记失败
    }
}
```

## Gotchas
1. **@XxlJobCron(selfStarting=true) 自动注册** — 启动时自动同步到Admin，无需手动在UI创建
2. **Admin版本参数差异** — v2用`id`，v3用`ids[]`，Starter自动适配
3. **执行器端口设为0自动探测** — 避免端口冲突，-1不启动执行器
4. **多网卡指定ip** — 云环境多网卡必须指定`xxl.job.executor.ip`
5. **session自动续期** — XxlJobTemplate检测session过期自动重新登录
6. **XxlJobHelper.handleFail显式标记** — 不调用默认视为成功
7. **@RequiredArgsConstructor注入** — 用final字段+构造器注入，不用@Autowired字段注入
8. **@XxlJobCron 与 MetricMethodJobHandler 冲突** — XXL-JOB 自带的 `MetricMethodJobHandler` 通过反射读取 `@XxlJob.value()`，但 `@XxlJobCron` 不包含原生 `@XxlJob` 注解，导致 `NullPointerException: Cannot invoke "com.xxl.job.core.handler.annotation.XxlJob.value()" because "job" is null`。解决方案：① 禁用 Micrometer 指标（`xxl.job.metrics.enabled=false`） ② 同时在方法上添加空的 `@XxlJob` 注解解决反射问题 ③ 升级 hiwepy starter 版本看是否已修复

## Data Privacy
本技能不收集、存储或传输任何用户数据。
