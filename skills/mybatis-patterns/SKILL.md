---
name: mybatis-patterns
description: |
  MyBatis 核心 ORM 技能。覆盖 XML vs 注解 SQL选择、ResultMap复用(extends)、关联查询(association/collection join vs 嵌套select/N+1决策)、分页插件配置、#和$的SQL注入防护、动态SQL(if/where/set/foreach/choose)最佳实践、columnPrefix解决同表多次JOIN。
  当用户编写 MyBatis Mapper XML、处理关联查询、配置分页、防范SQL注入时使用。
license: Apache-2.0
---

# MyBatis 核心 ORM

> 来源：[https://mybatis.org/mybatis-3/](https://mybatis.org/mybatis-3/)  
> GitHub：[https://github.com/mybatis/mybatis-3](https://github.com/mybatis/mybatis-3)

## Capability Boundaries

### ✅ Strong Suits
1. **XML vs 注解选择** — 简单CRUD用注解，复杂查询/动态SQL用XML
2. **ResultMap复用** — extends继承、discriminator鉴别器、columnPrefix 同表多JOIN
3. **关联查询** — association(一对一)/collection(一对多)，Join查询(推荐) vs 嵌套select(N+1风险)
4. **动态SQL** — if/choose/when/otherwise/where/set/foreach/trim/return
5. **防注入** — #{}预编译 vs ${}表名/列名(必须白名单校验)
6. **分页** — RowBounds(不推荐) / PageHelper(推荐) 物理分页
7. **sql片段 + include** — 公共SQL片段复用

### ❌ Out of Scope
1. MyBatis-Plus LambdaWrapper → **mybatis-plus-patterns**
2. Spring Data JPA → **spring-data-jpa**（已有技能）

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 简单CRUD也用XML写 | `@Select("SELECT * FROM user WHERE id=#{id}")` 注解即可 |
| 2 | N+1查询：循环查子表 | Join查询(推荐) 或 association/collection + batch select |
| 3 | `${column}` 动态排序无白名单 | 先检查 columnName 是否在白名单中，否则 SQL 注入 |
| 4 | 不配置 resultMap 用别名映射 | 定义 `<resultMap>` + `<result column="user_name" property="userName"/>` |
| 5 | `SELECT *` 全部字段 | 只查需要的字段（尤其大字段/TEXT/BLOB） |
| 6 | 模糊查询 `LIKE '%${keyword}%'` SQL注入 | `LIKE CONCAT('%', #{keyword}, '%')` 预编译 |
| 7 | 多表 JOIN 不处理列名冲突 | 用别名 + resultMap column 映射 |
| 8 | 不同表 JOIN 同表两次，手动写所有列 | 用 `<association columnPrefix="addr_"` 复用 resultMap |

## 核心模式

### 模式 1: ResultMap 复用 + extends
```xml
<!-- 基础 ResultMap -->
<resultMap id="BaseResultMap" type="com.example.User">
    <id column="id" property="id"/>
    <result column="user_name" property="userName"/>
    <result column="email" property="email"/>
    <result column="status" property="status"/>
</resultMap>

<!-- 继承 + 关联(推荐 Join 方式) -->
<resultMap id="UserWithDept" extends="BaseResultMap" type="com.example.UserVO">
    <association property="dept" javaType="Department"
        resultMap="com.example.DeptMapper.BaseResultMap"
        columnPrefix="dept_"/>  <!-- ← 同名字段加前缀 -->
    <collection property="roles" ofType="Role"
        resultMap="com.example.RoleMapper.BaseResultMap"
        columnPrefix="role_"/>
</resultMap>
```

### 模式 2: Join 查询（推荐，替代嵌套 select）
```xml
<!-- ✅ 推荐：Join 查询 → 一次SQL，无N+1 -->
<select id="selectUserWithDept" resultMap="UserWithDept">
    SELECT u.id, u.user_name, u.email, u.status,
           d.id AS dept_id, d.dept_name AS dept_dept_name,  <!-- ← 加前缀 -->
           r.id AS role_id, r.role_name AS role_role_name
    FROM sys_user u
    LEFT JOIN sys_dept d ON u.dept_id = d.id
    LEFT JOIN sys_user_role ur ON u.id = ur.user_id
    LEFT JOIN sys_role r ON ur.role_id = r.id
    WHERE u.id = #{id}
</select>

<!-- ❌ 避免：嵌套 select 导致 N+1 -->
<resultMap id="UserWithDeptNested" extends="BaseResultMap" type="com.example.UserVO">
    <association property="dept" javaType="Department"
        column="dept_id" select="selectDeptById"/>  <!-- ← 每次查询一个部门 -->
</resultMap>
<!-- 如果查100个用户 → 1(主查询) + 100(部门查询) = 101次SQL -->
```

### 模式 3: 动态 SQL 完整模式
```xml
<select id="findByCondition" resultMap="BaseResultMap">
    SELECT id, user_name, email, status, create_time
    FROM sys_user
    <where>  <!-- ← 自动处理 AND/OR 前缀 -->
        <if test="username != null and username != ''">
            AND user_name LIKE CONCAT('%', #{username}, '%')  <!-- ✅ 防注入 -->
        </if>
        <if test="status != null">
            AND status = #{status}
        </if>
        <if test="deptId != null">
            AND dept_id = #{deptId}
        </if>
    </where>
    <if test="orderBy != null">
        ORDER BY ${orderBy}  <!-- ⚠️ 必须白名单校验 -->
    </if>
</select>

<!-- 批量插入 -->
<insert id="batchInsert">
    INSERT INTO sys_user (user_name, email, status)
    VALUES
    <foreach collection="list" item="user" separator=",">
        (#{user.userName}, #{user.email}, #{user.status})
    </foreach>
</insert>

<!-- 动态更新(set 自动去尾逗号) -->
<update id="updateSelective">
    UPDATE sys_user
    <set>
        <if test="userName != null">user_name = #{userName},</if>
        <if test="email != null">email = #{email},</if>
        <if test="status != null">status = #{status},</if>
    </set>
    WHERE id = #{id}
</update>

<!-- choose/when/otherwise 多分支 -->
<select id="findByCondition" resultMap="BaseResultMap">
    SELECT * FROM sys_user
    <where>
        <choose>
            <when test="queryType == 'name'">AND user_name LIKE CONCAT('%', #{keyword}, '%')</when>
            <when test="queryType == 'email'">AND email = #{keyword}</when>
            <otherwise>AND status = 'ACTIVE'</otherwise>
        </choose>
    </where>
</select>
```

### 模式 4: SQL 片段复用
```xml
<sql id="BaseColumns">
    id, user_name, email, status, create_time, update_time
</sql>

<select id="selectById" resultMap="BaseResultMap">
    SELECT <include refid="BaseColumns"/>
    FROM sys_user WHERE id = #{id}
</select>
```

### 模式 5: 注解方式(简单查询)
```java
@Select("SELECT * FROM sys_user WHERE id = #{id}")
@Results(id = "userMap", value = {
    @Result(column = "user_name", property = "userName"),
    @Result(column = "dept_id", property = "deptId")
})
User findById(Long id);
```

### 模式 6: 排序字段白名单校验
```java
// ✅ 安全：校验排序字段在白名单中
private static final Set<String> SORT_COLUMNS = Set.of(
    "create_time", "update_time", "user_name", "status"
);

public List<User> findByCondition(String orderBy, boolean asc) {
    if (!SORT_COLUMNS.contains(orderBy)) {
        throw new SecurityException("非法排序字段: " + orderBy);
    }
    // 传入 ${orderBy} 安全使用
}
```

## Gotchas
1. **`#{}` 会加引号自动转义，`${}` 直接拼接** — 用户输入必须用 #{}
2. **`${}` 用于动态表名/列名/排序时** — 必须白名单校验，否则 SQL 注入
3. **association 的 select 属性是延迟加载** — 每个关联触发一次查询 = N+1，用 Join 查询替代
4. **resultType 和 resultMap 不能同时使用** — 二选一
5. **Mapper 接口和 XML 必须在同一 package 路径** — 否则配置 mybatis.mapper-locations
6. **Spring Boot 默认开启驼峰映射** — `mybatis.configuration.map-underscore-to-camel-case=true`
7. **@Select/@Results 不定义 @ResultMap ID** — 不能在 XML 中复用
8. **JOIN 查询中 resultMap columnPrefix** — 解决同名字段的唯一方式，比写别名更简洁
9. **`WHERE 1=1` 不如 `<where>`** — `<where>` 自动处理 AND/OR 前缀，更优雅
10. **`<foreach>` 注意 IN 列表为空** — 空列表导致 SQL 语法错误，提前判空
11. **PageHelper 分页的原理是 ThreadLocal** — 分页后必须紧跟查询，中间不能有其他操作
12. **MyBatis 二级缓存慎用** — 跨 session 缓存导致数据不一致，分布式环境不要用

## Data Privacy
本技能不收集、存储或传输任何用户数据。
