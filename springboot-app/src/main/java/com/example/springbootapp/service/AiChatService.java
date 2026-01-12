package com.example.springbootapp.service;

import com.baidubce.appbuilder.console.appbuilderclient.AppBuilderClient;
import com.baidubce.appbuilder.model.appbuilderclient.AppBuilderClientIterator;
import com.baidubce.appbuilder.model.appbuilderclient.AppBuilderClientResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class AiChatService {

    @Value("${appbuilder.app-id}")
    private String appId;

    @Value("${appbuilder.token}")
    private String token;

    public String getChatReply(String userMessage) {
        // 设置环境中的TOKEN，用于AppBuilderClient认证
        System.setProperty("APPBUILDER_TOKEN", token);

        try {
            // 初始化AppBuilderClient
            AppBuilderClient client = new AppBuilderClient(appId);
            // 创建一个新的会话
            String conversationId = client.createConversation();

            // 发送消息并获取流式响应
            AppBuilderClientIterator iterator = client.run(userMessage, conversationId, new String[]{}, false);

            // 将流式响应拼接为完整字符串
            StringBuilder answer = new StringBuilder();
            while (iterator.hasNext()) {
                AppBuilderClientResult response = iterator.next();
                answer.append(response.getAnswer());
            }
            return answer.toString();

        } catch (Exception e) {
            // 简单的错误处理，实际项目中建议使用更完善的日志和异常处理机制
            e.printStackTrace();
            return "AI 服务暂时不可用，请稍后再试。";
        }
    }
}
