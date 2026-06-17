# 前后端分离 & 记住我模式

## 前后端分离（无Cookie模式）

### 何为无Cookie模式

Cookie 有两个特性：
1. **可由后端控制写入**
2. **每次请求自动提交**

在 app、小程序等前后端分离场景中，一般没有 Cookie 功能。解决方案：
- 不能后端控制写入 → 前端自己写入（后端将 Token 传递到前端）
- 每次请求不能自动提交 → 手动提交（前端将 Token 传递到后端，后端将其读取出来）

### 1. 后端将 Token 返回到前端

```java
@RequestMapping("doLogin")
public SaResult doLogin() {
    // 第1步，先登录上
    StpUtil.login(10001);
    // 第2步，获取 Token 相关参数
    SaTokenInfo tokenInfo = StpUtil.getTokenInfo();
    // 第3步，返回给前端
    return SaResult.data(tokenInfo);
}
```

前端将 `tokenName` 和 `tokenValue` 保存到本地。

### 2. 前端将 Token 提交到后端

格式：`{tokenName: tokenValue}`，塞到请求 header 里。

**uni-app 示例（方式1-简单粗暴）：**
```js
// 登录时存储
uni.setStorageSync('tokenValue', tokenValue);
// 请求时携带
uni.request({
    url: 'https://www.example.com/request',
    header: {
        "satoken": uni.getStorageSync('tokenValue')   // 关键代码
    },
    success: (res) => { console.log(res.data); }
});
```

**uni-app 示例（方式2-更加灵活）：**
```js
// 登录时存储tokenName和tokenValue
uni.setStorageSync('tokenName', tokenName);
uni.setStorageSync('tokenValue', tokenValue);

// 请求时组装header
var tokenName = uni.getStorageSync('tokenName');
var tokenValue = uni.getStorageSync('tokenValue');
var header = { "content-type": "application/x-www-form-urlencoded" };
if (tokenName != undefined && tokenName != '') {
    header[tokenName] = tokenValue;
}
uni.request({ url: '...', header: header });
```

## 记住我模式

### 实现原理

利用 Cookie 生命周期特性：
- **临时Cookie**：有效期为本次会话，关闭浏览器窗口后 Cookie 消失
- **持久Cookie**：有效期为一个具体的时间，关闭浏览器也不消失

### API

```java
// true=持久Cookie(记住我)，false=临时Cookie(关闭浏览器需重新登录)
StpUtil.login(10001, false);
```

### 登录时指定 Token 有效期

```java
// 指定token7天有效
StpUtil.login(10001, new SaLoginParameter().setTimeout(60 * 60 * 24 * 7));

// 所有参数
StpUtil.login(10001, new SaLoginParameter()
    .setDevice("PC")                    // 设备类型
    .setIsLastingCookie(true)           // 持久Cookie
    .setTimeout(60 * 60 * 24 * 7)       // token有效期
    .setToken("xxxx-xxxx-xxxx-xxxx")    // 预定token值
    .setIsWriteHeader(false)            // 是否写入响应头
);
```

### 前后端分离下的记住我

```js
// uni-app: 持久Cookie
uni.setStorageSync("satoken", "xxxx-xxxx-xxxx-xxxx-xxx");
// uni-app: 临时Cookie
getApp().globalData.satoken = "xxxx-xxxx-xxxx-xxxx-xxx";

// 浏览器: 持久Cookie
localStorage.setItem("satoken", "xxxx-xxxx-xxxx-xxxx-xxx");
// 浏览器: 临时Cookie
sessionStorage.setItem("satoken", "xxxx-xxxx-xxxx-xxxx-xxx");
```

---

> 来源：
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/not-cookie.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/not-cookie.md)（109行）
> - [https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/remember-me.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/up/remember-me.md)（90行）
