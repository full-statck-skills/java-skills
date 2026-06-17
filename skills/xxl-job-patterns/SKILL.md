---
name: xxl-job-patterns
description: |
  XXL-JOB 分布式任务调度技能。覆盖调度中心vs执行器架构、GLUE模式vs Bean模式选择、分片广播策略、失败重试与告警配置、任务参数传递、日志查看与清理。
  当用户需要Java分布式定时任务、替代@Scheduled时使用。
license: Apache-2.0
---

# XXL-JOB 分布式任务调度

> 编码 XXL-JOB 的使用规则。LLM 用 @Scheduled 做定时任务(单机/无法管理/无监控)，不知道分布式调度方案。

## Capability Boundaries

### ✅ Strong Suits
1. **架构** — 调度中心(admin)+执行器(executor)
2. **GLUE vs Bean模式** — GLUE(IDE在线编辑) vs Bean(本地代码)
3. **分片广播** — 同一个任务在多台执行器同时运行，用分片参数区分
4. **路由策略** — 第一个/最后一个/轮询/随机/故障转移/分片广播
5. **失败重试** — 重试次数+失败告警邮箱

### ❌ Out of Scope
1. 简单单机定时任务 → @Scheduled 即可
2. 替代方案：PowerJob(功能更强)、ElasticJob(无中心化)

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `@Scheduled(cron="0 0 2 * * ?")` 单机定时 | XXL-JOB 分布式 + 调度中心管理 |
| 2 | 不处理重复执行(手动去重) | 路由策略选"第一个"或"一致性HASH" |
| 3 | 全量处理不分解任务 | 分片广播，每个机器处理一部分 |
| 4 | 失败不告警 | 配置重试次数+报警邮件 |

## 核心规则速查

```java
// ✅ Bean模式(标准方式)
@Component
public class OrderCloseJob {
    @XxlJob("orderCloseJob")  // 任务名称，与调度中心一致
    public void execute() {
        String param = XxlJobHelper.getJobParam();
        int shardIndex = XxlJobHelper.getShardIndex();
        int shardTotal = XxlJobHelper.getShardTotal();
        // 分片处理：每个执行器处理自己的分片
        closeOrders(shardIndex, shardTotal);
        XxlJobHelper.handleSuccess("处理完成");
    }
}

// ✅ 执行器配置
xxl.job.admin.addresses=http://localhost:8080/xxl-job-admin
xxl.job.executor.appname=order-service
xxl.job.executor.port=9999

// ✅ GLUE模式(Python/JS等在线编写，无需重启)
// 在调度中心IDE中直接写：XxlJobHelper.log("开始处理");
```

## Gotchas
1. **任务超时设置** — 防止任务卡死阻塞线程池
2. **阻塞处理策略** — 单机串行/丢弃后续/覆盖之前，按需选择
3. **分片广播时每台机器收到相同的 total 不同的 index** — 用 index 取模分配
4. **GLUE 模式代码在调度中心存储** — 部署执行器时无需发布代码
5. **调度中心和执行器需要时钟同步** — NTP 保证时间一致性
6. **@XxlJob 注解的方法不能有参数** — Spring 管理的 Bean 中可以注入依赖
7. **日志只在调度中心查看** — 执行器本地不持久化日志

## Data Privacy
本技能不收集、存储或传输任何用户数据。
