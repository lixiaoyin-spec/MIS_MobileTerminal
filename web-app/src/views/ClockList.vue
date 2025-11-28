<script setup>
import { ref, onMounted, computed } from 'vue'
import { addClock, getClockList } from '../api/clock'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const clockList = ref([])
const loading = ref(false)
const content = ref('')
const submitLoading = ref(false)

// Check if clocked in today
const hasClockedToday = computed(() => {
  if (clockList.value.length === 0) return false
  const today = new Date().toISOString().split('T')[0]
  // Backend returns clockDate as "2025-11-26"
  return clockList.value.some(item => item.clockDate === today)
})

const fetchClockList = async () => {
  loading.value = true
  try {
    const res = await getClockList(userStore.token)
    clockList.value = res.data || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleClockIn = async () => {
  if (!content.value.trim()) {
    ElMessage.warning('请输入打卡内容')
    return
  }
  
  submitLoading.value = true
  try {
    await addClock({
      content: content.value,
      token: userStore.token
    })
    ElMessage.success('打卡成功！')
    content.value = ''
    fetchClockList()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

onMounted(() => {
  fetchClockList()
})
</script>

<template>
  <div class="clock-page">
    <el-row :gutter="20">
      <!-- Left: Clock In Action -->
      <el-col :span="10">
        <el-card class="clock-card">
          <template #header>
            <div class="card-header">
              <span>每日打卡</span>
              <el-tag v-if="hasClockedToday" type="success">今日已打卡</el-tag>
              <el-tag v-else type="warning">今日未打卡</el-tag>
            </div>
          </template>
          
          <div class="clock-form">
            <div class="greeting">
              <h3>坚持学习，记录每一天！</h3>
              <p>今天学了什么？分享一下吧。</p>
            </div>
            
            <el-input
              v-model="content"
              type="textarea"
              :rows="4"
              placeholder="输入今日学习心得..."
              :disabled="hasClockedToday"
            />
            
            <el-button 
              type="primary" 
              class="submit-btn" 
              :loading="submitLoading" 
              :disabled="hasClockedToday"
              @click="handleClockIn"
            >
              {{ hasClockedToday ? '今日任务已完成' : '立即打卡' }}
            </el-button>
          </div>
        </el-card>
      </el-col>
      
      <!-- Right: History Timeline -->
      <el-col :span="14">
        <el-card class="history-card">
          <template #header>
            <div class="card-header">
              <span>打卡记录</span>
            </div>
          </template>
          
          <el-skeleton :loading="loading" animated>
            <template #default>
              <div v-if="clockList.length === 0" class="empty">暂无打卡记录</div>
              <el-timeline v-else>
                <el-timeline-item
                  v-for="item in clockList"
                  :key="item.id"
                  :timestamp="item.createTime?.replace('T', ' ')"
                  placement="top"
                  :type="item.clockDate === new Date().toISOString().split('T')[0] ? 'success' : ''"
                >
                  <el-card shadow="hover" class="timeline-card">
                    <h4>{{ item.content }}</h4>
                    <p>打卡人：{{ item.nickname }}</p>
                  </el-card>
                </el-timeline-item>
              </el-timeline>
            </template>
          </el-skeleton>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped lang="scss">
.clock-page {
  padding: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.clock-form {
  text-align: center;
  padding: 20px 0;
  
  .greeting {
    margin-bottom: 20px;
    h3 {
      color: #409eff;
      margin: 0 0 10px 0;
    }
    p {
      color: #909399;
      margin: 0;
    }
  }
  
  .submit-btn {
    margin-top: 20px;
    width: 100%;
    height: 40px;
    font-size: 16px;
  }
}

.empty {
  text-align: center;
  color: #909399;
  padding: 40px;
}

.timeline-card {
  h4 {
    margin: 0 0 10px 0;
    font-size: 16px;
  }
  p {
    margin: 0;
    color: #909399;
    font-size: 13px;
  }
}
</style>
