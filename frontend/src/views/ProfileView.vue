<template>
  <div class="profile-container">
    <div class="profile-card">
      <div class="profile-header">
        <div class="avatar">{{ user?.username?.charAt(0).toUpperCase() }}</div>
        <div class="user-info">
          <h2>{{ user?.username }}</h2>
          <p>{{ user?.email }}</p>
        </div>
      </div>
      <div class="profile-stats">
        <div class="stat-item">
          <span class="stat-value">{{ stats.totalVideos }}</span>
          <span class="stat-label">视频总数</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ stats.publicVideos }}</span>
          <span class="stat-label">公开视频</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ stats.privateVideos }}</span>
          <span class="stat-label">私密视频</span>
        </div>
      </div>
      <div class="profile-actions">
        <button @click="handleLogout" class="action-btn logout">退出登录</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const router = useRouter()
const authStore = useAuthStore()
const user = computed(() => authStore.user)

const stats = ref({ totalVideos: 0, publicVideos: 0, privateVideos: 0 })

onMounted(async () => {
  try {
    const response = await axios.get('/api/users/me/stats')
    stats.value = response.data
  } catch (error) { console.error('获取用户统计失败', error) }
})

const handleLogout = () => { authStore.logout(); router.push('/') }
</script>

<style scoped>
.profile-container { max-width: 600px; margin: 0 auto; }
.profile-card { background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); padding: 2rem; }
.profile-header { display: flex; align-items: center; gap: 1.5rem; margin-bottom: 2rem; }
.avatar {
  width: 80px; height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%; display: flex; align-items: center; justify-content: center;
  font-size: 2rem; color: white; font-weight: bold;
}
.user-info h2 { color: #2c3e50; margin-bottom: 0.25rem; }
.user-info p { color: #666; }
.profile-stats {
  display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem;
  margin-bottom: 2rem; padding: 1.5rem; background: #f8f9fa; border-radius: 8px;
}
.stat-item { text-align: center; }
.stat-value { display: block; font-size: 1.5rem; font-weight: bold; color: #667eea; }
.stat-label { color: #666; font-size: 0.85rem; }
.profile-actions { display: flex; gap: 1rem; }
.action-btn { flex: 1; padding: 0.75rem; background: #fee2e2; color: #dc2626; border: none; border-radius: 8px; font-size: 1rem; cursor: pointer; }
</style>
