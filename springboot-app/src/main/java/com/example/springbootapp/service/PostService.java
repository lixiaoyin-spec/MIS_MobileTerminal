package com.example.springbootapp.service;

import com.example.springbootapp.vo.PostVO;
import java.util.List;

public interface PostService {
    // 发帖
    void createPost(PostVO postVO);

    // 获取帖子列表
    List<PostVO> getPostList();
}