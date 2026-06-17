# MyBatis 实战示例

```java
// ResultMap 复用
<resultMap id="BaseResultMap" type="com.example.User">
    <id column="id" property="id"/>
    <result column="user_name" property="userName"/>
</resultMap>
<resultMap id="UserWithDept" extends="BaseResultMap" type="com.example.UserVO">
    <association property="dept" javaType="Department" column="dept_id" select="selectDeptById"/>
</resultMap>

// 动态SQL防注入
<select id="findByCondition" resultMap="BaseResultMap">
    SELECT * FROM sys_user
    <where>
        <if test="username != null">AND user_name LIKE CONCAT('%',#{username},'%')</if>
    </where>
    ORDER BY ${orderBy}  <!-- 必须白名单校验 -->
</select>
```

---

> 来源：[https://mybatis.org/mybatis-3/](https://mybatis.org/mybatis-3/)
