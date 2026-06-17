# 前后端分离 SSO 方案（H5）

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-h5.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/sso/sso-h5.md)（322行）

## H5 方案流程

标准SSO需要后端重定向，前后端分离项目需要手动控制：

1. 前端检测未登录 → 重定向到Server登录页(带redirect参数)
2. 用户登录 → Server重定向回前端(带ticket参数)
3. 前端解析URL中的ticket → 调用后端接口换取登录态
4. 后端用ticket换取loginId → 写入本地Session

## 前端代码

```js
// 检测SSO回调
const urlParams = new URLSearchParams(window.location.search);
const ticket = urlParams.get('ticket');
if (ticket) {
    const res = await axios.post('/sso/loginByTicket', { ticket });
    localStorage.setItem('token', res.data.token);
    history.replaceState({}, '', '/');  // 清除URL中的ticket
}

// 未登录时跳转
if (!isLogin) {
    const redirectUrl = encodeURIComponent(window.location.href);
    window.location.href = `http://sso-server.com/sso/auth?redirect=${redirectUrl}`;
}
```

## 后端接口

```java
@RequestMapping("/sso/loginByTicket")
public SaResult loginByTicket(String ticket) {
    String loginId = SaSsoClientProcessor.instance.checkTicket(ticket);
    if (loginId != null) {
        StpUtil.login(loginId);
        return SaResult.data(StpUtil.getTokenInfo());
    }
    return SaResult.error("ticket无效");
}
```
