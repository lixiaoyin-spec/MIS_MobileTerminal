package com.example.springbootapp.controller;

import com.example.springbootapp.dto.ChatRequest;
import com.example.springbootapp.dto.ChatResponse;
import com.example.springbootapp.dto.Result;
import com.example.springbootapp.service.AiChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AiChatController {

    @Autowired
    private AiChatService aiChatService;

    @PostMapping("/chat")
    public Result<ChatResponse> chat(@RequestBody ChatRequest chatRequest) {
        String reply = aiChatService.getChatReply(chatRequest.getMessage());
        // 使用 Result.success() 包装响应数据
        return Result.success(new ChatResponse(reply));
    }
}
