# Scope 权限自定义与分级

> 来源：
> - [oauth2-custom-scope.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-custom-scope.md)（235行）
> - [oauth2-scope-level.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/oauth2/oauth2-scope-level.md)（136行）

## 自定义 Scope 处理器

```java
@Component
public class SaOAuth2DataLoaderImpl implements SaOAuth2DataLoader {
    @Override
    public Object getScope(String scope) {
        if("userinfo".equals(scope)) {
            return new SaScopeObject()
                .setScope("userinfo")
                .setName("获取用户基本信息")
                .setIsDefault(true);        // 默认选中
        }
        if("chat".equals(scope)) {
            return new SaScopeObject()
                .setScope("chat")
                .setName("发送消息")
                .setIsDefault(false);
        }
        return null;
    }
}
```

## Scope 等级控制

```java
// 定义Scope等级(数字越大级别越高)
SaOAuth2ScopeLevelUtil.addScopeLevel("userinfo", 1);   // 基础信息
SaOAuth2ScopeLevelUtil.addScopeLevel("email", 2);       // 中级
SaOAuth2ScopeLevelUtil.addScopeLevel("phone", 3);       // 高级
```

## 注解校验Access-Token

```java
@SaCheckAccessToken               // 校验AccessToken
@SaCheckClientToken               // 校验ClientToken
@SaCheckOAuth2Scope("userinfo")   // 校验Scope
```
