package com.example.springbootapp.service;

import com.example.springbootapp.vo.CommentVO;

import java.util.List;

public interface CommentService {
    // 添加评论
    void addComment(CommentVO commentVO);

    // 根据帖子ID获取评论列表
    List<CommentVO> getCommentsByPostId(Long postId);
}