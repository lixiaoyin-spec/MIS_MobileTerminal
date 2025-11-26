package com.example.springbootapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.example.springbootapp.po.Clock;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface ClockRepository extends BaseMapper<Clock> {
    // 按用户ID和日期查询（判断当天是否已打卡）
    Clock selectByUserIdAndDate(@Param("userId") Long userId, @Param("clockDate") LocalDate clockDate);

    // 按用户ID查询打卡记录（用于个人打卡列表）
    List<Clock> selectByUserId(@Param("userId") Long userId);
}