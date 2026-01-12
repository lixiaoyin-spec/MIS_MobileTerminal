import request from './request'

// 发送聊天消息
export const postChatMessage = (message) => {
  return request.post('/api/ai/chat', { message })
}
