---
name: mybatis
description: |
  MyBatis 核心 ORM 技能。覆盖 XML vs 注解 SQL选择、ResultMap复用、关联查询(association/collection)N+1解决方案、分页插件配置、#和$的SQL注入防护、动态SQL最佳实践。
  当用户编写 MyBatis Mapper XML、处理关联查询、配置分页、防范SQL注入时使用。
license: Apache-2.0
---

# MyBatis 核心 ORM

> 编码 MyBatis 的使用规则。LLM 用注解写SQL、不处理N+1查询、忘记分页、模板复制XML。

## Capability Boundaries

### ✅ Strong Suits
1. **XML vs 注解选择** — 简单CRUD用注解，复杂查询用XML
2. **ResultMap复用** — extends继承、discriminator鉴别器
3. **关联查询** — association(一对一)/collection(一对多)，N+1解决方案
4. **动态SQL** — if/choose/where/set/foreach/trim 组合模式
5. **防注入** — #{}预编译 vs ${}表名/列名(必须白名单校验)
6. **分页** — PageHelper 或 MyBatis-Plus 分页插件

### ❌ Out of Scope
1. MyBatis-Plus LambdaWrapper → **mybatis-plus**
2. Spring Data JPA → **spring-data-jpa**（已有技能）

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 简单CRUD也用XML写 | `@Select("SELECT * FROM user WHERE id=#{id}")` |
| 2 | N+1查询：循环查子表 | association/collection + `fetchType="eager"` 或批量查询 |
| 3 | `${column}` 动态排序无白名单 | 先检查 columnName 是否在白名单中 |
| 4 | 不配置 resultMap 用别名映射 | 定义 `<resultMap>` + `<result column="user_name" property="userName"/>` |
| 5 | `SELECT *` 全部字段 | 只查需要的字段（尤其大字段/外键） |
| 6 | 模糊查询 `LIKE '%${keyword}%'` SQL注入 | `LIKE CONCAT('%', #{keyword}, '%')` |

## 核心规则速查

```xml
<!-- ✅ ResultMap 复用(extends) -->
<resultMap id="BaseResultMap" type="com.example.User">
    <id column="id" property="id"/>
    <result column="user_name" property="userName"/>
</resultMap>
<resultMap id="UserWithDept" extends="BaseResultMap" type="com.example.UserVO">
    <association property="dept" javaType="Department"
        column="dept_id" select="selectDeptById"/>
    <collection property="roles" ofType="Role"
        column="id" select="selectRolesByUserId"/>
</resultMap>

<!-- ✅ 动态SQL -->
<select id="findByCondition" resultMap="BaseResultMap">
    SELECT * FROM sys_user
    <where>
        <if test="username != null and username != ''">
            AND user_name LIKE CONCAT('%', #{username}, '%')
        </if>
        <if test="status != null">
            AND status = #{status}
        </if>
    </where>
    <if test="orderBy != null">
        ORDER BY ${orderBy}  <!-- ⚠️ 必须白名单校验 -->
    </if>
</select>
```

```java
// ✅ 注解方式(简单查询)
@Select("SELECT * FROM sys_user WHERE id = #{id}")
@Results(id = "userMap", value = {
    @Result(column = "user_name", property = "userName"),
    @Result(column = "dept_id", property = "dept",
        one = @One(select = "selectDeptById"))
})
User findById(Long id);
```

## Gotchas
1. **`#{}` 会加引号自动转义，`${}` 直接拼接** — 用户输入必须用 #{}
2. **`${}` 用于动态表名/列名/排序时** — 必须白名单校验，否则 SQL 注入
3. **association 的 select 是延迟加载** — 每个关联触发一次查询 = N+1，用 join 或 批量查询替代
4. **resultType 和 resultMap 不能同时使用** — 二选一
5. **Mapper 接口和 XML 必须在同一路径** — 否则配置 mybatis.mapper-locations
6. **Spring Boot 默认开启驼峰映射** — `mybatis.configuration.map-underscore-to-camel-case=true`
7. **@Select/@Results 不定义 @ResultMap ID** — 不能在 XML 中复用

## Data Privacy
本技能不收集、存储或传输任何用户数据。
