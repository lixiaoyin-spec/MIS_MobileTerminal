package com.example.springbootapp.serviceImpl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.UserService;
import com.example.springbootapp.vo.UserVO;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import jakarta.annotation.Resource;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class UserServiceImpl implements UserService {

    @Resource
    private UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public void register(UserVO userVO) {
        // 1. 校验用户名是否已存在
        User existUser = userRepository.selectByUsername(userVO.getUsername());
        Assert.isNull(existUser, "用户名已存在");

        // 2. 密码加密，VO转PO
        User user = new User();
        user.setUsername(userVO.getUsername());
        user.setPassword(passwordEncoder.encode(userVO.getPassword()));
        user.setNickname(userVO.getNickname());
        user.setMajor(userVO.getMajor());
        user.setGrade(userVO.getGrade());
        user.setInterestTags(userVO.getInterestTags());
        user.setRole("STUDENT"); // 默认普通学习者
        user.setStatus(1); // 账号启用
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());

        // 3. 保存到数据库
        userRepository.insert(user);
    }

    @Override
    public UserVO login(UserVO userVO) {
        // 1. 查询用户
        User user = userRepository.selectByUsername(userVO.getUsername());
        Assert.notNull(user, "用户名或密码错误");

        // 2. 密码校验
        boolean pwdMatch = passwordEncoder.matches(userVO.getPassword(), user.getPassword());
        Assert.isTrue(pwdMatch, "用户名或密码错误");

        // 3. 生成Token，PO转VO
        String token = "TOKEN_" + UUID.randomUUID() + "_" + user.getId();
        UserVO resultVO = new UserVO();
        resultVO.setId(user.getId());
        resultVO.setNickname(user.getNickname());
        resultVO.setMajor(user.getMajor());
        resultVO.setRole(user.getRole());
        resultVO.setInterestTags(user.getInterestTags());
        resultVO.setToken(token);

        return resultVO;
    }
}