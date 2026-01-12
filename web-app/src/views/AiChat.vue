<script setup>
import { ref, nextTick } from 'vue'
import { postChatMessage } from '../api/ai'

const messages = ref([
  { role: 'ai', content: '你好！我是你的AI助手，有什么可以帮助你的吗？' }
])
const newMessage = ref('')
const isLoading = ref(false)
const chatContainer = ref(null)

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight
    }
  })
}

const sendMessage = async () => {
  const messageText = newMessage.value.trim()
  if (messageText === '' || isLoading.value) return

  messages.value.push({ role: 'user', content: messageText })
  newMessage.value = ''
  isLoading.value = true
  scrollToBottom()

  try {
    const res = await postChatMessage(messageText)
    messages.value.push({ role: 'ai', content: res.data.reply })
  } catch (error) {
    messages.value.push({ role: 'ai', content: '抱歉，服务暂时无法连接，请稍后再试。' })
    console.error('Error fetching AI reply:', error)
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}
</script>

<template>
  <div class="ai-chat-page">
    <el-card class="chat-card">
      <div class="chat-window" ref="chatContainer">
        <div v-for="(msg, index) in messages" :key="index" class="message-row" :class="`is-${msg.role}`">
          <div class="message-bubble">
            <p>{{ msg.content }}</p>
          </div>
        </div>
      </div>
      <div class="input-area">
        <el-input
          v-model="newMessage"
          placeholder="输入你的问题..."
          @keyup.enter="sendMessage"
          :disabled="isLoading"
          size="large"
        >
          <template #append>
            <el-button @click="sendMessage" :loading="isLoading">发送</el-button>
          </template>
        </el-input>
      </div>
    </el-card>
  </div>
</template>

<style scoped lang="scss">
.ai-chat-page {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.chat-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  
  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 0;
  }
}

.chat-window {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background-color: #f5f7fa;
}

.message-row {
  display: flex;
  margin-bottom: 15px;

  &.is-user {
    justify-content: flex-end;
    .message-bubble {
      background-color: #409eff;
      color: #fff;
    }
  }

  &.is-ai {
    justify-content: flex-start;
    .message-bubble {
      background-color: #fff;
      border: 1px solid #e4e7ed;
    }
  }
}

.message-bubble {
  max-width: 70%;
  padding: 10px 15px;
  border-radius: 18px;
  p {
    margin: 0;
    line-height: 1.6;
  }
}

.input-area {
  padding: 15px 20px;
  border-top: 1px solid #e4e7ed;
}
</style>
