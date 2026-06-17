---
name: mybatis-plus
description: |
  MyBatis-Plus 增强 ORM 技能。覆盖 LambdaQueryWrapper vs QueryWrapper选择、分页插件配置、乐观锁(@Version)、逻辑删除(@TableLogic)、自动填充(@TableField fill)、ActiveRecord vs Mapper模式选择、代码生成器模板。
  当用户使用 MyBatis-Plus 进行数据库操作、配置分页乐观锁、选择查询方式时使用。
  与 mybatis 技能互补：mybatis 侧重XML/ResultMap/SQL写法，mybatis-plus 侧重增强功能。
license: Apache-2.0
---

# MyBatis-Plus 增强 ORM

> 编码 MyBatis-Plus 的使用规则。LLM 用字符串字段名而非 Lambda、不配置乐观锁、不用 ActiveRecord。

## Capability Boundaries

### ✅ Strong Suits
1. **LambdaQueryWrapper** — 类型安全的查询(不用写字符串字段名)
2. **分页插件** — PaginationInnerInterceptor 配置与使用
3. **乐观锁** — @Version + OptimisticLockerInnerInterceptor
4. **逻辑删除** — @TableLogic 全局配置 vs 单表配置
5. **自动填充** — @TableField(fill = FieldFill.INSERT)
6. **ActiveRecord vs Mapper** — Entity extends Model vs 独立 Mapper 接口选择

### ❌ Out of Scope
1. MyBatis XML/ResultMap/动态SQL → **mybatis**
2. MyBatis-Plus Generator 代码生成 → 已有 **mybatis-plus-generator** 技能

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `eq("user_name", username)` 字符串字段名 | `eq(User::getUsername, username)` Lambda |
| 2 | 只用 PageHelper 不分页 | 用 IPage + PaginationInnerInterceptor |
| 3 | 不配置乐观锁导致并发覆盖 | @Version + OptimisticLockerInnerInterceptor |
| 4 | `UPDATE SET is_deleted = 1` 手动删除 | @TableLogic 自动转 UPDATE |
| 5 | 不知道 ActiveRecord 模式 | extends Model<T> → entity.insert/updateById/selectById |
| 6 | 不防全表更新/删除 | BlockAttackInnerInterceptor 阻止无where的UPDATE/DELETE |

## 核心规则速查

```java
// ✅ Lambda 查询(类型安全)
List<User> adults = userService.lambdaQuery()
    .ge(User::getAge, 18)
    .in(User::getStatus, Arrays.asList(1, 2))
    .orderByDesc(User::getCreateTime)
    .list();

// ✅ 分页
Page<User> page = new Page<>(1, 15);  // 第1页，15条
IPage<User> result = userService.page(page,
    new LambdaQueryWrapper<User>().ge(User::getAge, 18));

// ✅ 乐观锁 + 逻辑删除 配置
@Configuration
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor interceptor() {
        MybatisPlusInterceptor i = new MybatisPlusInterceptor();
        i.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        i.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        i.addInnerInterceptor(new BlockAttackInnerInterceptor());
        return i;
    }
}

// ✅ Entity配置
@Data
@TableName("sys_user")
public class User extends Model<User> {  // ActiveRecord
    @TableId(type = IdType.AUTO)
    private Long id;
    @Version private Integer version;        // 乐观锁
    @TableLogic private Integer isDeleted;   // 逻辑删除
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;        // 插入自动填充
}

// ✅ ActiveRecord vs Mapper
User user = new User();
user.insert();        // ActiveRecord: entity直接操作
userService.save(user); // Mapper: 通过Service操作
```

## Gotchas
1. **LambdaQueryWrapper 需要注解处理器生成元数据** — 否则 Lambda 表达式无法解析字段名
2. **乐观锁 @Version 字段类型支持 int/Integer/long/Long/Date/LocalDateTime/Timestamp**
3. **@TableLogic 影响所有删除操作** — deleteById/deleteBatchIds 都会变成 UPDATE
4. **BlockAttackInnerInterceptor 阻止全表更新** — 开发阶段建议开启
5. **分页插件在 PageHelper 存在时可能冲突** — 二选一，推荐 MyBatis-Plus 的分页
6. **ActiveRecord 模式 Entity 必须 extends Model** — 否则没有 insert/updateById 等方法
7. **逻辑删除后的查询自动带 is_deleted=0** — 如果需要查已删除的数据，用 `eq(User::getDeleted, 1)`
8. **自动填充需要 MetaObjectHandler** — 配置 createTime/updateTime 的填充逻辑

## Data Privacy
本技能不收集、存储或传输任何用户数据。
