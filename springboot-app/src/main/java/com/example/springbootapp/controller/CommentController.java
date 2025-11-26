package com.example.springbootapp.controller;

import com.example.springbootapp.service.CommentService;
import com.example.springbootapp.vo.CommentVO;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/comment")
public class CommentController {

    @Resource
    private CommentService commentService;

    // 添加评论接口
    @PostMapping("/add")
    public Map<String, Object> add(@Valid @RequestBody CommentVO commentVO) {
        commentService.addComment(commentVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "评论成功");
        result.put("data", null);
        return result;
    }
}