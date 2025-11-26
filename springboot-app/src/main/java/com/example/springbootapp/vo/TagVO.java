package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

@Data
public class TagVO {
    @NotBlank(message = "token不能为空")
    private String token;           // 身份令牌（获取当前用户）

    @NotBlank(message = "至少选择1个标签")
    @Pattern(regexp = "^(1|2|3|4|5)(,(1|2|3|4|5)){0,4}$",
            message = "标签只能选择1-5，且不能重复")
    private String interestTags;    // 新标签（格式："1,2,4"）
}