<script setup>
import { ref, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPostDetail, addComment } from '../api/post'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const post = ref({})
const loading = ref(false)
const commentContent = ref('')
const commentLoading = ref(false)

const postId = route.params.id

const fetchDetail = async () => {
  loading.value = true
  try {
    const res = await getPostDetail(postId)
    post.value = res.data
  } catch (error) {
    console.error(error)
    ElMessage.error('获取帖子详情失败')
  } finally {
    loading.value = false
  }
}

const handleComment = async () => {
  if (!commentContent.value.trim()) {
    ElMessage.warning('请输入评论内容')
    return
  }
  
  commentLoading.value = true
  try {
    await addComment({
      postId: postId,
      content: commentContent.value,
      token: userStore.token
    })
    ElMessage.success('评论成功')
    commentContent.value = ''
    // Refresh detail to see new comment
    fetchDetail()
  } catch (error) {
    console.error(error)
  } finally {
    commentLoading.value = false
  }
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  if (postId) {
    fetchDetail()
  }
})
</script>

<template>
  <div class="post-detail">
    <el-page-header @back="goBack" title="返回" class="mb-20">
      <template #content>
        <span class="text-large font-600 mr-3"> 帖子详情 </span>
      </template>
    </el-page-header>

    <el-skeleton :loading="loading" animated>
      <template #template>
        <el-skeleton-item variant="h1" style="width: 50%" />
        <el-skeleton-item variant="text" style="margin-top: 20px; height: 100px" />
      </template>
      
      <template #default>
        <el-card class="detail-card">
          <template #header>
            <div class="detail-header">
              <h1 class="title">{{ post.title }}</h1>
              <div class="meta">
                <span class="author">作者：{{ post.nickname }}</span>
                <span class="time">发布于：{{ post.createTime?.replace('T', ' ') }}</span>
                <span class="views">浏览：{{ post.viewCount }}</span>
              </div>
            </div>
          </template>
          <div class="content">
            {{ post.content }}
          </div>
        </el-card>

        <div class="comment-section">
          <h3>评论 ({{ post.comments?.length || 0 }})</h3>
          
          <div class="comment-input">
            <el-input
              v-model="commentContent"
              type="textarea"
              :rows="3"
              placeholder="写下你的评论..."
            />
            <div class="btn-wrapper">
              <el-button type="primary" :loading="commentLoading" @click="handleComment">发表评论</el-button>
            </div>
          </div>

          <div class="comment-list">
            <div v-if="!post.comments || post.comments.length === 0" class="empty-comment">
              暂无评论，快来抢沙发吧！
            </div>
            <el-card v-else v-for="comment in post.comments" :key="comment.id" class="comment-item" shadow="never">
              <div class="comment-header">
                <span class="comment-author">{{ comment.nickname }}</span>
                <span class="comment-time">{{ comment.createTime?.replace('T', ' ') }}</span>
              </div>
              <div class="comment-content">
                {{ comment.content }}
              </div>
            </el-card>
          </div>
        </div>
      </template>
    </el-skeleton>
  </div>
</template>

<style scoped lang="scss">
.mb-20 {
  margin-bottom: 20px;
}

.detail-card {
  margin-bottom: 30px;
  
  .title {
    margin: 0 0 15px 0;
    font-size: 24px;
    color: #303133;
  }
  
  .meta {
    font-size: 13px;
    color: #909399;
    display: flex;
    gap: 20px;
  }
  
  .content {
    font-size: 16px;
    line-height: 1.8;
    color: #606266;
    min-height: 100px;
    white-space: pre-wrap;
  }
}

.comment-section {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
  
  h3 {
    margin-top: 0;
    margin-bottom: 20px;
    border-left: 4px solid #409eff;
    padding-left: 10px;
  }
}

.comment-input {
  margin-bottom: 30px;
  
  .btn-wrapper {
    margin-top: 10px;
    text-align: right;
  }
}

.comment-list {
  .comment-item {
    margin-bottom: 15px;
    border: none;
    border-bottom: 1px solid #ebeef5;
    
    &:last-child {
      border-bottom: none;
    }
    
    .comment-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
      
      .comment-author {
        font-weight: bold;
        color: #303133;
      }
      
      .comment-time {
        font-size: 12px;
        color: #909399;
      }
    }
    
    .comment-content {
      color: #606266;
    }
  }
  
  .empty-comment {
    text-align: center;
    color: #909399;
    padding: 30px 0;
  }
}
</style>
