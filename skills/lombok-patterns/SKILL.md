---
name: lombok-patterns
description: |
  Lombok 注解使用规则技能。覆盖 @Data/@Builder/@Slf4j 组合规则、@EqualsAndHashCode(callSuper=true)继承陷阱、与Jackson/@Builder/@Jacksonized组合、与MyBatis无参构造器冲突解决、@Value不可变对象、@With对象复制、@SuperBuilder继承Builder。
  纠正 LLM 最常见的 Lombok 误用：不写 callSuper、不加 @Jacksonized、Builder 与继承冲突、@Builder.Default 默认值丢失。
license: Apache-2.0
---

# Lombok 注解使用规则

> 来源：[https://projectlombok.org/features/](https://projectlombok.org/features/)  
> GitHub：[https://github.com/projectlombok/lombok](https://github.com/projectlombok/lombok)

## Capability Boundaries

### ✅ Strong Suits
1. **@Data/@Builder/@Slf4j 组合规则** — 什么时候用哪个，什么时候不能组合
2. **@EqualsAndHashCode(callSuper=true)** — 继承时的正确写法
3. **@Builder + 继承** — Builder 模式在子类中的陷阱与解决(@SuperBuilder)
4. **@Jacksonized + @Builder** — Jackson 反序列化Builder对象的正确配置
5. **MyBatis-Plus 实体注解规则** — @Data/@Builder 与 MyBatis 的兼容性
6. **@Value** — 不可变对象(DTO/VO)的最佳实践
7. **@Builder.Default** — Builder 模式下默认值正确保留
8. **@With** — 不可变对象的"修改"副本

### ❌ Out of Scope
1. Lombok 安装配置 → 参考官方文档
2. Java Records(Java 16+) → 不可变数据载体替代方案

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 子类 `@Data` 不写 `callSuper=true` | `@EqualsAndHashCode(callSuper = true)` |
| 2 | `@Data` + `@Builder` 在一起(MyBatis实体) | 实体不要用 @Builder（破坏无参构造，MyBatis需要） |
| 3 | Jackson 反序列化 @Builder 对象失败(无默认构造器) | 加 `@Jacksonized` 注解 |
| 4 | 父类字段不参与 hashCode/equals | 子类加 `callSuper=true` |
| 5 | 用 `@Builder` 在子类，父类字段无法 build | 用 `@SuperBuilder` 替代(父类+子类都要加) |
| 6 | `@Builder` 默认值被忽略(字段初始化不生效) | 用 `@Builder.Default` 标注默认值字段 |
| 7 | DTO 用 `@Data`（setter 暴露修改） | 用 `@Value`（不可变）或 `@Getter` only |
| 8 | `@Data` 生成 toString 导致循环引用 StackOverflow | `@ToString.Exclude` 排除关联字段 |
| 9 | JPA 实体 `@Data` 导致懒加载 N+1 | JPA 实体用 `@Getter @Setter` + 手写 equals/hashCode |
| 10 | `@AllArgsConstructor` + `@Builder` 重复 | @Builder 自带全参构造器，不需要 @AllArgsConstructor |

## 核心规则速查

### 实体对象（MyBatis/MyBatis-Plus）

```java
// ✅ MyBatis 实体: 用 @Data，不加 @Builder
@Data
@TableName("sys_user")
public class SysUser extends BaseEntity<SysUser> {
    // ⚠️ 继承时 BaseEntity 已声明 @EqualsAndHashCode(callSuper=false)
    private String username;
    // ❌ 不要加 @Builder — MyBatis 需要无参构造器
    // ❌ 不要加 @AllArgsConstructor — @Data 已含 @RequiredArgsConstructor
}

// ✅ 如果必须用 Builder + 实体(需要加所有构造器)
@Data
@Builder
@NoArgsConstructor      // ← MyBatis 需要
@AllArgsConstructor     // ← @Builder 需要
public class UserEntity {
    private String name;
    private Integer age;
}
```

### DTO/VO（不可变对象）

```java
// ✅ DTO/VO — 不可变，适合 API 返回值
@Value
@Builder
@Jacksonized            // ← Jackson 反序列化支持（Lombok 1.18.14+）
public class UserDTO {
    Long id;
    String username;
    @Builder.Default Integer age = 0;  // ← 默认值必须加 @Builder.Default!
}
```

### 继承 + Builder

```java
// ✅ @SuperBuilder — 继承场景的 Builder 方案
@SuperBuilder
@Data
public class Parent {
    private String parentField;
}

@SuperBuilder        // ← 父类和子类都必须加 @SuperBuilder
@Data
@EqualsAndHashCode(callSuper = true)
public class Child extends Parent {
    private String childField;
}
```

### 精确注解（替代 @Data）

```java
// ✅ 精确控制: 用 @Getter @Setter 替代 @Data
@Getter
@Setter
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)  // ← 只包含指定字段
public class UserEntity {
    @EqualsAndHashCode.Include
    private Long id;              // ← 只以 id 做 equals/hashCode
    private String name;
    @ToString.Exclude
    private String password;      // ← toString 中排除
}

// ✅ @With — 不可变对象的"修改"(返回新对象)
@Value
@Builder
@Jacksonized
public class OrderDTO {
    Long id;
    String status;
    
    public OrderDTO withStatus(String newStatus) {
        return new OrderDTO(this.id, newStatus);
    }
}

// ✅ @With 一行搞定(等同上方法)
@Value
@Builder
@Jacksonized
public class OrderDTO {
    Long id;
    @With String status;  // ← 自动生成 withStatus() 返回新对象
}
```

### 日志

```java
// ✅ @Slf4j
@Slf4j
public class UserService {
    public void doSomething() {
        log.info("处理用户: {}", userId);  // 不用写 LoggerFactory.getLogger
    }
}
```

## 组合决策树

```
需要什么?
├── 纯数据类(DTO/VO/返回值)
│   ├── 需要 Builder → @Value + @Builder + @Jacksonized
│   ├── 需要继承   → @SuperBuilder(父+子) + @Value
│   └── 简单数据   → @Value
├── JPA/Hibernate实体
│   ├── 推荐 → @Getter + @Setter + @EqualsAndHashCode(onlyExplicitlyIncluded=true)
│   └── 避免 → @Data (懒加载N+1, toString循环)
├── MyBatis/MyBatis-Plus 实体
│   ├── 无继承 → @Data
│   ├── 有继承 → @Data + @EqualsAndHashCode(callSuper=true)
│   └── 需Builder → @Data + @Builder + @NoArgsConstructor + @AllArgsConstructor
└── 配置类/Service
    └── @Slf4j + @RequiredArgsConstructor (final字段注入)
```

## Gotchas
1. **@Builder 破坏无参构造器** — MyBatis/JPA/Hibernate 需要无参构造器，实体不要用 @Builder 或加 @NoArgsConstructor
2. **@Data 不包含 callSuper** — 子类 equals/hashCode 默认不比较父类字段，必须显式声明
3. **@Jacksonized 只在 @Builder 上生效** — 不加会导致 Jackson 反序列化失败(无默认构造器)
4. **@SuperBuilder 要求所有父类和子类都加** — 缺一个编译报错
5. **@Builder.Default 只在 builder 模式生效** — new 出来的对象 getter 返回 null
6. **@Builder.Default 不会影响无参构造** — 用 new 创建时字段默认值是 Java 默认值(0/null)
7. **@Slf4j 生成的是静态字段** — 不能用 this.log 访问
8. **Lombok 需要 IDE 插件 + annotation processor** — 否则编译期报错
9. **@Data 生成所有 getter/setter** — 敏感字段(密码等)需要手动排除或用 @Getter @Setter 精确控制
10. **@Value 类的所有字段是 final** — 不能有 setter，不能延迟初始化
11. **@ToString 对 JPA 实体有害** — 懒加载字段触发额外查询，循环引用 StackOverflow
12. **@With 只能用在非 final 字段** — 与 @Value 组合时 @With 字段不能是 final

## Data Privacy
本技能不收集、存储或传输任何用户数据。
