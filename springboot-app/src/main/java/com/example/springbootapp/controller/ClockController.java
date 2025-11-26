package com.example.springbootapp.controller;

import com.example.springbootapp.service.ClockService;
import com.example.springbootapp.vo.ClockVO;
import jakarta.validation.constraints.NotBlank;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/clock")
public class ClockController {

    @Resource
    private ClockService clockService;

    // 新增打卡接口
    @PostMapping("/add")
    public Map<String, Object> add(@Valid @RequestBody ClockVO clockVO) {
        clockService.addClock(clockVO);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "打卡成功");
        result.put("data", null);
        return result;
    }

    // 获取打卡列表接口（当前用户的所有打卡记录）
    @GetMapping("/list")
    public Map<String, Object> getList(@RequestParam @Valid @NotBlank(message = "token不能为空") String token) {
        List<ClockVO> clockList = clockService.getClockList(token);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "查询成功");
        result.put("data", clockList);
        return result;
    }
}