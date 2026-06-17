# JUnit5 + Mockito 实战示例

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock UserRepository userRepo;
    @Mock CacheManager cache;
    @InjectMocks UserService userService;

    @Test @DisplayName("缓存命中直接返回")
    void getUser_CacheHit() {
        User cached = new User(1L, "zhang");
        given(cache.get("user:1")).willReturn(cached);
        User result = userService.getUser(1L);
        assertThat(result.getName()).isEqualTo("zhang");
        verify(userRepo, never()).findById(anyLong());
    }

    @Test @DisplayName("缓存未命中查DB并缓存")
    void getUser_CacheMiss_QueryDB() {
        given(cache.get("user:1")).willReturn(null);
        given(userRepo.findById(1L)).willReturn(Optional.of(new User(1L, "zhang")));
        User result = userService.getUser(1L);
        assertThat(result).isNotNull();
        verify(cache).set(eq("user:1"), any(User.class));
    }
}

// Controller 切片测试
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserService userService;
    @Test void getUser() throws Exception {
        given(userService.getUser(1L)).willReturn(new UserVO(1L, "zhang"));
        mockMvc.perform(get("/user/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("zhang"));
    }
}
```

---

> 来源：[https://junit.org/junit5/docs/current/user-guide/](https://junit.org/junit5/docs/current/user-guide/)
