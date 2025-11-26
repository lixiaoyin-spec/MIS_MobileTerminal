package com.example.springbootapp.service;

import com.example.springbootapp.vo.TagVO;
import com.example.springbootapp.vo.UserVO;

public interface UserService {
    void register(UserVO userVO);       // 注册（含标签存储）
    UserVO login(UserVO userVO);        // 登录
    boolean updateTags(TagVO tagVO);    // 修改标签
}