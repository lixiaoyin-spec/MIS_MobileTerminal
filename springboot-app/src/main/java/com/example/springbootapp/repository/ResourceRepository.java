package com.example.springbootapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.springbootapp.po.ResourcePO; // 引用修改后的PO类
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ResourceRepository extends BaseMapper<ResourcePO> { // 替换为ResourcePO
}