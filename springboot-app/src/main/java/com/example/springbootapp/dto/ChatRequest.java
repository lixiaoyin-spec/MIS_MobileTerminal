package com.example.springbootapp.dto;

import lombok.Data;

@Data
public class ChatRequest {
    private String message;
    // 可以根据需要添加其他字段，例如 userId
}
