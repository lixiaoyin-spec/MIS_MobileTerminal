package com.example.springbootapp.controller;

import com.example.springbootapp.service.CommentService;
import com.example.springbootapp.vo.CommentVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.HashMap;
import java.util.List;
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

    // 根据帖子ID获取评论列表接口
    @GetMapping("/list")
    public Map<String, Object> getCommentsByPostId(
            @NotNull(message = "帖子ID不能为空") @RequestParam("postId") Long postId) {
        List<CommentVO> commentList = commentService.getCommentsByPostId(postId);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "查询成功");
        result.put("data", commentList);
        return result;
    }
}