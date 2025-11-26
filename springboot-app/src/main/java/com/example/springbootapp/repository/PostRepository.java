package com.example.springbootapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.springbootapp.po.Post;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PostRepository extends BaseMapper<Post> {
    // 继承BaseMapper，包含CRUD基础方法
}