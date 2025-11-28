<script setup>
import { ref, onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { getPostList, createPost } from '../api/post'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'

const posts = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const userStore = useUserStore()
const router = useRouter()

const form = reactive({
  title: '',
  content: ''
})

const fetchPosts = async () => {
  loading.value = true
  try {
    const res = await getPostList()
    posts.value = res.data || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleCreate = async () => {
  if (!form.title || !form.content) {
    ElMessage.warning('请填写标题和内容')
    return
  }
  try {
    await createPost({
      ...form,
      token: userStore.token 
    })
    ElMessage.success('发布成功')
    dialogVisible.value = false
    form.title = ''
    form.content = ''
    fetchPosts()
  } catch (error) {
    console.error(error)
  }
}

const goToDetail = (id) => {
  router.push(`/dashboard/posts/${id}`)
}

onMounted(() => {
  fetchPosts()
})
</script>

<template>
  <div class="post-list">
    <div class="toolbar">
      <h2>社区交流</h2>
      <el-button type="primary" @click="dialogVisible = true">发布新帖</el-button>
    </div>

    <el-skeleton :loading="loading" animated>
      <template #template>
        <el-skeleton-item variant="p" style="width: 100%" />
        <el-skeleton-item variant="p" style="width: 100%" />
      </template>
      <template #default>
        <div v-if="posts.length === 0" class="empty">暂无帖子</div>
        <el-card 
          v-else 
          v-for="post in posts" 
          :key="post.id" 
          class="post-card cursor-pointer" 
          shadow="hover"
          @click="goToDetail(post.id)"
        >
          <div class="post-header">
            <h3 class="title">{{ post.title }}</h3>
            <span class="author">@{{ post.nickname }}</span>
          </div>
          <p class="content">{{ post.content }}</p>
          <div class="post-footer">
            <span class="time">{{ post.createTime?.replace('T', ' ') }}</span>
          </div>
        </el-card>
      </template>
    </el-skeleton>

    <el-dialog v-model="dialogVisible" title="发布新帖" width="500px">
      <el-form :model="form" label-position="top">
        <el-form-item label="标题">
          <el-input v-model="form.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="form.content" type="textarea" :rows="4" placeholder="请输入内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleCreate">发布</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.post-card {
  margin-bottom: 15px;
  
  .post-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    
    .title {
      margin: 0;
      font-size: 18px;
    }
    
    .author {
      color: #409eff;
      font-weight: bold;
    }
  }
  
  .content {
    color: #606266;
    line-height: 1.5;
    margin-bottom: 10px;
  }
  
  .post-footer {
    text-align: right;
    color: #909399;
    font-size: 12px;
  }
}

.empty {
  text-align: center;
  color: #909399;
  padding: 40px;
}
</style>
