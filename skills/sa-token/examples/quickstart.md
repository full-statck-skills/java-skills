# Sa-Token 快速入门示例

## 1. 创建项目

在 IDE 中新建一个 SpringBoot 项目。

## 2. 添加依赖

**Maven：**
```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-spring-boot-starter</artifactId>
    <version>1.45.0</version>
</dependency>
```
- SpringBoot 3.x → `sa-token-spring-boot3-starter`
- SpringBoot 4.x → `sa-token-spring-boot4-starter`

**Gradle：**
```gradle
implementation 'cn.dev33:sa-token-spring-boot-starter:1.45.0'
```

## 3. 配置文件 application.yml

```yaml
server:
  port: 8081

############## Sa-Token 配置 ##############
sa-token:
  token-name: satoken
  timeout: 2592000
  active-timeout: -1
  is-concurrent: true
  is-share: false
  token-style: uuid
  is-log: true
```

## 4. 启动类

```java
@SpringBootApplication
public class SaTokenDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(SaTokenDemoApplication.class, args);
        System.out.println("启动成功，Sa-Token 配置如下：" + SaManager.getConfig());
    }
}
```

## 5. 测试 Controller

```java
@RestController
@RequestMapping("/user/")
public class UserController {

    // 登录: http://localhost:8081/user/doLogin?username=zhang&password=123456
    @RequestMapping("doLogin")
    public String doLogin(String username, String password) {
        if("zhang".equals(username) && "123456".equals(password)) {
            StpUtil.login(10001);
            return "登录成功";
        }
        return "登录失败";
    }

    // 查询登录状态: http://localhost:8081/user/isLogin
    @RequestMapping("isLogin")
    public String isLogin() {
        return "当前会话是否登录：" + StpUtil.isLogin();
    }
}
```

## 6. 运行

启动后访问：
- `http://localhost:8081/user/doLogin?username=zhang&password=123456` → 登录成功
- `http://localhost:8081/user/isLogin` → 当前会话是否登录：true

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/start/example.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/start/example.md)（160行）
