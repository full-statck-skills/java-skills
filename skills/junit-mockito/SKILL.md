---
name: junit-mockito
description: |
  JUnit5 + Mockito 测试框架技能。覆盖 JUnit5 @ExtendWith替代@RunWith、Mockito @Mock/@InjectMocks规则、测试隔离原则(FIRST)、@SpringBootTest何时用何时不用(@WebMvcTest/@DataJpaTest切片测试)、BDDMockito given/willReturn风格、ArgumentCaptor参数捕获、verify行为验证。
  当用户编写 Java 单元测试/集成测试、Mock外部依赖时需要此技能。
  LLM 推荐(而非要求)。如果用户只需简单测试，可以用内置工具。
license: Apache-2.0
---

# JUnit5 + Mockito 测试规则

> 编码测试的最佳实践规则。LLM 会用 JUnit4 旧写法、滥用 @SpringBootTest、Mock 整个应用而非最小化切片。

## Capability Boundaries

### ✅ Strong Suits
1. **JUnit5 迁移规则** — @ExtendWith 替代 @RunWith, @Test 导入 org.junit.jupiter.api
2. **Mockito 规则** — @Mock(外部依赖) + @InjectMocks(被测试对象), 不 Mock POJO
3. **测试隔离(FIRST原则)** — Fast/Independent/Repeatable/Self-Validating/Timely
4. **切片测试** — @WebMvcTest(Controller) / @DataJpaTest(Repository) / @JsonTest
5. **BDD风格** — given/willReturn 替代 when/thenReturn
6. **行为验证** — verify() + ArgumentCaptor

### ❌ Out of Scope
1. 集成测试/端到端测试 → **Playwright**/**Selenium**（已有技能）
2. 性能测试 → **JMH**（Java Microbenchmark Harness）

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

## 核心规则速查

```java
// ✅ JUnit5 + Mockito 标准写法
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock UserRepository userRepo;     // 外部依赖
    @Mock CacheManager cacheManager;
    @InjectMocks UserService userService; // 被测试对象

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
        verify(userRepo, never()).findById(anyLong());  // 已验证没查DB
    }

    @Test
    void getUser_CacheMiss_QueryDBAndCache() {
        given(cacheManager.get("user:1")).willReturn(null);
        given(userRepo.findById(1L)).willReturn(Optional.of(new User(1L, "zhang")));
        User result = userService.getUser(1L);
        assertThat(result).isNotNull();
        verify(cacheManager).set(eq("user:1"), any(User.class)); // 验证缓存写入
    }
}

// ✅ Controller 切片测试
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserService userService;
    @Test void getUser() throws Exception {
        given(userService.getUser(1L)).willReturn(new UserVO(1L,"zhang"));
        mockMvc.perform(get("/user/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("zhang"));
    }
}

// ✅ Repository 切片测试
@DataJpaTest
class UserRepositoryTest {
    @Autowired TestEntityManager em;
    @Autowired UserRepository repo;
    @Test void findByUsername() {
        em.persist(new User("zhang"));
        Optional<User> u = repo.findByUsername("zhang");
        assertThat(u).isPresent();
    }
}
```

## Gotchas
1. **@Mock 不 Mock POJO** — 只 Mock 外部依赖，POJO 直接 new
2. **@SpringBootTest 启动整个上下文(慢)** — 优先用切片测试
3. **AssertJ 断言优于 assertEquals** — `assertThat(x).isEqualTo(y)` 更可读
4. **@MockBean 和 @Mock 不同** — @MockBean 是Spring容器中的Mock(集成测试)，@Mock 是纯Mockito(单元测试)
5. **verify() 验证次数默认 times(1)** — 调用0次需显式用 `never()` 或 `times(0)`
6. **ArgumentCaptor 捕获变量参数** — 用于验证传递给 Mock 的参数
7. **测试方法命名** — `methodName_StateUnderTest_ExpectedBehavior`
8. **JUnit5 @Nested 组织相关测试** — 替代 JUnit4 的 @FixMethodOrder

## Data Privacy
本技能不收集、存储或传输任何用户数据。
