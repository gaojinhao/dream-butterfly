<template>
  <div class="home">
    <section class="hero">
      <h1>🦋 用AI创造年龄渐变视频</h1>
      <p>上传您的照片，让AI为您生成独特的年龄渐变视频</p>
      <div class="hero-actions">
        <router-link v-if="!isLoggedIn" to="/register" class="btn btn-primary">立即开始</router-link>
        <router-link v-else to="/create" class="btn btn-primary">创建视频</router-link>
      </div>
    </section>

    <section class="features">
      <h2>功能特点</h2>
      <div class="feature-grid">
        <div class="feature-card">
          <div class="feature-icon">📸</div>
          <h3>简单上传</h3>
          <p>最多上传20张照片，轻轻一点即可开始生成</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🤖</div>
          <h3>AI驱动</h3>
          <p>使用先进的AI技术生成流畅的年龄渐变效果</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🔒</div>
          <h3>隐私保护</h3>
          <p>您可以控制视频的公开或私密状态</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🌍</div>
          <h3>分享社区</h3>
          <p>浏览和欣赏其他用户创作的精彩视频</p>
        </div>
      </div>
    </section>

    <section class="recent-videos" v-if="publicVideos.length > 0">
      <h2>最新公开视频</h2>
      <div class="video-grid">
        <div v-for="video in publicVideos" :key="video.id" class="video-card">
          <div class="video-thumbnail">
            <img :src="video.thumbnail_url" :alt="video.title" />
            <div class="video-overlay">
              <router-link :to="`/videos/${video.id}`" class="play-btn">▶</router-link>
            </div>
          </div>
          <div class="video-info">
            <h3>{{ video.title }}</h3>
            <p>创作者：{{ video.username }}</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

interface Video {
  id: number
  title: string
  thumbnail_url: string
  username: string
}

const authStore = useAuthStore()
const isLoggedIn = computed(() => authStore.isAuthenticated)
const publicVideos = ref<Video[]>([])

onMounted(async () => {
  try {
    const response = await axios.get('/api/videos', { params: { public: true, limit: 6 } })
    publicVideos.value = response.data
  } catch (error) {
    console.error('获取视频列表失败', error)
  }
})
</script>

<style scoped>
.home { max-width: 1200px; margin: 0 auto; }
.hero {
  text-align: center;
  padding: 4rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: white;
  margin-bottom: 3rem;
}
.hero h1 { font-size: 3rem; margin-bottom: 1rem; }
.hero p { font-size: 1.25rem; margin-bottom: 2rem; opacity: 0.9; }
.hero-actions { display: flex; gap: 1rem; justify-content: center; }
.btn {
  padding: 0.75rem 2rem;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: transform 0.2s;
}
.btn-primary { background: white; color: #667eea; }
.btn:hover { transform: translateY(-2px); }
.features { margin-bottom: 3rem; }
.features h2 { text-align: center; font-size: 2rem; margin-bottom: 2rem; color: #2c3e50; }
.feature-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; }
.feature-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
.feature-icon { font-size: 3rem; margin-bottom: 1rem; }
.feature-card h3 { color: #2c3e50; margin-bottom: 0.5rem; }
.feature-card p { color: #666; }
.recent-videos h2 { text-align: center; font-size: 2rem; margin-bottom: 2rem; color: #2c3e50; }
.video-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem; }
.video-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
.video-thumbnail { position: relative; aspect-ratio: 16/9; }
.video-thumbnail img { width: 100%; height: 100%; object-fit: cover; }
.video-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}
.video-card:hover .video-overlay { opacity: 1; }
.play-btn {
  width: 60px;
  height: 60px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: #667eea;
  text-decoration: none;
}
.video-info { padding: 1rem; }
.video-info h3 { color: #2c3e50; margin-bottom: 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.video-info p { color: #666; font-size: 0.9rem; }
</style>
