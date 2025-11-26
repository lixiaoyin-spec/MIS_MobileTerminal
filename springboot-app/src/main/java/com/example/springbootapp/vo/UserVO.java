package com.example.springbootapp.vo;

import jakarta.validation.constraints.Pattern;
import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class UserVO {
    private Long id;                // 出参用（用户ID）
    @NotBlank(message = "用户名不能为空")
    private String username;        // 入参必填（登录/注册）
    @NotBlank(message = "密码不能为空")
    private String password;        // 入参必填（登录/注册，后端加密）
    @NotBlank(message = "昵称不能为空")
    private String nickname;        // 入参必填（注册）
    @NotBlank(message = "专业不能为空")
    private String major;           // 入参必填（注册）
    @NotNull(message = "年级不能为空")
    private Integer grade;          // 入参必填（注册）
    @NotNull(message = "至少选择1个标签")
    @Pattern(regexp = "^(1|2|3|4|5)(,(1|2|3|4|5)){0,4}$",
            message = "标签只能选择1-5，且不能重复")
    private String interestTags;    // 格式："1,3,5"（逗号分隔，无重复）
    private String role;            // 出参用（角色）
    private String token;           // 出参用（登录令牌）
}