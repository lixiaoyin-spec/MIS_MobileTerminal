package com.example.springbootapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.example.springbootapp.po.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CommentRepository extends BaseMapper<Comment> {
    // 按帖子ID查询评论（可用于帖子详情页展示评论列表）
    List<Comment> selectByPostId(@Param("postId") Long postId);
}