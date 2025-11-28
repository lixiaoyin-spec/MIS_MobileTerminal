import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8081', // 后端地址
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, '') // 根据后端文档，URL 本身包含 /api，所以不需要 rewrite
      },
      '/upload': {
        target: 'http://localhost:8081',
        changeOrigin: true
      }
    }
  }
})
