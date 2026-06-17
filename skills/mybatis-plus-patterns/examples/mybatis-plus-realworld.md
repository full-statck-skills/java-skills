# MyBatis-Plus 实战示例

## 示例 1：Lambda 查询 + 分页

```java
@Service
public class UserService extends ServiceImpl<UserMapper, User> {
    public IPage<UserVO> search(UserQuery query) {
        Page<User> page = new Page<>(query.getPageNo(), query.getPageSize());
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<User>()
            .like(StringUtils.hasText(query.getKeyword()), User::getUsername, query.getKeyword())
            .eq(query.getStatus() != null, User::getStatus, query.getStatus())
            .ge(query.getBeginTime() != null, User::getCreateTime, query.getBeginTime())
            .orderByDesc(User::getCreateTime);
        IPage<User> result = page(page, wrapper);
        return result.convert(userMapper::toVO);
    }
}
```

## 示例 2：乐观锁更新

```java
@Data
@TableName("inventory")
public class Inventory extends Model<Inventory> {
    @TableId private Long id;
    private Integer quantity;
    @Version private Integer version;  // 乐观锁
}

@Service
public class InventoryService {
    @Transactional
    public boolean deduct(Long id, int count) {
        Inventory inv = getById(id);
        if (inv.getQuantity() < count) return false;
        inv.setQuantity(inv.getQuantity() - count);
        return updateById(inv);  // WHERE version = oldVersion，失败则版本冲突
    }
}
```

## 示例 3：逻辑删除 + 自动填充

```java
@Data
@TableName("sys_user")
public class SysUser extends Model<SysUser> {
    @TableId(type = IdType.AUTO) private Long id;
    private String username;
    @TableLogic private Integer isDeleted;  // 0=正常，1=已删除
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updateTime;
}

// 删除 → UPDATE sys_user SET is_deleted=1 WHERE id=?
userService.removeById(1L);
// 查询自动带 is_deleted=0
userService.list();  // WHERE is_deleted=0
```

---

> 来源：[https://baomidou.com/](https://baomidou.com/)
