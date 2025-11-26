package com.example.springbootapp.service;

import com.example.springbootapp.vo.CommentVO;

public interface CommentService {
    // 添加评论
    void addComment(CommentVO commentVO);
}