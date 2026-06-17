---
name: mapstruct
description: |
  MapStruct Bean 映射技能。覆盖 Mapper 接口定义规范、类型不匹配转换策略、与 Lombok 配合(annotationProcessorPaths)、Spring Component模式注入、嵌套对象映射、反向映射、表达式映射、defaultValue与constant。
  纠正 LLM 最常见的错误：手写 BeanUtils.copyProperties（运行时反射）而非用 MapStruct（编译期生成）。
license: Apache-2.0
---

# MapStruct Bean 映射

> 编码 MapStruct 的使用规则。LLM 会用运行时反射方式做 Bean 映射，编译期生成才是正确方案。

## Capability Boundaries

### ✅ Strong Suits
1. **基础映射** — @Mapping source/target/dateFormat/numberFormat
2. **嵌套映射** — 对象嵌套的自动展开 vs 手动 qualifiedByName
3. **类型转换** — 日期/数字/枚举/String 互转
4. **Lombok 配合** — annotationProcessorPaths 配置
5. **Spring注入** — componentModel="spring"
6. **表达式映射** — expression 处理复杂转换
7. **defaultValue/constant** — 默认值和常量

### ❌ Out of Scope
1. DDD4J 使用 Dozer 不是 MapStruct → **ddd4j-core**（DDD4J项目中Doozer已注入）
2. 运行时动态映射 → 用 MapStruct 编译期生成，不是反射

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | `BeanUtils.copyProperties(dto, entity)` | MapStruct Mapper 接口，编译期生成代码 |
| 2 | 手写 `entity.setName(dto.getName()); entity.setAge(dto.getAge())` | 一个 @Mapping 搞定，30个字段也不怕 |
| 3 | Lombok 和 MapStruct 冲突编译失败 | Lombok 放在 annotationProcessorPaths 最前面 |
| 4 | 日期字段 String ↔ LocalDateTime 手动转换 | `@Mapping(dateFormat = "yyyy-MM-dd HH:mm:ss")` |
| 5 | 嵌套对象映射不了 | `@Mapping(target = "address.street", source = "addr")` |
| 6 | 不知道反向映射 | `@InheritInverseConfiguration` 自动反向 |

## 核心规则速查

```java
// ✅ Mapper 定义
@Mapper(componentModel = "spring")  // Spring 管理的单例
public interface UserMapper {
    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    @Mapping(target = "createTime", dateFormat = "yyyy-MM-dd HH:mm:ss")
    @Mapping(target = "status", expression = "java(dto.getStatus() == 1)")
    @Mapping(target = "fullName", source = "name")
    UserVO toVO(User entity);

    @InheritInverseConfiguration  // 自动反向映射
    User toEntity(UserVO vo);

    List<UserVO> toVOList(List<User> entities);  // List 自动映射
}

// ✅ 使用
@Autowired UserMapper userMapper;
UserVO vo = userMapper.toVO(userEntity);
List<UserVO> voList = userMapper.toVOList(users);

// ✅ Maven 配置(Lombok 配合)
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <annotationProcessorPaths>
            <path><groupId>org.projectlombok</groupId>  <!-- Lombok 必须第一个 -->
                <artifactId>lombok</artifactId></path>
            <path><groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId></path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

## Gotchas
1. **Lombok 的 annotationProcessor 必须排在 MapStruct 前面** — 否则编译报错
2. **MapStruct 编译期生成实现类** — 不生成时检查 target/generated-sources/annotations
3. **source 和 target 字段名不一致必须指定 @Mapping** — 否则静默跳过
4. **嵌套对象默认使用同名的嵌套 Mapper** — 没有同名的需要手动 qualifiedByName
5. **List 映射自动复用单个映射方法** — 不需要额外配置
6. **componentModel="spring" 是单例** — 不要在 Mapper 中维护状态
7. **@Mapping 的 expression 是 Java 代码字符串** — 复杂逻辑提取为方法用 qualifiedByName

## Data Privacy
本技能不收集、存储或传输任何用户数据。
