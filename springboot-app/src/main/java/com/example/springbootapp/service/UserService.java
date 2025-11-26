package com.example.springbootapp.service;

import com.example.springbootapp.vo.UserVO;

public interface UserService {
    // 注册（入参为UserVO）
    void register(UserVO userVO);

    // 登录（入参/出参均为UserVO）
    UserVO login(UserVO userVO);
}