import axios from 'axios'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'

const service = axios.create({
  timeout: 5000
})

// Request interceptor
service.interceptors.request.use(
  (config) => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
service.interceptors.response.use(
  (response) => {
    const res = response.data
    // According to backend docs, success is code 200
    if (res.code === 200) {
      return res
    } else {
      ElMessage.error(res.msg || 'Error')
      return Promise.reject(new Error(res.msg || 'Error'))
    }
  },
  (error) => {
    ElMessage.error(error.response?.data?.msg || error.message || 'Request failed')
    return Promise.reject(error)
  }
)

export default service
