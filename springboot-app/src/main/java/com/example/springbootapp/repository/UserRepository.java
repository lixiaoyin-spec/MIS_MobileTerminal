package com.example.springbootapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.springbootapp.po.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper // 标识为MyBatis映射接口
public interface UserRepository extends BaseMapper<User> {
    // 按用户名查询用户（自定义查询方法）
    User selectByUsername(@Param("username") String username);
}