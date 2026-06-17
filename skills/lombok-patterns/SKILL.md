---
name: lombok-patterns
description: |
  Lombok 注解使用规则技能。覆盖 @Data/@Builder/@Slf4j 组合规则、@EqualsAndHashCode(callSuper=true)继承陷阱、与Jackson/@Builder/@Jacksonized组合、与MyBatis无参构造器冲突解决、@Value不可变对象、@With对象复制。
  纠正 LLM 最常见的 Lombok 误用：不写 callSuper、不加 @Jacksonized、Builder 与继承冲突。
license: Apache-2.0
---

# Lombok 注解使用规则

> 编码 Lombok 的正确使用规则。LLM 熟悉 Lombok 但频繁犯组合错误——这些错误在编译期才暴露。

## Capability Boundaries

### ✅ Strong Suits
1. **@Data/@Builder/@Slf4j 组合规则** — 什么时候用哪个，什么时候不能组合
2. **@EqualsAndHashCode(callSuper=true)** — 继承时的正确写法
3. **@Builder + 继承** — Builder 模式在子类中的陷阱与解决(@SuperBuilder)
4. **@Jacksonized + @Builder** — Jackson 反序列化Builder对象的正确配置
5. **MyBatis-Plus 实体注解规则** — @Data/@Builder 与 MyBatis 的兼容性
6. **@Value** — 不可变对象(DTO/VO)的最佳实践

### ❌ Out of Scope
1. Lombok 安装配置 → 参考官方文档

## LLM最常犯的错误

| # | 错误 | 正确做法 |
|---|------|---------|
| 1 | 子类 `@Data` 不写 `callSuper=true` | `@EqualsAndHashCode(callSuper = true)` |
| 2 | `@Data` + `@Builder` 在一起(MyBatis实体) | 实体不要用 @Builder（破坏无参构造，MyBatis需要） |
| 3 | Jackson 反序列化 @Builder 对象失败(无默认构造器) | 加 `@Jacksonized` 注解 |
| 4 | 父类字段不参与 hashCode | 加 `callSuper=true` |
| 5 | 用 `@Builder` 在子类，父类字段无法 build | 用 `@SuperBuilder` 替代 |
| 6 | `@AllArgsConstructor` 与 `@Builder` 同时使用 | @Builder 自带全参构造器，不需要 @AllArgsConstructor |
| 7 | DTO 用 `@Data`（setter 暴露修改） | 用 `@Value`（不可变）或 `@Getter` only |

## 核心规则速查

```java
// ✅ 实体对象(MyBatis实体)
@Data
@TableName("sys_user")
public class SysUser extends BaseEntity<SysUser> {  // 继承时注意
    // ✅ 继承+@Data → 必须加 callSuper=true
    // BaseEntity 已通过 @EqualsAndHashCode(callSuper=false) 声明
    private String username;  // @Data 自动生成 getter/setter/toString/equals/hashCode
    // ❌ 不要加 @Builder — MyBatis需要无参构造器
    // ❌ 不要加 @AllArgsConstructor — @Data 已含 @RequiredArgsConstructor
}

// ✅ DTO/VO(不可变) — 适合 API 返回值
@Value
@Builder
@Jacksonized  // Jackson 反序列化支持
public class UserDTO {
    Long id;
    String username;
    @Builder.Default Integer age = 0;  // Builder 默认值
}

// ✅ 有继承的Builder
@SuperBuilder
@Data
public class Child extends Parent {
    private String childField;
}

// ✅ Slf4j日志 — 每个类一个
@Slf4j
public class UserService {
    public void doSomething() {
        log.info("处理用户: {}", userId);  // 不用写 LoggerFactory.getLogger
    }
}
```

## Gotchas
1. **@Builder 破坏无参构造器** — MyBatis/JPA/Hibernate 需要无参构造器，实体不要用 @Builder
2. **@Data 不包含 callSuper** — 子类 equals/hashCode 默认不比较父类字段
3. **@Jacksonized 只在 @Builder 上生效** — 不加会导致 Jackson 反序列化失败(无默认构造器)
4. **@SuperBuilder 要求所有父类和子类都加** — 缺一个编译报错
5. **@Builder.Default 只在 builder 模式生效** — new 出来的对象 getter 返回 null
6. **@Slf4j 生成的是静态字段** — 不能用 this.log 访问
7. **Lombok 需要 IDE 插件 + annotation processor** — 否则编译期报错
8. **@Data 生成所有 getter/setter** — 敏感字段(密码等)需要手动排除

## Data Privacy
本技能不收集、存储或传输任何用户数据。
