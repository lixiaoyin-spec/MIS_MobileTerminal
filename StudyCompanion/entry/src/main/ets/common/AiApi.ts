import { HttpClient } from './HttpClient';
import { ApiResponse } from './ApiResponse';

// 定义后端返回的聊天数据结构
interface ChatResponseData {
  reply: string;
}

class AiApi {
  /**
   * 发送聊天消息
   * @param message 用户发送的消息
   * @param token  用户的认证token
   * @returns AI的回复内容
   */
  async postChatMessage(message: string, token: string): Promise<string> {
    // 调用HttpClient的静态方法，并传入正确的泛型类型和token
    const response = await HttpClient.postJson<ApiResponse<ChatResponseData>>('/api/ai/chat', { message }, token);

    // 检查业务码并返回data中的reply字段
    if (response && response.code === 200 && response.data) {
      return response.data.reply;
    } else {
      throw new Error(response.msg || 'AI service returned an error');
    }
  }
}

const aiApi = new AiApi();
export default aiApi;
