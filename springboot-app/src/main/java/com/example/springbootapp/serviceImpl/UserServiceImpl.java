package com.example.springbootapp.serviceImpl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.security.TokenService;
import com.example.springbootapp.security.TokenUser;
import com.example.springbootapp.service.UserService;
import com.example.springbootapp.vo.LoginVO;
import com.example.springbootapp.vo.TagVO;
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
    @Resource
    private TokenService tokenService;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // 注册：存储标签到interest_tags字段
    @Override
    public void register(UserVO userVO) {
        // 1. 校验用户名是否已存在
        User existUser = userRepository.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, userVO.getUsername()));
        Assert.isNull(existUser, "用户名已存在");

        // 2. 密码加密+VO转PO（存储标签）
        User user = new User();
        user.setUsername(userVO.getUsername());
        user.setPassword(passwordEncoder.encode(userVO.getPassword()));
        user.setNickname(userVO.getNickname());
        user.setMajor(userVO.getMajor());
        user.setGrade(userVO.getGrade());
        user.setInterestTags(userVO.getInterestTags()); // 存储注册时的标签
        user.setRole("STUDENT");
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());

        // 3. 保存到数据库
        userRepository.insert(user);
    }

    // 登录：返回token和用户信息
    @Override
    public UserVO login(LoginVO loginVO) {
        // 1. 查询用户
        User user = userRepository.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, loginVO.getUsername()));
        Assert.notNull(user, "用户名或密码错误");

        // 2. 校验密码
        boolean pwdMatch = passwordEncoder.matches(loginVO.getPassword(), user.getPassword());
        Assert.isTrue(pwdMatch, "用户名或密码错误");

        // 3. 生成token（格式：TOKEN_uuid_userId）
        String token = "TOKEN_" + UUID.randomUUID() + "_" + user.getId();
        tokenService.storeToken(token, new TokenUser(user.getId(), user.getUsername(), user.getRole()));

        // 4. PO转VO返回
        UserVO result = new UserVO();
        result.setId(user.getId());
        result.setUsername(user.getUsername());
        result.setNickname(user.getNickname());
        result.setMajor(user.getMajor());
        result.setGrade(user.getGrade());
        result.setInterestTags(user.getInterestTags());
        result.setRole(user.getRole());
        result.setToken(token);
        return result;
    }

    // 修改标签：更新interest_tags字段
    @Override
    public boolean updateTags(TagVO tagVO) {
        // 1. 解析token获取当前用户ID
        String token = tagVO.getToken();
        Assert.isTrue(token.contains("_") && token.split("_").length >=3, "无效token");
        Long userId = Long.parseLong(token.split("_")[2]);

        // 2. 校验用户存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. 更新标签+修改时间
        user.setInterestTags(tagVO.getInterestTags());
        user.setUpdateTime(LocalDateTime.now());
        int rows = userRepository.updateById(user);
        return rows > 0; // 返回是否修改成功
    }
}