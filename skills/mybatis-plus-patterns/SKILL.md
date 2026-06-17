---
name: mybatis-plus-patterns
description: |
  MyBatis-Plus 增强 ORM 技能。覆盖 LambdaQueryWrapper vs QueryWrapper选择(始终Lambda)、分页插件(PaginationInnerInterceptor)配置、乐观锁(@Version + OptimisticLockerInnerInterceptor)、逻辑删除(@TableLogic 全局/局部配置)、自动填充(@TableField fill + MetaObjectHandler)、ActiveRecord vs Mapper模式选择、防全表更新(BlockAttackInnerInterceptor)、通用PageQuery抽取。
  当用户使用 MyBatis-Plus 进行数据库操作、配置分页乐观锁、选择查询方式时使用。
  与 mybatis 技能互补：mybatis 侧重XML/ResultMap/SQL写法，mybatis-plus 侧重增强功能。
license: Apache-2.0
---

# MyBatis-Plus 增强 ORM

> 来源：[https://baomidou.com/](https://baomidou.com/)  
> GitHub：[https://github.com/baomidou/mybatis-plus](https://github.com/baomidou/mybatis-plus)

## Capability Boundaries

### ✅ Strong Suits
1. **LambdaQueryWrapper** — 类型安全的查询(不用写字符串字段名)
2. **分页插件** — PaginationInnerInterceptor 配置与使用
3. **乐观锁** — @Version + OptimisticLockerInnerInterceptor
4. **逻辑删除** — @TableLogic 全局配置 vs 单表配置
5. **自动填充** — @TableField(fill) + MetaObjectHandler 实现
6. **ActiveRecord vs Mapper** — Entity extends Model vs 独立 Mapper 接口选择
7. **防全表操作** — BlockAttackInnerInterceptor
8. **通用分页封装** — PageQuery → PageDTO 泛型模式

### ❌ Out of Scope
1. MyBatis XML/ResultMap/动态SQL → **mybatis-patterns**
2. MyBatis-Plus Generator 代码生成 → 已有 **mybatis-plus-generator** 技能
3. MyBatis-Plus 数据权限 → 插件体系，非 LLM 常见需求

## 最精简配置
```java
@Configuration
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        interceptor.addInnerInterceptor(new BlockAttackInnerInterceptor()); // ← 推荐
        return interceptor;
    }
}
```

```yaml
mybatis-plus:
  global-config:
    db-config:
      id-type: auto                    # 主键自增
      logic-delete-field: deleted      # 逻辑删除字段
      logic-delete-value: 1
      logic-not-delete-value: 0
      insert-strategy: not_null
      update-strategy: not_null
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # 开发环境
```

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `eq("user_name", username)` 字符串字段名 | `eq(User::getUsername, username)` Lambda 类型安全 |
| 2 | 只用 PageHelper 不分页 | 用 IPage + PaginationInnerInterceptor |
| 3 | 不配置乐观锁导致并发覆盖 | @Version + OptimisticLockerInnerInterceptor |
| 4 | `UPDATE SET is_deleted = 1` 手动删除 | @TableLogic 自动转 UPDATE |
| 5 | 不知道 ActiveRecord 模式 | extends Model<T> → entity.insert/updateById/selectById |
| 6 | 不防全表更新/删除 | BlockAttackInnerInterceptor 阻止无 where 的 UPDATE/DELETE |
| 7 | 分页查询手动计算 total/pages | Page 自动封装 total, pages, records |
| 8 | createTime/updateTime 手动设置 | MetaObjectHandler 自动填充 |
| 9 | Wrapper 用字符串字段写死 | Wrappers.lambdaQuery() + LambdaQueryWrapper |

## 核心模式

### 模式 1: LambdaQueryWrapper（始终用 Lambda）
```java
// ✅ 推荐：LambdaQueryWrapper（类型安全）
LambdaQueryWrapper<User> wrapper = Wrappers.lambdaQuery();
wrapper.eq(User::getUsername, "张三")
       .ge(User::getAge, 18)
       .in(User::getStatus, List.of(1, 2))
       .orderByDesc(User::getCreateTime)
       .last("limit 10");  // 慎用 last——与分页冲突
List<User> list = userMapper.selectList(wrapper);

// ✅ 简化：lambdaQuery() 链式调用
List<User> adults = userService.lambdaQuery()
    .ge(User::getAge, 18)
    .in(User::getStatus, Arrays.asList(1, 2))
    .orderByDesc(User::getCreateTime)
    .list();

// ✅ 更新：lambdaUpdate()
userService.lambdaUpdate()
    .eq(User::getUsername, "张三")
    .set(User::getEmail, "new@test.com")
    .update();

// ❌ 避免：QueryWrapper（字符串硬编码，重构时不易发现）
// QueryWrapper<User> wrapper = new QueryWrapper<>();
// wrapper.eq("user_name", "张三");  // 字段名写死，重构时断裂
```

### 模式 2: 通用分页封装
```java
// 通用分页查询参数
@Data
public class PageQuery {
    @Min(1) private Integer pageNo = 1;
    @Min(1) @Max(5000) private Integer pageSize = 10;
    private String sortBy;
    private boolean isAsc = true;

    public <T> Page<T> toPage() {
        Page<T> page = Page.of(pageNo, pageSize);
        if (StrUtil.isNotBlank(sortBy)) {
            page.addOrder(new OrderItem(sortBy, isAsc));
        }
        return page;
    }
}

// 通用分页返回
@Data
public class PageDTO<T> {
    private Long total;
    private Long pages;
    private List<T> list;

    public static <T> PageDTO<T> of(IPage<T> page) {
        PageDTO<T> dto = new PageDTO<>();
        dto.setTotal(page.getTotal());
        dto.setPages(page.getPages());
        dto.setList(page.getRecords());
        return dto;
    }
}

// 使用
public PageDTO<User> queryUsers(PageQuery query) {
    Page<User> page = userService.page(query.toPage(),
        Wrappers.lambdaQuery<User>().ge(User::getAge, 18));
    return PageDTO.of(page);
}
```

### 模式 3: 乐观锁 + 逻辑删除 + 自动填充 Entity
```java
@Data
@TableName("sys_user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;
    private String email;

    @Version private Integer version;          // ← 乐观锁(更新时自动+1)

    @TableLogic private Integer deleted;        // ← 逻辑删除(0=正常, 1=删除)

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;           // ← 插入时自动填充

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;           // ← 更新时自动填充
}

// 自动填充处理器
@Component
public class MyMetaObjectHandler implements MetaObjectHandler {
    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createTime", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }
}
```

### 模式 4: ActiveRecord vs Mapper 对比
```java
// ActiveRecord: Entity extends Model<T>
@Data
@EqualsAndHashCode(callSuper = true) // ← 必须加
@TableName("sys_user")
public class User extends Model<User> {
    @TableId private Long id;
    private String username;
}
// 使用
User user = new User();
user.setUsername("张三");
user.insert();                         // 直接操作
User found = user.selectById(1L);
user.setEmail("new@test.com");
user.updateById();
user.deleteById();

// Mapper 模式: 独立 Mapper 接口 + IService
public interface UserMapper extends BaseMapper<User> {}

public interface UserService extends IService<User> {}
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {}
// 使用
userService.save(user);
userService.getById(1L);
userService.lambdaQuery().eq(User::getUsername, "张三").list();
```

### 模式 5: 防全表更新/删除
```java
// 配置 BlockAttackInnerInterceptor 后：
userService.update(new User().setEmail("all@test.com"));  // ❌ 抛出异常
// 必须加 where 条件
userService.lambdaUpdate()
    .eq(User::getStatus, "ACTIVE")
    .set(User::getEmail, "all@test.com")
    .update();  // ✅ 安全
```

## Gotchas
1. **LambdaQueryWrapper 需要注解处理器(annotation processor)生成元数据** — 否则 Lambda 表达式无法解析字段名
2. **乐观锁 @Version 字段类型支持 int/Integer/long/Long/Date/LocalDateTime/Timestamp**
3. **乐观锁必须先查询后更新** — `selectById → setXxx → updateById`，否则 version 为 null 不生效
4. **@TableLogic 影响全局所有删除操作** — deleteById/deleteBatchIds 都会变成 UPDATE
5. **自定义 SQL 不自动加逻辑删除条件** — 手写 SQL 需手动拼接 `AND deleted = 0`
6. **BlockAttackInnerInterceptor 阻止全表更新** — 开发阶段建议开启，生产按需
7. **分页插件在 PageHelper 存在时可能冲突** — 二选一，推荐 MyBatis-Plus 的分页
8. **ActiveRecord 模式 Entity 必须 extends Model** — 否则没有 insert/updateById 等方法
9. **逻辑删除后的查询自动带 deleted=0** — 如果需要查已删除的数据，手动 `eq(User::getDeleted, 1)`
10. **自动填充的 MetaObjectHandler 必须是 Spring Bean(@Component)** — 否则不生效
11. **strictInsertFill/strictUpdateFill 要求字段类型精确匹配** — 新版 MyBatis-Plus 推荐用 strict 方法
12. **Page 构造参数是 pageNo 和 pageSize** — 不是 offset 和 limit

## Data Privacy
本技能不收集、存储或传输任何用户数据。
