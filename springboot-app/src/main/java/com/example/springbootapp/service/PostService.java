package com.example.springbootapp.service;

import com.example.springbootapp.vo.PostDetailVO;
import com.example.springbootapp.vo.PostVO;
import java.util.List;

public interface PostService {
    // 发帖
    void createPost(PostVO postVO);

    // 获取帖子列表
    List<PostVO> getPostList();

    // 按标题搜索帖子（模糊匹配）
    List<PostVO> searchPostsByTitle(String title);

    // 按浏览量排序帖子（order: asc/desc）
    List<PostVO> getPostListByViewCount(String order);

    // 获取帖子详情（包含帖子信息和评论列表）
    PostDetailVO getPostDetail(Long postId);
}