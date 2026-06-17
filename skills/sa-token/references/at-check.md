# 注解鉴权

## 注解一览

| 注解 | 所属技能 | 作用 |
|------|----------|------|
| `@SaCheckLogin` | sa-token(当前) | 登录校验——只有登录后才能进入该方法 |
| `@SaCheckRole("admin")` | sa-token(当前) | 角色校验——必须具有指定角色才能进入 |
| `@SaCheckPermission("user.add")` | sa-token(当前) | 权限校验——必须具有指定权限才能进入 |
| `@SaCheckSafe` | sa-token-advanced | 二级认证校验 |
| `@SaCheckHttpBasic(account="sa:123456")` | sa-token-advanced | HttpBasic校验 |
| `@SaCheckHttpDigest("sa:123456")` | sa-token-advanced | HttpDigest校验 |
| `@SaCheckDisable("comment")` | sa-token-advanced | 账号服务封禁校验 |
| `@SaCheckSign` | sa-token-api-security | API签名校验 |
| `@SaCheckApiKey(scope="userinfo")` | sa-token-api-security | API Key校验 |
| `@SaIgnore` | sa-token(当前) | 忽略校验 |

> 注解鉴权默认关闭，**必须手动将 Sa-Token 的全局拦截器注册到项目中**。

## 1. 注册拦截器

```java
@Configuration
public class SaTokenConfigure implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SaInterceptor()).addPathPatterns("/**");
    }
}
```

## 2. 使用注解鉴权

```java
// 登录校验：只有登录之后才能进入该方法
@SaCheckLogin
@RequestMapping("info")
public String info() { return "查询用户信息"; }

// 角色校验：必须具有指定角色才能进入该方法
@SaCheckRole("super-admin")
@RequestMapping("add")
public String add() { return "用户增加"; }

// 权限校验：必须具有指定权限才能进入该方法
@SaCheckPermission("user-add")
@RequestMapping("add")
public String add() { return "用户增加"; }

// 二级认证校验：必须二级认证之后才能进入该方法
@SaCheckSafe()
@RequestMapping("add")
public String add() { return "用户增加"; }

// Http Basic 校验：只有通过 Http Basic 认证后才能进入该方法
@SaCheckHttpBasic(account = "sa:123456")
@RequestMapping("add")
public String add() { return "用户增加"; }

// Http Digest 校验
@SaCheckHttpDigest(value = "sa:123456")
@RequestMapping("add")
public String add() { return "用户增加"; }

// 校验当前账号是否被封禁 comment 服务
@SaCheckDisable("comment")
@RequestMapping("send")
public String send() { return "查询用户信息"; }
```

> 所有注解都可以加在**类上**，代表为这个类的所有方法进行鉴权。

## 3. 设定校验模式

```java
// OR模式：只要具有其中一个权限即可通过
@RequestMapping("atJurOr")
@SaCheckPermission(value = {"user-add", "user-all", "user-delete"}, mode = SaMode.OR)
public SaResult atJurOr() { return SaResult.data("用户信息"); }
```

`mode` 两种取值：
- `SaMode.AND`：标注一组权限，会话必须全部具有才可通过校验（默认）
- `SaMode.OR`：标注一组权限，会话只要具有其一即可通过校验

## 4. 角色权限双重 OR 校验

一个接口在具有权限 `user.add` **或**角色 `admin` 时可以调通：

```java
@RequestMapping("userAdd")
@SaCheckPermission(value = "user.add", orRole = "admin")
public SaResult userAdd() { return SaResult.data("用户信息"); }
```

`orRole` 三种写法：
- **写法一**：`orRole = "admin"`，代表需要拥有角色 admin
- **写法二**：`orRole = {"admin", "manager", "staff"}`，代表具有三个角色其一即可
- **写法三**：`orRole = {"admin, manager, staff"}`，代表必须同时具有三个角色

## 5. @SaIgnore 忽略认证

```java
@SaCheckLogin
@RestController
public class TestController {
    // 此接口加上了 @SaIgnore 可以游客访问
    @SaIgnore
    @RequestMapping("getList")
    public SaResult getList() { return SaResult.ok(); }
}
```

规则：
- `@SaIgnore` 修饰方法 → 这个方法可以被游客访问
- `@SaIgnore` 修饰类 → 这个类中的所有接口都可以游客访问
- `@SaIgnore` 具有最高优先级，和其它鉴权注解一起出现时，其它鉴权注解都将被忽略
- `@SaIgnore` 同样可以忽略掉 Sa-Token 拦截器中的路由鉴权

## 6. @SaCheckOr 批量注解鉴权

```java
@SaCheckOr(
    login = @SaCheckLogin,
    role = @SaCheckRole("admin"),
    permission = @SaCheckPermission("user.add"),
    safe = @SaCheckSafe("update-password"),
    httpBasic = @SaCheckHttpBasic(account = "sa:123456"),
    disable = @SaCheckDisable("submit-orders")
)
@RequestMapping("test")
public SaResult test() { return SaResult.ok(); }
```

每一项属性都可以写成数组形式：
```java
@SaCheckOr(
    login = { @SaCheckLogin(type = "login"), @SaCheckLogin(type = "user") }
)
```

多个注解同时出现时，默认 AND 关系：
```java
@SaCheckLogin
@SaCheckRole("admin")
@SaCheckPermission("user.add")  // 必须同时满足三者
```

使用 append 字段追加扩展包里的注解：
```java
@RequestMapping("/test")
@SaCheckOr(login = @SaCheckLogin, append = { SaCheckApiKey.class })
public SaResult test() { return SaResult.ok(); }
```

## 7. 扩展阅读

- 在业务逻辑层使用鉴权注解：[AOP注解鉴权](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/aop-at.md)
- 制作自定义鉴权注解注入到框架：[自定义注解](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/fun/custom-annotations.md)

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/at-check.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/at-check.md)（254行）
