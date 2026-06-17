# 权限/角色认证

## 1. 设计思路

权限认证的最终目的在于：规定哪些用户可以访问哪些接口/页面/资源。

从底层数据的角度来讲：**每个账号都会拥有一组权限码集合，框架要做的就是校验这个集合中是否包含指定的权限码。** 有→通过，没有→禁止访问。

## 2. 获取当前账号权限码集合

### 实现 StpInterface 接口

必须实现此接口，告诉框架指定账号拥有的权限码和角色集合：

```java
@Component  // 保证被 SpringBoot 扫描，完成 Sa-Token 自定义权限验证扩展
public class StpInterfaceImpl implements StpInterface {

    /**
     * 返回一个账号所拥有的权限码集合
     */
    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        List<String> list = new ArrayList<String>();
        list.add("101");
        list.add("user.add");
        list.add("user.update");
        list.add("user.get");
        // list.add("user.delete");
        list.add("art.*");       // 通配符权限
        return list;
    }

    /**
     * 返回一个账号所拥有的角色标识集合 (权限与角色可分开校验)
     */
    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        List<String> list = new ArrayList<String>();
        list.add("admin");
        list.add("super-admin");
        return list;
    }
}
```

**参数解释：**
- `loginId`：账号id，即调用 `StpUtil.login(id)` 时写入的唯一标识
- `loginType`：账号体系标识（多账户认证时使用，单系统默认为"login"）

> ⚠️ 注意：StpInterface 不会在程序启动时执行，只有在每次调用鉴权代码时才会触发。

## 3. 权限校验 API

```java
// 获取：当前账号所拥有的权限集合
StpUtil.getPermissionList();

// 获取：指定账号的权限集合
StpUtil.getPermissionList(10001);

// 判断：当前账号是否含有指定权限, 返回 true 或 false
StpUtil.hasPermission("user.add");

// 判断：指定账号是否含有指定权限标识, 返回true或false
StpUtil.hasPermission(loginId, "user.add");

// 校验：当前账号是否含有指定权限, 如果验证未通过，则抛出异常: NotPermissionException
StpUtil.checkPermission("user.add");

// 校验：当前账号是否含有指定权限 [指定多个，必须全部验证通过]
StpUtil.checkPermissionAnd("user.add", "user.delete", "user.get");

// 校验：当前账号是否含有指定权限 [指定多个，只要其一验证通过即可]
StpUtil.checkPermissionOr("user.add", "user.delete", "user.get");
```

> `NotPermissionException` 异常对象可通过 `getLoginType()` 方法获取具体是哪个 `StpLogic` 抛出的异常。

## 4. 角色校验 API

```java
// 获取：当前账号的角色集合
StpUtil.getRoleList();

// 获取：指定账号的角色集合
StpUtil.getRoleList(10001);

// 判断：当前账号是否拥有指定角色, 返回 true 或 false
StpUtil.hasRole("super-admin");

// 判断：指定账号是否含有指定角色标识, 返回true或false
StpUtil.hasRole(loginId, "super-admin");

// 校验：当前账号是否含有指定角色标识, 如果验证未通过，则抛出异常: NotRoleException
StpUtil.checkRole("super-admin");

// 校验：当前账号是否含有指定角色标识 [指定多个，必须全部验证通过]
StpUtil.checkRoleAnd("super-admin", "shop-admin");

// 校验：当前账号是否含有指定角色标识 [指定多个，只要其一验证通过即可]
StpUtil.checkRoleOr("super-admin", "shop-admin");
```

> `NotRoleException` 异常对象可通过 `getLoginType()` 方法获取具体是哪个 `StpLogic` 抛出的异常。

## 5. 拦截全局异常

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler
    public SaResult handlerException(Exception e) {
        e.printStackTrace();
        return SaResult.error(e.getMessage());
    }
}
```

## 6. 权限通配符

Sa-Token 允许根据通配符指定**泛权限**。当一个账号拥有 `art.*` 的权限时，`art.add`、`art.delete`、`art.update` 都将匹配通过。

```java
// 当拥有 art.* 权限时
StpUtil.hasPermission("art.add");        // true
StpUtil.hasPermission("art.update");     // true
StpUtil.hasPermission("goods.add");      // false

// 当拥有 *.delete 权限时
StpUtil.hasPermission("art.delete");      // true
StpUtil.hasPermission("user.delete");     // true
StpUtil.hasPermission("user.update");     // false

// 当拥有 *.js 权限时
StpUtil.hasPermission("index.js");        // true
StpUtil.hasPermission("index.css");       // false
StpUtil.hasPermission("index.html");      // false
```

> **上帝权限**：当一个账号拥有 `"*"` 权限时，他可以验证通过任何权限码（角色认证同理）。

## 7. 按钮级权限控制

前后端分离项目：

1. 登录时把当前账号拥有的所有权限码一次性返回给前端
2. 前端将权限码集合保存在 localStorage 或全局状态管理
3. 在需要权限控制的按钮上，使用 js 进行逻辑判断

```java
@RequestMapping("getPermissionList")
public SaResult getPermissionList() {
    return SaResult.data(StpUtil.getPermissionList());
}
```

Vue 前端示例：
```html
<button v-if="arr.indexOf('user.get') > -1">查询用户</button>
<button v-if="arr.indexOf('user.update') > -1">修改用户</button>
<button v-if="arr.indexOf('user.delete') > -1">删除按钮</button>
```

> ⚠️ **前端的鉴权只是一个辅助功能，后端接口必须同样进行权限校验！**

---

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/jur-auth.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/use/jur-auth.md)（212行）
