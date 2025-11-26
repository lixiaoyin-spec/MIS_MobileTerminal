package com.example.springbootapp.service;

import com.example.springbootapp.vo.PartnerVO;
import java.util.List;

/**
 * 学伴推荐服务接口
 */
public interface PartnerService {
    List<PartnerVO> recommendPartners(String token);
}