package com.example.springbootapp.service;

import com.example.springbootapp.vo.ClockVO;
import java.util.List;

public interface ClockService {
    // 新增打卡
    void addClock(ClockVO clockVO);

    // 获取打卡列表（当前用户的所有打卡记录）
    List<ClockVO> getClockList(String token);
}