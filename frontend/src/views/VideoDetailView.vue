<template>
  <div class="video-detail-container">
    <div v-if="loading" class="loading">加载中...</div>
    <div v-else-if="video" class="video-content">
      <div class="video-player">
        <video :src="video.video_url" controls poster="video.thumbnail_url"></video>
      </div>
      <div class="video-info">
        <h1>{{ video.title }}</h1>
        <p class="video-meta">创作者：{{ video.username }} | 创建时间：{{ formatDate(video.created_at) }}</p>
        <p class="video-description">{{ video.description }}</p>
      </div>
    </div>
    <div v-else class="error">视频不存在或已被删除</div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'

interface Video {
  id: number
  title: string
  description: string
  video_url: string
  thumbnail_url: string
  username: string
  created_at: string
}

const route = useRoute()
const video = ref<Video | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const response = await axios.get(`/api/videos/${route.params.id}`)
    video.value = response.data
  } catch (error) {
    console.error('获取视频详情失败', error)
  } finally { loading.value = false }
})

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' })
}
</script>

<style scoped>
.video-detail-container { max-width: 1000px; margin: 0 auto; }
.loading { text-align: center; padding: 3rem; color: #666; }
.error { text-align: center; padding: 3rem; color: #dc2626; }
.video-content { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); }
.video-player video { width: 100%; display: block; background: #000; }
.video-info { padding: 1.5rem; }
.video-info h1 { color: #2c3e50; margin-bottom: 0.5rem; }
.video-meta { color: #999; font-size: 0.9rem; margin-bottom: 1rem; }
.video-description { color: #666; line-height: 1.6; }
</style>
