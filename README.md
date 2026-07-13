<div align="center">

# java-skills

**Java development best practices and coding conventions**

[![GitHub](https://img.shields.io/badge/github-full--stack--skills%2Fjava-skills-green.svg)](https://github.com/full-stack-skills/java-skills)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-purple.svg)](https://agentskills.io)

English | [简体中文](./README.zh-CN.md)

[Introduction](#-introduction) ·
[Install](#-install) ·
[Skills](#-skills) ·
[Supported Agents](#-supported-agents) ·
[Ecosystem](#-ecosystem)

</div>

---

## 📖 Introduction

**Java Skills** is a curated collection of Agent Skills for AI coding agents, part of the [Full Stack Skills](https://github.com/partme-ai/full-stack-skills) ecosystem maintained by [PartMe.AI](https://github.com/partme-ai).

This package includes **31 skills**. Each skill is a self-contained `SKILL.md` file that AI agents load on-demand.

## 📦 Install

```bash
npx skills add full-stack-skills/java-skills
```

Or install specific skills:

```bash
npx skills add full-stack-skills/java-skills --skill <skill-name>
```

## 🎯 Skills (31)

| Skill | Description |
|-------|-------------|
| `java-code-comments` | Java code commenting conventions and best practices |
| `java-conventions` | 统一 Java 项目编码规范与注释规范（SLF4J+Lombok 日志、Bean Lombok 注解选择、判空 Objects/Optional、工具类优先级 Spring→Apache Commons→Hutool→Guava、复杂... |
| `java-development-manual` | Java development manual and guidelines |
| `unirest-java-3` | Unirest 3.x HTTP client for Java 8+ with Apache HttpClient, built-in GSON, per-request proxy, mocking, caching, and connection pool tuning |
| `unirest-java-4` | Unirest 4.x HTTP client for Java 11+ with java.net.http, SSE, WebSocket, HTTP/2, ProxySelector, mocking, caching, and modular JSON support |
| `okhttp3-5.x` | OkHttp 5.x HTTP client for Java/JVM 8+ and Android 5+ with HTTP/2, transparent GZIP, Fast Fallback, MockWebServer, and GraalVM Native Image support |
| `sa-token` | Sa-Token core authentication framework — login, permission/role auth, annotation auth, route interceptor, session management, token configuration, front-back separation |
| `sa-token-advanced` | Sa-Token advanced security — secondary auth (2FA), account banning (full/category/tiered), identity switching, multi-account systems, global listener & filter, password encryption, HTTP Basic/Digest |
| `sa-token-sso` | Sa-Token SSO single sign-on — 3 modes (same-domain cookie, cross-domain redirect, cross-domain HTTP ticket), SSO-Server setup, SSO-Client integration, single logout |
| `sa-token-oauth2` | Sa-Token OAuth2.0 server — 4 grant types (authorization code, implicit, password, client credentials), Scope control, OIDC support, custom grant_type |
| `sa-token-micro` | Sa-Token microservice auth — Same-Token inter-service isolation, SpringCloud Gateway unified auth, Feign/Dubbo/gRPC RPC auth, distributed session |
| `sa-token-api-security` | Sa-Token API security — API parameter signing (anti-tamper/anti-replay), API Key managed partial authorization, temporary token (short-lived links) |
| `sa-token-integration` | Sa-Token integration extensions — JWT (Simple/Mixin/Stateless), Redis persistence, Alone-Redis isolation, AOP annotation auth, Quick-Login, template engine integration |
| `easyexcel-fill` | Alibaba EasyExcel 4.x template filling — simple object / list / complex / horizontal multi-column composite filling, Spring Boot integration, template design specs, escape chars, 03/07 version differences |
| `easyexcel-write` | Alibaba EasyExcel 4.x programmatic Excel generation — 3 minimal-write APIs, complex multi-row headers, `@ExcelProperty`/`@ExcelIgnore`/`@DateTimeFormat`/`@NumberFormat` annotations, include/exclude columns, `@ColumnWidth`/`@ContentRowHeight` style annotations, `@HeadStyle`/`@ContentStyle` custom styles, merged cells, image export, hyperlinks/comments/formulas/rich-text, dynamic headers, auto column width, custom `WriteHandler`s, paged batch write, Web `OutputStream` direct download, 03/07 version compatibility |
| `easyexcel-read` | Alibaba EasyExcel 4.x Excel data reading — listener pattern (`ReadListener` / `AnalysisEventListener` / `PageReadListener`), synchronous `doReadSync`, multi-Sheet reading, `@ExcelProperty(index/name)` matching, multi-row headers (`headRowNumber`), date/number/custom converters, listener exception handling (`onException` + `ExcelDataConvertException`), extra info reading (comment/hyperlink/merge via `extraRead` + `CellExtra`), formula and cell type (`CellData<T>`), model-less reading (`ReadListener<Map<Integer,String>>`), Web upload reading (`MultipartFile`→`InputStream`) |
| `guava-patterns` | Guava best-practice patterns distilled from official docs — collections (`ImmutableList`/`Multimap`/`Table`), caching (`CacheBuilder` with TTL + LRU), functional (`Function`/`Predicate` cache), primitives (`IntList`/`LongList`), I/O utilities (`ByteStreams`/`CharStreams`), graph (`CommonGraph`), concurrency (`ListenableFuture`) |
| `hutool-patterns` | Hutool best-practice patterns from official wiki — `DateUtil`/`DatePattern` date handling, `StrUtil` string utilities, `CollUtil`/`ListUtil` collection extensions, `SecureUtil` crypto, `HttpUtil` HTTP client, `CaptchaUtil` captcha, `Console` interactive prompts, Spring Boot integration |
| `lombok-patterns` | Lombok best-practice patterns from official docs — `@Data`/`@Builder`/`@Value` POJO, `@Slf4j`/`@Log4j2` logger, `@NonNull`/`@Cleanup` safety, `@SneakyThrows`/`@UtilityClass` advanced, `@Accessors` chainable setters, `@AllArgsConstructor`/`@RequiredArgsConstructor` injection, `@Delegate`/`@ExtensionMethod` composition |
| `mapstruct-patterns` | MapStruct best-practice patterns from official reference — DTO↔Entity mapping, `@Mapping`/`@Mappings` field mapping, expression & qualified-by-name mapping, nested object & collection mapping, type conversion & format (`dateFormat`/`numberFormat`), Spring component-model integration, custom mapper |
| `junit-mockito-patterns` | JUnit 5 + Mockito best-practice patterns — `@Test`/`@ParameterizedTest`/`@Nested` test methods, `@BeforeEach`/`@BeforeAll` lifecycle, `@MockitoBean`/`@Mock`/`@Spy` mocks, `Mockito.when()`/`verify()`/`ArgumentCaptor`, `given()/willReturn()` BDD style, `@WebMvcTest` slice testing, Spring Boot test integration |
| `jackson-patterns` | Jackson best-practice patterns from official wiki — `@JsonInclude`/`@JsonIgnore`/`@JsonProperty` property control, `@JsonFormat`/`@JsonSerialize`/`@JsonDeserialize` custom formatting, `@JsonTypeInfo` polymorphic types, `ObjectMapper`/`JsonNode` tree model, `@JsonComponent` Spring auto-registration, streaming `JsonParser`/`JsonGenerator` |
| `mybatis-patterns` | MyBatis best-practice patterns from official docs — XML mapper & dynamic SQL (`<if>`/`<foreach>`/`<choose>`), resultMap & association/collection, `@Select`/`@Insert`/`@Update` annotations, `@Param`/`@ResultMap`, plugins (pagination interceptor), Spring Boot integration |
| `mybatis-plus-patterns` | MyBatis-Plus best-practice patterns from official docs — `BaseMapper`/`IService` generic CRUD, `@TableName`/`@TableId`/`@TableField` annotations, `Wrapper` (`QueryWrapper`/`LambdaQueryWrapper`) chain query, pagination `Page<T>`/`PageHelper`, active-record mode, multi-tenant plugin, code generator |
| `redis-redisson-patterns` | Redis & Redisson best-practice patterns — Lettuce/Jedis client, `RedisTemplate`/`StringRedisTemplate`, `RedisSerializer` (JSON/Protobuf), pipeline & transaction, `RBucket`/`RMap`/`RList`/`RQueue`/`RTopic` Redisson distributed objects, `RLock`/`RSemaphore` distributed lock & semaphore, Spring Cache `@Cacheable`/`@CacheEvict`, Spring Boot integration |
| `kafka-patterns` | Kafka best-practice patterns — `KafkaTemplate` send/receive, `@KafkaListener` annotation consumer, `ConsumerFactory`/`ProducerFactory`, JSON/Avro/Protobuf serializers, manual offset commit, error handling & retry, Spring Boot integration, Kafka Streams basics |
| `xxl-job-patterns` | XXL-Job best-practice patterns from official docs — `@XxlJob` annotation, `GlueJobHandler`/`BeanMethodJobHandler`, executor/route strategy, `BlockingQueue`/`log` & email failure alarm, parallel sharding, Spring Boot integration, dashboard operation |
| `seata-patterns` | Seata distributed transaction patterns from official docs — `GlobalTransactional`/`@Transactional` AT mode, TCC mode (`@TwoPhaseBusinessAction`), Saga mode compensation, XA mode, lock & isolation, Spring Boot & Spring Cloud Alibaba integration, file/DB/nacos config center |
| `caffeine-patterns` | Caffeine best-practice patterns from official wiki — `Cache`/`LoadingCache`/`AsyncCache`, TTL/expiryAfterWrite/expiryAfterAccess, maximumSize & weakKeys, refreshAfterWrite, statistics & removalListener, Spring Boot integration, multi-level cache |
| `commons-patterns` | Apache Commons best-practice patterns from official docs — `StringUtils`/`StringEscapeUtils`, `CollectionUtils`/`ListUtils`/`MapUtils`, `FileUpload`/`FileUtils`/`IOUtils`, `Lang3` (`RandomStringUtils`/`NumberUtils`), `BeanUtils`/`PropertyUtils`, `HttpClient`/`HttpUtils` |

## 🤖 Supported Agents

Works with [Claude Code](https://code.claude.com), [Codex](https://developers.openai.com/codex), [Cursor](https://cursor.com), [OpenCode](https://opencode.ai), [Gemini CLI](https://geminicli.com), [GitHub Copilot](https://github.com/features/copilot), [Windsurf](https://codeium.com/windsurf), and [70+ others](https://agentskills.io/clients).

### Claude Code Installation

**Option 1: npx skills CLI (Recommended)**

```bash
npx skills add full-stack-skills/java-skills
```

**Option 2: Manual Installation**

```bash
git clone https://github.com/full-stack-skills/java-skills.git
cp -r java-skills/skills/* .claude/skills/
```

For more details, see the [Claude Code Skills Guide](https://code.claude.com/docs/en/skills) and [Agent Skills Spec](https://agentskills.io/).

## 🌐 Ecosystem

| Resource | Link |
|----------|------|
| **Full Stack Skills** | [github.com/partme-ai/full-stack-skills](https://github.com/partme-ai/full-stack-skills) |
| **All Skill Groups** | [github.com/full-stack-skills](https://github.com/full-stack-skills) |
| **Agent Skills Spec** | [agentskills.io](https://agentskills.io) |
| **Skills CLI** | [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) |

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE).
