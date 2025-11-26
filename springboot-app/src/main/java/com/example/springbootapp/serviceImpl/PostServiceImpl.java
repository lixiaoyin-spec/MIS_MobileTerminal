package com.example.springbootapp.serviceImpl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springbootapp.po.Post;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.PostRepository;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.PostService;
import com.example.springbootapp.vo.PostVO;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import jakarta.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostServiceImpl implements PostService {

    @Resource
    private PostRepository postRepository;
    @Resource
    private UserRepository userRepository;

    @Override
    public void createPost(PostVO postVO) {
        // 1. 从token中解析用户ID（简化版：实际需用JWT工具解析，这里假设token格式为"TOKEN_uuid_userId"）
        String token = postVO.getToken();
        Assert.isTrue(token.contains("_"), "无效token");
        String userIdStr = token.split("_")[2];
        Long userId = Long.parseLong(userIdStr);

        // 2. 校验用户是否存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. VO转PO，保存帖子
        Post post = new Post();
        post.setUserId(userId);
        post.setTitle(postVO.getTitle());
        post.setContent(postVO.getContent());
        post.setViewCount(0); // 初始浏览量0
        post.setCreateTime(LocalDateTime.now());
        post.setUpdateTime(LocalDateTime.now());
        postRepository.insert(post);
    }

    @Override
    public List<PostVO> getPostList() {
        // 1. 查询所有帖子（按创建时间倒序）
        LambdaQueryWrapper<Post> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Post::getCreateTime);
        List<Post> postList = postRepository.selectList(queryWrapper);

        // 2. PO转VO（补充发帖人昵称）
        return postList.stream().map(post -> {
            PostVO postVO = new PostVO();
            postVO.setId(post.getId());
            postVO.setTitle(post.getTitle());
            postVO.setContent(post.getContent());
            postVO.setCreateTime(post.getCreateTime());
            // 查询发帖人昵称
            User user = userRepository.selectById(post.getUserId());
            postVO.setNickname(user != null ? user.getNickname() : "匿名用户");
            return postVO;
        }).collect(Collectors.toList());
    }
}