<div align="center">

# java-skills

**Java development best practices and coding conventions**

[![GitHub](https://img.shields.io/badge/github-full--stack--skills%2Fjava-skills-green.svg)](https://github.com/full-stack-skills/java-skills)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-兼容-purple.svg)](https://agentskills.io)

[English](./README.md) | 简体中文

[简介](#-简介) ·
[安装](#-安装) ·
[技能列表](#-技能列表) ·
[支持的智能体](#-支持的智能体) ·
[生态](#-生态)

</div>

---

## 📖 简介

**Java 技能** 是一组 AI 编码智能体技能，属于 [Full Stack Skills](https://github.com/partme-ai/full-stack-skills) 生态，由 [PartMe.AI](https://github.com/partme-ai) 维护。

本包包含 **31 个技能**。每个技能是一个独立的 `SKILL.md` 文件，AI 智能体按需加载。

## 📦 安装

```bash
npx skills add full-stack-skills/java-skills
```

或按需安装特定技能：

```bash
npx skills add full-stack-skills/java-skills --skill <skill-name>
```

## 🎯 技能列表 (31)

| 技能 | 描述 |
|------|------|
| `java-code-comments` | Java 代码注释规范与最佳实践 |
| `java-conventions` | 统一 Java 项目编码规范与注释规范（SLF4J+Lombok 日志、Bean Lombok 注解选择、判空 Objects/Optional、工具类优先级 Spring→Apache Commons→Hutool→Guava、复杂... |
| `java-development-manual` | Java 开发手册与指南 |
| `unirest-java-3` | Unirest 3.x HTTP 客户端，基于 Apache HttpClient，支持 Java 8+，内置 GSON，支持每请求代理、Mock 测试、缓存和连接池调优 |
| `unirest-java-4` | Unirest 4.x HTTP 客户端，基于 java.net.http，支持 Java 11+，SSE、WebSocket、HTTP/2、ProxySelector、Mock 测试、缓存和模块化 JSON 支持 |
| `okhttp3-5.x` | OkHttp 5.x HTTP 客户端，支持 Java/JVM 8+ 和 Android 5+，HTTP/2、透明 GZIP、Fast Fallback、MockWebServer、GraalVM Native Image 支持 |
| `sa-token` | Sa-Token 核心权限认证框架 — 登录认证、权限/角色认证、注解鉴权、路由拦截鉴权、Session 会话管理、框架配置、前后端分离 |
| `sa-token-advanced` | Sa-Token 高级安全特性 — 二级认证、账号封禁(全/分类/阶梯)、身份切换、多账号体系(StpUserUtil/StpKit)、全局侦听器与过滤器、密码加密、Http Basic/Digest |
| `sa-token-sso` | Sa-Token SSO 单点登录 — 三种模式(同域Cookie/跨域重定向/跨域Http ticket)、Server 搭建、Client 接入、单点注销、前后端分离 H5 方案 |
| `sa-token-oauth2` | Sa-Token OAuth2.0 服务端 — 四种授权模式(授权码/隐式/密码/客户端凭证)、Scope 权限控制、OIDC、自定义 grant_type |
| `sa-token-micro` | Sa-Token 微服务鉴权 — Same-Token 内部服务隔离、SpringCloud Gateway 统一鉴权、Feign/Dubbo/gRPC 鉴权、分布式 Session |
| `sa-token-api-security` | Sa-Token API 安全 — API 参数签名(防篡改防重放)、API Key 部分授权管理、临时 Token 短效链接 |
| `sa-token-integration` | Sa-Token 集成扩展 — JWT 三种模式(Simple/Mixin/Stateless)、Redis 持久化、Alone-Redis 缓存隔离、AOP 注解鉴权、Quick-Login 快速登录、模板引擎集成 |
| `easyexcel-fill` | Alibaba EasyExcel 4.x 模板填充 — 简单对象 / 列表 / 复杂 / 横向多列组合填充、Spring Boot 集成、模板设计规范、转义字符、03/07 版差异 |
| `easyexcel-write` | Alibaba EasyExcel 4.x 程序化生成 Excel — 3 种最简写入 API、复杂多级表头、`@ExcelProperty` / `@ExcelIgnore` / `@DateTimeFormat` / `@NumberFormat` 注解、include/exclude 选择列、`@ColumnWidth` / `@ContentRowHeight` 样式注解、`@HeadStyle` / `@ContentStyle` 自定义样式、合并单元格、图片导出、超链接/批注/公式/富文本、动态表头、自动列宽、自定义 `WriteHandler`、分页分批写入、Web `OutputStream` 直接下载、03/07 版兼容 |
| `easyexcel-read` | Alibaba EasyExcel 4.x Excel 数据读取 — 监听器模式(`ReadListener` / `AnalysisEventListener` / `PageReadListener`)、同步 `doReadSync`、多 Sheet 读取、`@ExcelProperty(index/name)` 匹配、多行表头(`headRowNumber`)、日期/数字/自定义转换器、监听器异常处理(`onException` + `ExcelDataConvertException`)、额外信息读取(批注/超链接/合并, `extraRead` + `CellExtra`)、公式和单元格类型(`CellData<T>`)、不创建对象的读(`ReadListener<Map<Integer,String>>`)、Web 上传读取(`MultipartFile`→`InputStream`) |
| `guava-patterns` | Guava 最佳实践模式 — 集合(`ImmutableList` / `Multimap` / `Table`)、缓存(`CacheBuilder` TTL + LRU)、函数式(`Function` / `Predicate` 缓存)、原生类型(`IntList` / `LongList`)、I/O 工具(`ByteStreams` / `CharStreams`)、图算法(`CommonGraph`)、并发(`ListenableFuture`) |
| `hutool-patterns` | Hutool 最佳实践模式 — `DateUtil` / `DatePattern` 日期处理、`StrUtil` 字符串工具、`CollUtil` / `ListUtil` 集合扩展、`SecureUtil` 加密、`HttpUtil` HTTP 客户端、`CaptchaUtil` 图形验证码、`Console` 交互式提示、Spring Boot 集成 |
| `lombok-patterns` | Lombok 最佳实践模式 — `@Data` / `@Builder` / `@Value` POJO、`@Slf4j` / `@Log4j2` 日志、`@NonNull` / `@Cleanup` 安全、`@SneakyThrows` / `@UtilityClass` 高级、`@Accessors` 链式 setter、`@AllArgsConstructor` / `@RequiredArgsConstructor` 注入、`@Delegate` / `@ExtensionMethod` 组合 |
| `mapstruct-patterns` | MapStruct 最佳实践模式 — DTO↔Entity 映射、`@Mapping` / `@Mappings` 字段映射、表达式与 qualified-by-name 映射、嵌套对象与集合映射、类型转换与格式(`dateFormat` / `numberFormat`)、Spring component-model 集成、自定义 mapper |
| `junit-mockito-patterns` | JUnit 5 + Mockito 最佳实践模式 — `@Test` / `@ParameterizedTest` / `@Nested` 测试方法、`@BeforeEach` / `@BeforeAll` 生命周期、`@MockitoBean` / `@Mock` / `@Spy` mock、`Mockito.when()` / `verify()` / `ArgumentCaptor`、`given()/willReturn()` BDD 风格、`@WebMvcTest` 切片测试、Spring Boot 测试集成 |
| `jackson-patterns` | Jackson 最佳实践模式 — `@JsonInclude` / `@JsonIgnore` / `@JsonProperty` 属性控制、`@JsonFormat` / `@JsonSerialize` / `@JsonDeserialize` 自定义格式、`@JsonTypeInfo` 多态类型、`ObjectMapper` / `JsonNode` 树模型、`@JsonComponent` Spring 自动注册、流式 `JsonParser` / `JsonGenerator` |
| `mybatis-patterns` | MyBatis 最佳实践模式 — XML mapper 与动态 SQL(`<if>` / `<foreach>` / `<choose>`)、resultMap 与 association/collection、`@Select` / `@Insert` / `@Update` 注解、`@Param` / `@ResultMap`、插件(分页拦截器)、Spring Boot 集成 |
| `mybatis-plus-patterns` | MyBatis-Plus 最佳实践模式 — `BaseMapper` / `IService` 通用 CRUD、`@TableName` / `@TableId` / `@TableField` 注解、`Wrapper`(`QueryWrapper` / `LambdaQueryWrapper`)链式查询、分页 `Page<T>` / `PageHelper`、active-record 模式、多租户插件、代码生成器 |
| `redis-redisson-patterns` | Redis 与 Redisson 最佳实践模式 — Lettuce/Jedis 客户端、`RedisTemplate` / `StringRedisTemplate`、`RedisSerializer`(JSON/Protobuf)、pipeline 与事务、`RBucket` / `RMap` / `RList` / `RQueue` / `RTopic` Redisson 分布式对象、`RLock` / `RSemaphore` 分布式锁与信号量、Spring Cache `@Cacheable` / `@CacheEvict`、Spring Boot 集成 |
| `kafka-patterns` | Kafka 最佳实践模式 — `KafkaTemplate` 发送与接收、`@KafkaListener` 注解消费者、`ConsumerFactory` / `ProducerFactory`、JSON/Avro/Protobuf 序列化、手动 offset 提交、错误处理与重试、Spring Boot 集成、Kafka Streams 基础 |
| `xxl-job-patterns` | XXL-Job 最佳实践模式 — `@XxlJob` 注解、`GlueJobHandler` / `BeanMethodJobHandler`、执行器/路由策略、`BlockingQueue` / 日志邮件失败告警、并行分片、Spring Boot 集成、任务调度 Dashboard |
| `seata-patterns` | Seata 分布式事务模式 — `GlobalTransactional` / `@Transactional` AT 模式、TCC 模式(`@TwoPhaseBusinessAction`)、Saga 模式补偿、XA 模式、锁与隔离、Spring Boot 与 Spring Cloud Alibaba 集成、file/db/nacos 配置中心 |
| `caffeine-patterns` | Caffeine 最佳实践模式 — `Cache` / `LoadingCache` / `AsyncCache`、TTL/expiryAfterWrite/expiryAfterAccess、maximumSize 与 weakKeys、refreshAfterWrite、统计与 removalListener、Spring Boot 集成、多级缓存 |
| `commons-patterns` | Apache Commons 最佳实践模式 — `StringUtils` / `StringEscapeUtils`、`CollectionUtils` / `ListUtils` / `MapUtils`、`FileUpload` / `FileUtils` / `IOUtils`、`Lang3`(`RandomStringUtils` / `NumberUtils`)、`BeanUtils` / `PropertyUtils`、`HttpClient` / `HttpUtils` |

## 🤖 支持的智能体

适用于 [Claude Code](https://code.claude.com)、[Codex](https://developers.openai.com/codex)、[Cursor](https://cursor.com)、[OpenCode](https://opencode.ai)、[Gemini CLI](https://geminicli.com)、[GitHub Copilot](https://github.com/features/copilot)、[Windsurf](https://codeium.com/windsurf) 及 [70+ 其他平台](https://agentskills.io/clients)。

### Claude Code 安装

**方式一：npx skills CLI（推荐）**

```bash
npx skills add full-stack-skills/java-skills
```

**方式二：手动安装**

```bash
git clone https://github.com/full-stack-skills/java-skills.git
cp -r java-skills/skills/* .claude/skills/
```

更多详情请参阅 [Claude Code 技能指南](https://code.claude.com/docs/en/skills) 和 [Agent Skills 规范](https://agentskills.io/)。

## 🌐 生态

| 资源 | 链接 |
|------|------|
| **Full Stack Skills** | [github.com/partme-ai/full-stack-skills](https://github.com/partme-ai/full-stack-skills) |
| **全部技能组** | [github.com/full-stack-skills](https://github.com/full-stack-skills) |
| **Agent Skills 规范** | [agentskills.io](https://agentskills.io) |
| **Skills CLI** | [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) |

## 📄 许可证

Apache 2.0 — 详见 [LICENSE](LICENSE)。
