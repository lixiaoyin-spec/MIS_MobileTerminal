<script setup>
import { ref, nextTick } from 'vue'
import { postChatMessage } from '../api/ai'
import MarkdownIt from 'markdown-it'
import hljs from 'highlight.js'
import 'highlight.js/styles/atom-one-dark.css'

const md = new MarkdownIt({
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
               hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
               '</code></pre>'
      } catch (__) {}
    }

    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>'
  }
})
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

const renderMarkdown = (text) => {
  return md.render(text || '')
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
            <div v-if="msg.role === 'ai'" class="markdown-body" v-html="renderMarkdown(msg.content)"></div>
            <p v-else>{{ msg.content }}</p>
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
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.chat-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  
  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 0;
    overflow: hidden;
  }
}

.chat-window {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  min-height: 0;
  background-color: #f5f7fa;
  scroll-behavior: smooth;
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
      color: #303133;
    }
  }
}

.message-bubble {
  max-width: 70%;
  padding: 10px 15px;
  border-radius: 18px;
  
  /* Markdown Styles */
  :deep(.markdown-body) {
    font-size: 14px;
    line-height: 1.6;
    
    p {
      margin-bottom: 10px;
      &:last-child {
        margin-bottom: 0;
      }
    }
    
    code {
      background-color: #f0f2f5;
      padding: 2px 4px;
      border-radius: 4px;
      font-family: monospace;
      color: #e6a23c;
    }
    
    pre {
      padding: 10px;
      border-radius: 4px;
      overflow-x: auto;
      margin: 0;
      
      code {
        background-color: transparent;
        color: inherit;
        padding: 0;
        font-family: Consolas, Monaco, 'Andale Mono', 'Ubuntu Mono', monospace;
      }
    }
    
    ul, ol {
      padding-left: 20px;
      margin-bottom: 10px;
    }
    
    a {
      color: #409eff;
      text-decoration: none;
      &:hover {
        text-decoration: underline;
      }
    }
  }

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
