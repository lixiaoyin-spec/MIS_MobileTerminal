package com.example.springbootapp.vo;

import lombok.Data;

@Data
public class PartnerVO {
    private String name;            // 学伴昵称
    private String major;           // 专业
    private String tags;            // 学伴标签（格式："1,3,5"）
    private Integer sameTagCount;   // 与当前用户的重复标签个数（核心排序依据）
}