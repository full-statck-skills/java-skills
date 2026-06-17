---
name: mapstruct-patterns
description: |
  MapStruct 最佳实践模式。从官方 Reference Guide 提炼，覆盖 Mapper 三种定义方式(接口/抽象类/default方法)、Spring 注入策略(CONSTRUCTOR推荐/SETTER解决循环依赖)、嵌套映射模式(显式子方法 > dot notation 一次性配置)、@Qualifier > @Named 的安全选择、Lombok 集成规则、@MappingComposition 谨慎使用。
  纠正 LLM 最常见的错误：用反射 BeanUtils 而非编译期 MapStruct、嵌套映射全写在一个方法、不知 SETTER 解决循环依赖。
license: Apache-2.0
---

# MapStruct 最佳实践模式

> 来源: [MapStruct Reference Guide](https://mapstruct.org/documentation/stable/reference/html/) | GitHub: [mapstruct/mapstruct](https://github.com/mapstruct/mapstruct)

## Capability Boundaries

### ✅ Strong Suits
1. **Mapper 三种定义方式** — 接口(标准) / 抽象类(需要字段) / default方法(自定义逻辑)
2. **Spring 注入策略** — CONSTRUCTOR(推荐，测试友好) / SETTER(解决循环依赖)
3. **嵌套映射模式** — 显式子方法封装(推荐) > dot notation 一次性配置
4. **@Qualifier vs @Named** — 自定义 @Qualifier 注解(IDE重构安全) > @Named(字符串不安全)
5. **Lombok 集成** — annotationProcessorPaths 中 Lombok 必须在 MapStruct 之前
6. **@MappingComposition** — 组合注解复用，但 error messages 不成熟需谨慎

### ❌ Out of Scope
1. 运行时动态 Bean 映射(Orika/Dozer) → MapStruct 编译期生成，不是反射

## 核心模式

### 模式 1: Spring 注入策略选择

```java
// ✅ 推荐：CONSTRUCTOR 注入(测试友好，不依赖Spring容器)
@Mapper(componentModel = "spring", injectionStrategy = InjectionStrategy.CONSTRUCTOR)
public interface UserMapper { UserVO toVO(User e); }

// ✅ 循环依赖：SETTER注入
@Mapper(componentModel = "spring", injectionStrategy = InjectionStrategy.SETTER,
        uses = { OrderMapper.class })
public interface UserMapper { ... }

// ✅ 全局默认配置(避免每个接口重复)
@MapperConfig(componentModel = "spring", injectionStrategy = InjectionStrategy.CONSTRUCTOR)
public interface CentralConfig {}
@Mapper(config = CentralConfig.class) public interface UserMapper { ... }
```

### 模式 2: 嵌套映射的正确方式

```java
// ❌ 反模式：全写在顶层(重复配置，难以维护)
@Mapping(target = "address.street", source = "home.street")
@Mapping(target = "address.city", source = "home.city")
UserDTO toDTO(User e);

// ✅ 模式：显式子方法(单一配置点，可复用)
@Mapper
public interface UserMapper {
    UserDTO toDTO(User e);               // MapStruct 自动检测嵌套类型
    AddressDTO toAddressDTO(Address e);   // 子映射方法 — 唯一配置处
}

// ✅ dot notation + 子方法组合(局部覆盖)
@Mapping(target = "address.zip", constant = "00000")  // 常量覆盖
@Mapping(target = "address", source = "homeAddr")     // 其余走子方法
UserDTO toDTO(User e);
```

### 模式 3: @Qualifier > @Named

```java
// ✅ 推荐：自定义 @Qualifier(IDE重构安全)
@Qualifier @Target(ElementType.METHOD) @Retention(RetentionPolicy.CLASS)
public @interface ToUpperCase {}
@ToUpperCase default String toUpper(String s) { return s.toUpperCase(); }
@Mapping(target = "name", qualifiedBy = ToUpperCase.class)
UserDTO toDTO(User e);

// ⚠️ 可用但不推荐：@Named(字符串依赖，IDE不能自动重命名)
@Named("toUpper") default String toUpper(String s) { return s.toUpperCase(); }
@Mapping(target = "name", qualifiedByName = "toUpper")  // 字符串引用
```

### 模式 4: 循环依赖的 Spring 配置

```java
// 场景: UserMapper → OrderMapper → UserMapper
@Mapper(componentModel = "spring", injectionStrategy = InjectionStrategy.SETTER,
        uses = { OrderMapper.class })  // ← SETTER是关键
public interface UserMapper {
    @Mapping(target = "orders", source = "orderList")
    UserDTO toDTO(User entity);
}
@Mapper(componentModel = "spring", injectionStrategy = InjectionStrategy.SETTER,
        uses = { UserMapper.class })
public interface OrderMapper { ... }
```

### 模式 5: 抽象类 Mapper

```java
@Mapper
public abstract class UserMapper {
    @Autowired protected PasswordEncoder encoder;  // 可注入字段
    @Mapping(target = "encodedPwd", expression = "java(encoder.encode(dto.getPassword()))")
    public abstract UserVO toVO(UserDTO dto);
    protected String formatDate(LocalDateTime dt) { return dt.format(FORMATTER); } // 自定义方法
}
```

## Gotchas
1. **Lombok 的 annotationProcessor 必须在 MapStruct 之前** — 否则编译期找不到 getter/setter
2. **CONSTRUCTOR 注入遇循环依赖会编译失败** — 改为 SETTER
3. **dot notation 不创建子映射方法** — 嵌套字段逻辑重复时用显式子方法
4. **MapStruct 编译期生成，性能等同手写代码** — 不是反射
5. **@Named 字符串引用不安全** — IDE重构不会自动更新，用自定义 @Qualifier
6. **CollectionMappingStrategy.DEFAULT 不要显式使用** — 仅作内部区分
7. **Mapper 接口中 default 方法优先于生成代码** — 可用于自定义转换逻辑

## Data Privacy
本技能不收集、存储或传输任何用户数据。
