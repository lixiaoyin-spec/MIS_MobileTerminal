package com.example.springbootapp.serviceImpl;

import com.example.springbootapp.po.Clock;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.ClockRepository;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.ClockService;
import com.example.springbootapp.vo.ClockVO;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ClockServiceImpl implements ClockService {

    @Resource
    private ClockRepository clockRepository;
    @Resource
    private UserRepository userRepository;

    @Override
    public void addClock(ClockVO clockVO) {
        // 1. 解析token获取用户ID
        String token = clockVO.getToken();
        Assert.isTrue(token.contains("_") && token.split("_").length >= 3, "无效token");
        Long userId = Long.parseLong(token.split("_")[2]);

        // 2. 校验用户存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. 校验当天是否已打卡（避免重复打卡，可选逻辑）
        LocalDate today = LocalDate.now();
        Clock existClock = clockRepository.selectByUserIdAndDate(userId, today);
        Assert.isNull(existClock, "今日已打卡，请勿重复提交");

        // 4. VO转PO，保存打卡记录
        Clock clock = new Clock();
        clock.setUserId(userId);
        clock.setContent(clockVO.getContent());
        clock.setClockDate(today); // 打卡日期（年月日）
        clock.setCreateTime(LocalDateTime.now()); // 精确到时分秒
        clockRepository.insert(clock);
    }

    @Override
    public List<ClockVO> getClockList(String token) {
        // 1. 解析token获取用户ID
        String tokenStr = token;
        Assert.isTrue(tokenStr.contains("_") && tokenStr.split("_").length >= 3, "无效token");
        Long userId = Long.parseLong(tokenStr.split("_")[2]);

        // 2. 校验用户存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. 查询该用户的所有打卡记录（按时间倒序）
        List<Clock> clockList = clockRepository.selectByUserId(userId);

        // 4. PO转VO（补充用户昵称）
        return clockList.stream().map(clock -> {
            ClockVO vo = new ClockVO();
            vo.setId(clock.getId());
            vo.setContent(clock.getContent());
            vo.setClockDate(clock.getClockDate());
            vo.setCreateTime(clock.getCreateTime());
            vo.setNickname(user.getNickname()); // 打卡人昵称
            return vo;
        }).collect(Collectors.toList());
    }
}