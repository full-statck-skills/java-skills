# Hutool 实战示例

## 示例 1：身份证校验 + 提取信息

```java
@RestController
public class UserController {
    @PostMapping("/register")
    public ApiResult register(@RequestBody RegisterDTO dto) {
        // ✅ Hutool 一行校验
        if (!IdcardUtil.isValidCard(dto.getIdCard())) {
            return ApiResult.fail("身份证号格式不正确");
        }
        // 提取信息
        int age = IdcardUtil.getAgeByIdCard(dto.getIdCard());
        String gender = IdcardUtil.getGenderByIdCard(dto.getIdCard());
        if (age < 18) return ApiResult.fail("未满18岁");
        return userService.register(dto, age, gender);
    }
}
```

## 示例 2：HTTP 工具简单调用

```java
@Service
public class SmsService {
    public void sendCode(String phone) {
        // ✅ 简单HTTP场景一行搞定(非高并发)
        String result = HttpUtil.post("https://sms-api.example.com/send",
            MapUtil.of("phone", phone, "template", "login"));
        JSONObject resp = JSONUtil.parseObj(result);
        if (!"0".equals(resp.getStr("code"))) {
            throw new BizException("发送失败: " + resp.getStr("msg"));
        }
    }
}
```

## 示例 3：日期处理实用方法

```java
public class DateUtils {
    // 计算两个日期之间的天数
    public static long daysBetween(String start, String end) {
        Date d1 = DateUtil.parse(start);
        Date d2 = DateUtil.parse(end);
        return DateUtil.between(d1, d2, DateUnit.DAY);
    }
    // 获取30天前的日期
    public static String thirtyDaysAgo() {
        return DateUtil.format(DateUtil.offsetDay(new Date(), -30), "yyyy-MM-dd");
    }
    // 本月第一天
    public static String firstDayOfMonth() {
        return DateUtil.format(DateUtil.beginOfMonth(new Date()), "yyyy-MM-dd");
    }
}
```

## 示例 4：StrUtil 命名转换

```java
// ✅ 下划线 → 驼峰(数据库字段→Java字段)
String name = StrUtil.toCamelCase("user_name");        // "userName"

// ✅ 驼峰 → 下划线(Java字段→JSON)
String column = StrUtil.toUnderlineCase("createTime"); // "create_time"

// ✅ 格式化模板
String msg = StrUtil.format("用户{}在{}登录", "张三", DateUtil.now()); // "用户张三在2024-03-15登录"
```

---

> 来源：[https://doc.hutool.cn/](https://doc.hutool.cn/)
