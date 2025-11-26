package com.example.springbootapp.controller;

import com.example.springbootapp.service.UserService;
import com.example.springbootapp.vo.UserVO;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Resource
    private UserService userService;

    // 注册接口
    @PostMapping("/register")
    public Map<String, Object> register(@Valid @RequestBody UserVO userVO) {
        userService.register(userVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "注册成功");
        result.put("data", null);
        return result;
    }

    // 登录接口
    @PostMapping("/login")
    public Map<String, Object> login(@Valid @RequestBody UserVO userVO) {
        UserVO loginResult = userService.login(userVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "登录成功");
        result.put("data", loginResult);
        return result;
    }
}