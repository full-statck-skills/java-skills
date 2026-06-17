# MapStruct 实战示例

## 示例 1：标准 DTO ↔ Entity 映射

```java
@Mapper(componentModel = "spring", injectionStrategy = InjectionStrategy.CONSTRUCTOR)
public interface UserMapper {
    @Mapping(target = "createTime", dateFormat = "yyyy-MM-dd HH:mm:ss")
    @Mapping(target = "statusName", expression = "java(StatusEnum.from(e.getStatus()).getDesc())")
    UserVO toVO(User entity);

    @InheritInverseConfiguration
    @Mapping(target = "password", ignore = true)  // 反向映射时忽略密码
    User toEntity(UserVO vo);

    List<UserVO> toVOList(List<User> entities);
}

// Controller 中使用
@RestController
public class UserController {
    @Autowired UserMapper userMapper;
    @GetMapping("/users")
    public List<UserVO> list() {
        return userMapper.toVOList(userService.list());
    }
}
```

## 示例 2：嵌套映射 + @Named vs @Qualifier

```java
@Qualifier @Target(ElementType.METHOD) @Retention(RetentionPolicy.CLASS)
public @interface MaskPhone {}
@Qualifier @Target(ElementType.METHOD) @Retention(RetentionPolicy.CLASS)
public @interface ToChineseDate {}

@Mapper(componentModel = "spring")
public interface OrderMapper {
    @Mapping(target = "user.phone", source = "user.phone", qualifiedBy = MaskPhone.class)
    @Mapping(target = "createTime", source = "createTime", qualifiedBy = ToChineseDate.class)
    OrderVO toVO(Order entity);

    // ✅ 自定义 Qualifier 注解(IDE 重构安全)
    @MaskPhone
    default String maskPhone(String phone) {
        return phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2");
    }
    @ToChineseDate
    default String toChineseDate(LocalDateTime dt) {
        return dt.format(DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm"));
    }
}
```

## 示例 3：抽象类 Mapper（需要注入依赖）

```java
@Mapper(componentModel = "spring")
public abstract class UserMapper {
    @Autowired protected PasswordEncoder encoder;

    @Mapping(target = "password", expression = "java(encoder.encode(dto.getRawPassword()))")
    public abstract User toEntity(RegisterDTO dto);
}
```

---

> 来源：[https://mapstruct.org/documentation/stable/reference/html/](https://mapstruct.org/documentation/stable/reference/html/)
