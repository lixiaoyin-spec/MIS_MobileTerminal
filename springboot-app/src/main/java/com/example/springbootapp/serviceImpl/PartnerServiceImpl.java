package com.example.springbootapp.serviceImpl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.PartnerService;
import com.example.springbootapp.vo.PartnerVO;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 学伴推荐服务实现类
 */
@Service
public class PartnerServiceImpl implements PartnerService {

    @Resource
    private UserRepository userRepository;

    /**
     * 核心推荐逻辑：按标签重复个数降序排序
     */
    @Override
    public List<PartnerVO> recommendPartners(String token) {
        // 1. 解析token获取当前登录用户ID
        Assert.isTrue(token.contains("_") && token.split("_").length >= 3, "无效token");
        Long currentUserId = Long.parseLong(token.split("_")[2]);

        // 2. 获取当前用户信息（含其标签）
        User currentUser = userRepository.selectById(currentUserId);
        Assert.notNull(currentUser, "当前用户不存在");
        Set<String> currentUserTags = parseTags(currentUser.getInterestTags()); // 解析当前用户标签

        // 3. 查询所有正常状态的其他用户（排除当前用户）
        List<User> allUsers = userRepository.selectList(new LambdaQueryWrapper<User>()
                .eq(User::getStatus, 1) // 只选正常状态
                .ne(User::getId, currentUserId)); // 排除自己

        // 4. 计算每个用户与当前用户的重复标签个数，转换为VO
        List<PartnerVO> partnerList = new ArrayList<>();
        for (User user : allUsers) {
            Set<String> targetTags = parseTags(user.getInterestTags()); // 解析目标用户标签
            int sameTagCount = countSameTags(currentUserTags, targetTags); // 统计重复个数

            PartnerVO vo = new PartnerVO();
            vo.setName(user.getNickname());
            vo.setMajor(user.getMajor());
            vo.setTags(user.getInterestTags());
            vo.setSameTagCount(sameTagCount);
            partnerList.add(vo);
        }

        // 5. 按重复标签个数降序排序（重复越多越靠前），最多返回10个
        return partnerList.stream()
                .sorted(Comparator.comparingInt(PartnerVO::getSameTagCount).reversed())
                .limit(10)
                .collect(Collectors.toList());
    }

    /**
     * 工具方法1：解析标签字符串为Set（如"1,3,5" → {"1","3","5"}）
     */
    private Set<String> parseTags(String tagStr) {
        if (tagStr == null || tagStr.trim().isEmpty()) {
            return Set.of(); // 无标签返回空集合
        }
        return Set.of(tagStr.split(","));
    }

    /**
     * 工具方法2：统计两个标签集合的重复个数（交集大小）
     */
    private int countSameTags(Set<String> tags1, Set<String> tags2) {
        if (tags1.isEmpty() || tags2.isEmpty()) {
            return 0;
        }
        // 统计两个集合的交集元素个数
        return (int) tags1.stream()
                .filter(tags2::contains)
                .count();
    }
}