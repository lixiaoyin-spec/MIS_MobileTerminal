package com.example.springbootapp.controller;

import com.example.springbootapp.service.PostService;
import com.example.springbootapp.vo.PostDetailVO;
import com.example.springbootapp.vo.PostVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/post")
public class PostController {

    @Resource
    private PostService postService;

    // 发帖接口（请求体：token+title+content）
    @PostMapping("/create")
    public Map<String, Object> create(@Valid @RequestBody PostVO postVO) {
        postService.createPost(postVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "发帖成功");
        result.put("data", null);
        return result;
    }

    // 帖子列表接口（返回content字段）
    @GetMapping("/list")
    public Map<String, Object> getList() {
        List<PostVO> postList = postService.getPostList();
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "查询成功");
        result.put("data", postList);
        return result;
    }

    // 帖子详情接口（包含帖子信息和评论列表）
    @GetMapping("/detail")
    public Map<String, Object> getDetail(
            @RequestParam("postId") Long postId) {
        PostDetailVO postDetail = postService.getPostDetail(postId);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "查询成功");
        result.put("data", postDetail);
        return result;
    }
}