<template>
  <div class="my-videos-container">
    <div class="page-header">
      <h2>我的视频</h2>
      <router-link to="/create" class="create-btn">+ 创建新视频</router-link>
    </div>
    <div v-if="loading" class="loading">加载中...</div>
    <div v-else-if="videos.length === 0" class="empty-state">
      <span class="empty-icon">🎬</span>
      <h3>还没有视频</h3>
      <p>上传图片，创建您的第一个年龄渐变视频</p>
      <router-link to="/create" class="create-btn">立即创建</router-link>
    </div>
    <div v-else class="video-grid">
      <div v-for="video in videos" :key="video.id" class="video-card">
        <div class="video-thumbnail">
          <img :src="video.thumbnail_url" :alt="video.title" />
          <div class="video-overlay">
            <router-link :to="`/videos/${video.id}`" class="play-btn">▶</router-link>
          </div>
          <span v-if="!video.is_public" class="private-badge">私密</span>
        </div>
        <div class="video-info">
          <h3>{{ video.title }}</h3>
          <p class="video-date">{{ formatDate(video.created_at) }}</p>
          <div class="video-actions">
            <button @click="deleteVideo(video.id)" class="action-btn delete">删除</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import axios from 'axios'

interface Video { id: number; title: string; thumbnail_url: string; is_public: boolean; created_at: string }

const videos = ref<Video[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const response = await axios.get('/api/videos/my')
    videos.value = response.data
  } catch (error) { console.error('获取视频列表失败', error) }
  finally { loading.value = false }
})

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' })
}

const deleteVideo = async (id: number) => {
  if (!confirm('确定要删除这个视频吗？')) return
  try {
    await axios.delete(`/api/videos/${id}`)
    videos.value = videos.value.filter(v => v.id !== id)
  } catch (error) {
    console.error('删除视频失败', error)
    alert('删除失败，请重试')
  }
}
</script>

<style scoped>
.my-videos-container { max-width: 1200px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
.page-header h2 { color: #2c3e50; }
.create-btn {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
}
.loading { text-align: center; padding: 3rem; color: #666; }
.empty-state { text-align: center; padding: 4rem 2rem; background: white; border-radius: 12px; }
.empty-icon { font-size: 4rem; display: block; margin-bottom: 1rem; }
.empty-state h3 { color: #2c3e50; margin-bottom: 0.5rem; }
.empty-state p { color: #666; margin-bottom: 1.5rem; }
.video-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 2rem; }
.video-card { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
.video-thumbnail { position: relative; aspect-ratio: 16/9; }
.video-thumbnail img { width: 100%; height: 100%; object-fit: cover; }
.video-overlay {
  position: absolute; inset: 0; background: rgba(0, 0, 0, 0.5);
  display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.2s;
}
.video-card:hover .video-overlay { opacity: 1; }
.play-btn {
  width: 60px; height: 60px; background: white; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 1.5rem; color: #667eea; text-decoration: none;
}
.private-badge { position: absolute; top: 8px; right: 8px; background: rgba(0, 0, 0, 0.6); color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; }
.video-info { padding: 1rem; }
.video-info h3 { color: #2c3e50; margin-bottom: 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.video-date { color: #999; font-size: 0.85rem; margin-bottom: 1rem; }
.video-actions { display: flex; gap: 0.5rem; }
.action-btn { padding: 0.4rem 0.8rem; background: #fee2e2; color: #dc2626; border: none; border-radius: 4px; font-size: 0.85rem; cursor: pointer; }
</style>
