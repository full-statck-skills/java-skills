# API Key

> 来源：[https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md](https://github.com/dromara/sa-token/blob/dev/sa-token-doc/plugin/api-key.md)（283行）

## 凭证对比

| 凭证 | 风险 | 可控性 |
|------|------|--------|
| 账号密码 | 获取全部权限 | ❌ |
| 会话Token | 几乎所有API | ❌ |
| **API Key** | 受控Scope权限 | ✅ 可吊销、部分授权、独立有效期 |

## 依赖

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-apikey</artifactId>
    <version>1.45.0</version>
</dependency>
```

## 创建

```java
ApiKeyModel akModel = SaApiKeyUtil.createApiKeyModel(10001).setTitle("test");
akModel.addScope("commit", "pull");                // Scope权限
akModel.setExpiresTime(System.currentTimeMillis() + 2592000); // 30天
akModel.setIsValid(true);
akModel.addExtra("name", "张三");
SaApiKeyUtil.saveApiKey(akModel);
```

## 查询/删除

```java
ApiKeyModel ak = SaApiKeyUtil.getApiKey("AK-xxx");
Object loginId = SaApiKeyUtil.getLoginIdByApiKey("AK-xxx");
List<ApiKeyModel> list = SaApiKeyUtil.getApiKeyList(10001);
SaApiKeyUtil.deleteApiKey("AK-xxx");
```

## 校验

```java
SaApiKeyUtil.checkApiKey("AK-xxx");                 // 有效性
SaApiKeyUtil.checkApiKeyScope("AK-xxx", "userinfo"); // Scope
SaApiKeyUtil.hasApiKeyScope("AK-xxx", "userinfo");   // boolean
SaApiKeyUtil.checkApiKeyLoginId("AK-xxx", 10001);    // 账号归属
```

## 注解

```java
@SaCheckApiKey
@SaCheckApiKey(scope = "userinfo")
@SaCheckApiKey(scope = {"userinfo","chat"}, mode = SaMode.OR)
```

## 多账号体系

```java
SaApiKeyTemplate adminKeyTemplate = new SaApiKeyTemplate("admin-apikey");
ApiKeyModel ak = adminKeyTemplate.createApiKeyModel(StpUtil.getLoginId());
adminKeyTemplate.saveApiKey(ak);
```

## 数据库模式

```java
@Component
public class SaApiKeyDataLoaderImpl implements SaApiKeyDataLoader {
    @Override
    public ApiKeyModel getApiKeyModelFromDatabase(String namespace, String apiKey) {
        return apiKeyMapper.getApiKeyModel(apiKey);
    }
}
```
