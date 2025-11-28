<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { register } from '../api/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  nickname: '',
  major: '',
  grade: 2023,
  interestTags: '' // Simple input for now
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  major: [{ required: true, message: '请输入专业', trigger: 'blur' }],
  grade: [{ required: true, message: '请输入年级', trigger: 'blur' }]
}

const formRef = ref(null)

const handleRegister = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        // Convert tags if needed, backend expects string "1,3"
        // Here we just send what user types or defaults
        await register(form)
        ElMessage.success('注册成功，请登录')
        router.push('/login')
      } catch (error) {
        // Error handled
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<template>
  <div class="register-container">
    <el-card class="register-card">
      <template #header>
        <div class="card-header">
          <h2>注册新账号</h2>
        </div>
      </template>
      
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="登录账号" />
        </el-form-item>
        
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="登录密码" />
        </el-form-item>

        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" placeholder="显示名称" />
        </el-form-item>

        <el-form-item label="专业" prop="major">
          <el-input v-model="form.major" placeholder="例如：计算机科学" />
        </el-form-item>

        <el-form-item label="年级" prop="grade">
          <el-input-number v-model="form.grade" :min="2015" :max="2030" />
        </el-form-item>

        <el-form-item label="兴趣" prop="interestTags">
          <el-input v-model="form.interestTags" placeholder="标签ID (如 1,2)" />
          <div class="tips">请输入1-5的数字，逗号分隔</div>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" :loading="loading" class="w-100" @click="handleRegister">
            注册
          </el-button>
        </el-form-item>
        
        <div class="links">
          <router-link to="/login">已有账号？去登录</router-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped lang="scss">
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #2d3a4b;
}

.register-card {
  width: 500px;
  
  .card-header {
    text-align: center;
  }
}

.w-100 {
  width: 100%;
}

.tips {
  font-size: 12px;
  color: #999;
}

.links {
  text-align: right;
  font-size: 14px;
}
</style>
