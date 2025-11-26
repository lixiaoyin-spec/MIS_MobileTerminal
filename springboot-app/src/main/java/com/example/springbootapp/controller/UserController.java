package com.example.springbootapp.controller;

import com.example.springbootapp.service.UserService;
import com.example.springbootapp.vo.LoginVO;
import com.example.springbootapp.vo.TagVO;
import com.example.springbootapp.vo.UserVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Resource
    private UserService userService;

    // 注册接口（含标签提交）
    @PostMapping("/register")
    public Map<String, Object> register(@Valid @RequestBody UserVO userVO) {
        userService.register(userVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "注册成功");
        return result;
    }

    // 登录接口
    @PostMapping("/login")
    public Map<String, Object> login(@Valid @RequestBody LoginVO loginVO) {
        UserVO loginResult = userService.login(loginVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "登录成功");
        result.put("data", loginResult);
        return result;
    }

    // 新增：修改标签接口（POST或PUT均可，这里用POST）
    @PostMapping("/tag")
    public Map<String, Object> updateTags(@Valid @RequestBody TagVO tagVO) {
        boolean success = userService.updateTags(tagVO);
        Map<String, Object> result = new HashMap<>();
        if (success) {
            result.put("code", 200);
            result.put("msg", "标签修改成功");
        } else {
            result.put("code", 500);
            result.put("msg", "标签修改失败");
        }
        return result;
    }
}