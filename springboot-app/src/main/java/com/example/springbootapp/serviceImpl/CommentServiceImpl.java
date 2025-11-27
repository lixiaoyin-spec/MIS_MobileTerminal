package com.example.springbootapp.serviceImpl;

import com.example.springbootapp.po.Comment;
import com.example.springbootapp.po.Post;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.CommentRepository;
import com.example.springbootapp.repository.PostRepository;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.CommentService;
import com.example.springbootapp.vo.CommentVO;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import jakarta.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CommentServiceImpl implements CommentService {

    @Resource
    private CommentRepository commentRepository;
    @Resource
    private PostRepository postRepository;
    @Resource
    private UserRepository userRepository;

    @Override
    public void addComment(CommentVO commentVO) {
        // 1. 从token解析用户ID（复用登录时的token格式："TOKEN_uuid_userId"）
        String token = commentVO.getToken();
        Assert.isTrue(token.contains("_") && token.split("_").length >= 3, "无效token");
        Long userId = Long.parseLong(token.split("_")[2]);

        // 2. 校验用户是否存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. 校验帖子是否存在
        Long postId = commentVO.getPostId();
        Post post = postRepository.selectById(postId);
        Assert.notNull(post, "帖子不存在或已删除");

        // 4. VO转PO，保存评论
        Comment comment = new Comment();
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(commentVO.getContent());
        comment.setCreateTime(LocalDateTime.now());
        commentRepository.insert(comment);
    }

    @Override
    public List<CommentVO> getCommentsByPostId(Long postId) {
        // 1. 校验帖子是否存在
        Post post = postRepository.selectById(postId);
        Assert.notNull(post, "帖子不存在或已删除");

        // 2. 查询该帖子下的所有评论
        List<Comment> comments = commentRepository.selectByPostId(postId);

        // 3. PO转VO，关联用户表获取昵称
        return comments.stream().map(comment -> {
            CommentVO vo = new CommentVO();
            vo.setId(comment.getId());
            vo.setPostId(comment.getPostId());
            vo.setContent(comment.getContent());
            vo.setCreateTime(comment.getCreateTime());

            // 查询评论人信息获取昵称
            User user = userRepository.selectById(comment.getUserId());
            if (user != null) {
                vo.setNickname(user.getNickname());
            }

            return vo;
        }).collect(Collectors.toList());
    }
}