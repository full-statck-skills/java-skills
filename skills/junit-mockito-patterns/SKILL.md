---
name: junit-mockito-patterns
description: |
  JUnit5 + Mockito 测试框架技能。覆盖 JUnit5 @ExtendWith替代@RunWith、Mockito @Mock/@InjectMocks规则、测试隔离原则(FIRST)、@SpringBootTest何时用何时不用(@WebMvcTest/@DataJpaTest切片测试)、BDDMockito given/willReturn风格、ArgumentCaptor参数捕获、verify行为验证、@ParameterizedTest参数化测试。
  当用户编写 Java 单元测试/集成测试、Mock外部依赖时需要此技能。
license: Apache-2.0
---

# JUnit5 + Mockito 测试规则

> 来源：[https://junit.org/junit5/docs/current/user-guide/](https://junit.org/junit5/docs/current/user-guide/)  
> Mockito：[https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)

## Capability Boundaries

### ✅ Strong Suits
1. **JUnit5 迁移规则** — @ExtendWith 替代 @RunWith, @Test 导入 org.junit.jupiter.api
2. **Mockito 规则** — @Mock(外部依赖) + @InjectMocks(被测试对象), 不 Mock POJO
3. **测试隔离(FIRST原则)** — Fast/Independent/Repeatable/Self-Validating/Timely
4. **切片测试** — @WebMvcTest(Controller) / @DataJpaTest(Repository) / @JsonTest
5. **BDD风格** — BDDMockito.given()/willReturn()/then().should() 替代 when/thenReturn/verify
6. **行为验证** — verify() + ArgumentCaptor
7. **@ParameterizedTest + @MethodSource** — 参数化测试简化多场景
8. **@Nested 分组** — 组织相关测试场景

### ❌ Out of Scope
1. 集成测试/端到端测试 → **Playwright**/**Selenium**（已有技能）
2. 性能测试 → **JMH**（Java Microbenchmark Harness）

## JUnit4 → JUnit5 迁移对照

| JUnit4 | JUnit5 | 说明 |
|--------|--------|------|
| `@RunWith(SpringRunner.class)` | `@ExtendWith(SpringExtension.class)` | 扩展机制 |
| `@RunWith(MockitoJUnitRunner.class)` | `@ExtendWith(MockitoExtension.class)` | Mockito扩展 |
| `@Test(expected = Exception.class)` | `assertThrows(Exception.class, () -> {...})` | 异常断言 |
| `@Before` | `@BeforeEach` | 每个测试前执行 |
| `@After` | `@AfterEach` | 每个测试后执行 |
| `@BeforeClass` | `@BeforeAll` | 所有测试前(static) |
| `@AfterClass` | `@AfterAll` | 所有测试后(static) |
| `@Ignore` | `@Disabled` | 禁用测试 |
| `@FixMethodOrder` | `@TestMethodOrder(MethodName)` | 测试顺序 |

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `import org.junit.Test` (JUnit4) | `import org.junit.jupiter.api.Test` (JUnit5) |
| 2 | `@RunWith(MockitoJUnitRunner.class)` | `@ExtendWith(MockitoExtension.class)` |
| 3 | 测试 Service 用 @SpringBootTest 启动整个上下文 | 用 `@ExtendWith(MockitoExtension.class)` 纯 Mockito |
| 4 | Controller 测试启动整个应用 | @WebMvcTest + @MockBean 只加载 Controller 层 |
| 5 | Mock 值对象(POJO/DTO) | 只 Mock 外部依赖(DB/HTTP/MQ)，POJO 直接 new |
| 6 | `verify(mock, never())` 不写 `times(0)` | `verify(mock, never()).method()` 或 `verify(mock, times(0)).method()` |
| 7 | 每个测试方法都 `initMocks(this)` | @ExtendWith 自动初始化 |
| 8 | 用 `when().thenReturn()` (非BDD) | BDD 风格: `given().willReturn()` |
| 9 | @SpringBootTest 做单元测试(慢，3s+) | 切片测试 < 200ms |
| 10 | 不写 `@DisplayName` | 测试方法中文描述，方便定位 |

## 核心规则速查

### 纯单元测试（推荐）
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("用户服务测试")
class UserServiceTest {
    @Mock UserRepository userRepo;     // 外部依赖
    @Mock CacheManager cacheManager;
    @InjectMocks UserService userService; // 被测试对象(构造器注入)

    @Test
    @DisplayName("查询用户-缓存命中-直接返回")
    void getUser_CacheHit_ReturnFromCache() {
        // given(BDD风格)
        User cached = new User(1L, "zhang");
        given(cacheManager.get("user:1")).willReturn(cached);
        // when
        User result = userService.getUser(1L);
        // then
        assertThat(result.getName()).isEqualTo("zhang");
        then(userRepo).should(never()).findById(anyLong());  // BDD验证
    }

    @Test
    @DisplayName("查询用户-未命中-查DB并缓存")
    void getUser_CacheMiss_QueryDBAndCache() {
        // given
        given(cacheManager.get("user:1")).willReturn(null);
        given(userRepo.findById(1L)).willReturn(Optional.of(new User(1L, "zhang")));
        // when
        User result = userService.getUser(1L);
        // then
        assertThat(result).isNotNull();
        then(cacheManager).should().set(eq("user:1"), any(User.class));
    }
}
```

### Controller 切片测试
```java
@WebMvcTest(UserController.class)
@DisplayName("用户控制器测试")
class UserControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserService userService;

    @Test
    @DisplayName("GET /user/1 返回用户信息")
    void getUser_ById_ReturnsUser() throws Exception {
        given(userService.getUser(1L)).willReturn(new UserVO(1L, "zhang"));
        mockMvc.perform(get("/user/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("zhang"));
    }

    @Test
    @DisplayName("GET /user/1 用户不存在返回404")
    void getUser_NotFound_Returns404() throws Exception {
        given(userService.getUser(99L)).willThrow(new UserNotFoundException(99L));
        mockMvc.perform(get("/user/99"))
            .andExpect(status().isNotFound());
    }
}
```

### Repository 切片测试
```java
@DataJpaTest
@DisplayName("用户仓库测试")
class UserRepositoryTest {
    @Autowired TestEntityManager em;
    @Autowired UserRepository repo;

    @Test
    @DisplayName("按用户名查询-存在-返回用户")
    void findByUsername_Exists_ReturnUser() {
        em.persistAndFlush(new User("zhang", "zhang@test.com"));
        Optional<User> result = repo.findByUsername("zhang");
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo("zhang@test.com");
    }

    @Test
    @DisplayName("按用户名查询-不存在-返回空")
    void findByUsername_NotExists_ReturnEmpty() {
        Optional<User> result = repo.findByUsername("nonexistent");
        assertThat(result).isEmpty();
    }
}
```

### 参数化测试
```java
@ExtendWith(MockitoExtension.class)
class PriceServiceTest {
    @InjectMocks PriceService priceService;

    @ParameterizedTest
    @MethodSource("discountParams")
    @DisplayName("计算折扣-多场景验证")
    void calcDiscount_Scenarios(BigDecimal price, int level, BigDecimal expected) {
        assertThat(priceService.calcDiscount(price, level))
            .isEqualByComparingTo(expected);
    }

    static Stream<Arguments> discountParams() {
        return Stream.of(
            Arguments.of(new BigDecimal("100"), 1, new BigDecimal("100")),
            Arguments.of(new BigDecimal("100"), 2, new BigDecimal("90")),  // 9折
            Arguments.of(new BigDecimal("100"), 3, new BigDecimal("80"))   // 8折
        );
    }
}
```

### ArgumentCaptor 参数捕获
```java
@Test
@DisplayName("注册用户-验证发送欢迎邮件")
void registerUser_ShouldSendWelcomeEmail() {
    @Captor ArgumentCaptor<EmailMessage> emailCaptor;
    given(mailClient.send(any())).willReturn(true);
    
    userService.register("test@test.com", "张三");
    
    then(mailClient).should().send(emailCaptor.capture());
    EmailMessage msg = emailCaptor.getValue();
    assertThat(msg.getTo()).isEqualTo("test@test.com");
    assertThat(msg.getSubject()).contains("欢迎");
}
```

### @Nested 组织测试
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("订单服务测试")
class OrderServiceTest {
    @Mock OrderRepository orderRepo;
    @InjectMocks OrderService orderService;

    @Nested
    @DisplayName("创建订单")
    class CreateOrder {
        @Test
        @DisplayName("正常创建-返回订单ID")
        void normal_ReturnOrderId() { ... }

        @Test
        @DisplayName("库存不足-抛异常")
        void noStock_ThrowException() { ... }
    }

    @Nested
    @DisplayName("取消订单")
    class CancelOrder {
        @Test
        @DisplayName("已支付-退款并取消")
        void paid_RefundAndCancel() { ... }

        @Test
        @DisplayName("已取消-幂等")
        void alreadyCancelled_Idempotent() { ... }
    }
}
```

## 测试选择决策树

```
需要测试什么？
├── Service/业务逻辑
│   ├── 纯逻辑(无外部依赖) → @Test + new 对象
│   └── 有DB/HTTP/MQ依赖 → @ExtendWith(MockitoExtension.class) + @Mock/@InjectMocks
├── Controller/API
│   └── @WebMvcTest + @MockBean
├── Repository/数据层
│   └── @DataJpaTest + TestEntityManager
├── JSON序列化
│   └── @JsonTest
└── 集成测试(多组件)
    └── @SpringBootTest(慎用，仅关键流程)
```

## Gotchas
1. **@Mock 不 Mock POJO** — 只 Mock 外部依赖，POJO 直接 new
2. **@SpringBootTest 启动整个上下文(慢)** — 优先用切片测试 @WebMvcTest/@DataJpaTest
3. **AssertJ 断言优于 assertEquals** — `assertThat(x).isEqualTo(y)` 更可读、链式调用
4. **@MockBean 和 @Mock 不同** — @MockBean 是 Spring 容器中的 Mock(集成测试)，@Mock 是纯 Mockito(单元测试)
5. **verify() 验证次数默认 times(1)** — 调用0次需显式用 `never()` 或 `times(0)`
6. **@MockitoExtension 自动初始化 mocks** — 不需要在 @BeforeEach 调用 MockitoAnnotations.openMocks(this)
7. **测试方法命名** — `methodName_StateUnderTest_ExpectedBehavior` 或 `@DisplayName` 中文描述
8. **JUnit5 @Nested 组织相关测试** — 替代 JUnit4 的 @FixMethodOrder
9. **@InjectMocks 必须是具体类** — 不能是接口或抽象类(需要实例化)
10. **Mockito 不能 Mock 构造方法、final 类、静态方法(默认)** — 需要 PowerMock/Mockito Inline
11. **BDDMockito.then(mock).should() 替代 verify(mock)** — 更符合 Given-When-Then 结构
12. **@Captor 比手动创建 ArgumentCaptor 更简洁** — 声明式参数捕获

## Data Privacy
本技能不收集、存储或传输任何用户数据。
