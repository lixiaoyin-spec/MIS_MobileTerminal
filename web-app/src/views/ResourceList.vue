<script setup>
import { ref } from 'vue'
import { uploadResource } from '../api/resource'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const uploadRef = ref(null)
const uploading = ref(false)
const uploadedFiles = ref([]) // Store uploaded files locally for display

// Custom upload handler to match backend requirements (FormData with file + token)
const customUpload = async (options) => {
  const { file, onSuccess, onError } = options
  
  const formData = new FormData()
  formData.append('file', file)
  formData.append('token', userStore.token)
  
  uploading.value = true
  try {
    const res = await uploadResource(formData)
    
    // Add to local list
    uploadedFiles.value.unshift({
      name: file.name,
      url: res.data,
      time: new Date().toLocaleString()
    })
    
    ElMessage.success('上传成功')
    onSuccess(res)
  } catch (error) {
    console.error(error)
    onError(error)
  } finally {
    uploading.value = false
  }
}

const handleExceed = () => {
  ElMessage.warning('单次只能上传一个文件，请稍后继续')
}
</script>

<template>
  <div class="resource-page">
    <el-row :gutter="20">
      <!-- Upload Area -->
      <el-col :span="12">
        <el-card class="upload-card">
          <template #header>
            <div class="card-header">
              <span>资源上传</span>
            </div>
          </template>
          
          <div class="upload-container">
            <el-upload
              ref="uploadRef"
              class="upload-dragger"
              drag
              action="#"
              :http-request="customUpload"
              :limit="1"
              :on-exceed="handleExceed"
              :show-file-list="false"
            >
              <el-icon class="el-icon--upload"><upload-filled /></el-icon>
              <div class="el-upload__text">
                拖拽文件到此处 或 <em>点击上传</em>
              </div>
              <template #tip>
                <div class="el-upload__tip">
                  支持 PDF, Word, Excel 等格式，大小不超过 10MB
                </div>
              </template>
            </el-upload>
          </div>
        </el-card>
      </el-col>
      
      <!-- Uploaded List (Client side only for now) -->
      <el-col :span="12">
        <el-card class="list-card">
          <template #header>
            <div class="card-header">
              <span>本次上传记录</span>
            </div>
          </template>
          
          <div v-if="uploadedFiles.length === 0" class="empty">
            暂无上传记录
          </div>
          
          <el-table v-else :data="uploadedFiles" style="width: 100%">
            <el-table-column prop="name" label="文件名" show-overflow-tooltip />
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-link type="primary" :href="scope.row.url" target="_blank">
                  下载/查看
                </el-link>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped lang="scss">
.resource-page {
  padding: 0;
}

.upload-container {
  padding: 20px;
  text-align: center;
}

.empty {
  text-align: center;
  color: #909399;
  padding: 40px;
}
</style>
