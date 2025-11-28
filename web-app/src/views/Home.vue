<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '../stores/user'
import { updateTags } from '../api/user'
import { getRecommendPartners } from '../api/partner'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const dialogVisible = ref(false)
const newTags = ref('')
const loading = ref(false)
const partners = ref([])
const partnersLoading = ref(false)

const openEditDialog = () => {
  newTags.value = userStore.userInfo.interestTags || ''
  dialogVisible.value = true
}

const handleUpdateTags = async () => {
  loading.value = true
  try {
    await updateTags({
      token: userStore.token,
      interestTags: newTags.value
    })
    
    userStore.updateUserInfo({ interestTags: newTags.value })
    ElMessage.success('标签修改成功')
    dialogVisible.value = false
    // Refresh recommendations after tags update
    fetchPartners()
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const fetchPartners = async () => {
  partnersLoading.value = true
  try {
    const res = await getRecommendPartners(userStore.token)
    partners.value = res.data || []
  } catch (error) {
    console.error(error)
  } finally {
    partnersLoading.value = false
  }
}

onMounted(() => {
  fetchPartners()
})
</script>

<template>
  <div class="home">
    <el-card class="welcome-card">
      <template #header>
        <div class="card-header">
          <span>个人信息概览</span>
        </div>
      </template>
      <h2>你好，{{ userStore.userInfo.nickname || userStore.userInfo.username }}！</h2>
      <div class="info-grid">
        <div class="info-item">
          <span class="label">角色：</span>
          <el-tag>{{ userStore.userInfo.role }}</el-tag>
        </div>
        <div class="info-item">
          <span class="label">专业：</span>
          <span class="value">{{ userStore.userInfo.major }}</span>
        </div>
         <div class="info-item">
          <span class="label">年级：</span>
          <span class="value">{{ userStore.userInfo.grade }}级</span>
        </div>
        <div class="info-item">
          <span class="label">兴趣标签：</span>
          <span class="value">{{ userStore.userInfo.interestTags }}</span>
          <el-button type="primary" link size="small" @click="openEditDialog">
            <el-icon><Edit /></el-icon> 修改
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- Tag Edit Dialog -->
    <el-dialog v-model="dialogVisible" title="修改兴趣标签" width="400px">
      <el-form label-position="top">
        <el-form-item label="兴趣标签 (用逗号分隔)">
          <el-input v-model="newTags" placeholder="例如：1,3,5" />
          <div class="tips">提示：请输入数字标签ID，多个用逗号隔开</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="loading" @click="handleUpdateTags">保存</el-button>
        </span>
      </template>
    </el-dialog>
    
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="8">
        <el-card shadow="hover" class="action-card" @click="$router.push('/dashboard/posts')">
          <div class="action-content">
            <el-icon size="40" color="#409eff"><component is="ChatLineRound" /></el-icon>
            <h3>社区交流</h3>
            <p>浏览最新帖子，参与讨论</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="action-card" @click="$router.push('/dashboard/resources')">
          <div class="action-content">
             <el-icon size="40" color="#67c23a"><component is="Folder" /></el-icon>
            <h3>资源中心</h3>
            <p>下载学习资料，上传分享</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="action-card" @click="$router.push('/dashboard/clock')">
          <div class="action-content">
             <el-icon size="40" color="#e6a23c"><component is="Timer" /></el-icon>
            <h3>每日打卡</h3>
            <p>记录学习进度，坚持就是胜利</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Partner Recommendations -->
    <div class="recommend-section">
      <h3>为您推荐的学伴</h3>
      <el-skeleton :loading="partnersLoading" animated>
        <template #default>
          <div v-if="partners.length === 0" class="empty-partner">
            <el-empty description="暂无推荐，尝试完善兴趣标签吧！" image-size="100" />
          </div>
          <el-row v-else :gutter="20">
            <el-col :span="6" v-for="(partner, index) in partners" :key="index">
              <el-card shadow="hover" class="partner-card">
                <div class="partner-header">
                  <el-avatar :size="50" :src="'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'" />
                  <div class="partner-info">
                    <div class="name">{{ partner.name }}</div>
                    <div class="major">{{ partner.major }}</div>
                  </div>
                </div>
                <div class="partner-tags">
                  <el-tag 
                    v-for="tag in partner.tags.split(',')" 
                    :key="tag" 
                    size="small" 
                    class="tag-item"
                  >
                    标签{{ tag }}
                  </el-tag>
                </div>
                <div class="match-info">
                  <el-icon color="#f56c6c"><Sunny /></el-icon>
                  <span>{{ partner.sameTagCount }} 个共同兴趣</span>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </template>
      </el-skeleton>
    </div>
  </div>
</template>

<style scoped lang="scss">
.welcome-card {
  margin-bottom: 20px;
}
.info-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 30px;
  margin-top: 10px;
}
.info-item {
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.label {
  color: #909399;
}
.value {
  font-weight: bold;
}

.action-card {
  cursor: pointer;
  text-align: center;
  transition: transform 0.3s;
  
  &:hover {
    transform: translateY(-5px);
  }
  
  .action-content {
    padding: 20px 0;
    h3 {
      margin: 15px 0 10px;
    }
    p {
      color: #909399;
      margin: 0;
    }
  }
}

.tips {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}
.tips {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.recommend-section {
  margin-top: 30px;
  
  h3 {
    margin-bottom: 20px;
    border-left: 4px solid #409eff;
    padding-left: 10px;
  }
}

.partner-card {
  margin-bottom: 20px;
  
  .partner-header {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 15px;
    
    .name {
      font-weight: bold;
      font-size: 16px;
    }
    .major {
      font-size: 12px;
      color: #909399;
    }
  }
  
  .partner-tags {
    margin-bottom: 15px;
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
    
    .tag-item {
      margin-right: 0;
    }
  }
  
  .match-info {
    display: flex;
    align-items: center;
    gap: 5px;
    color: #f56c6c;
    font-size: 13px;
    background-color: #fef0f0;
    padding: 5px 10px;
    border-radius: 4px;
  }
}
</style>
