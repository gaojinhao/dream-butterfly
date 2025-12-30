<template>
  <div class="create-video-container">
    <h2>创建新视频</h2>
    <form @submit.prevent="handleSubmit" class="create-form">
      <div class="form-group">
        <label for="title">视频标题</label>
        <input type="text" id="title" v-model="title" required placeholder="为您的视频起个名字" maxlength="100" />
      </div>
      <div class="form-group">
        <label for="description">视频描述</label>
        <textarea id="description" v-model="description" placeholder="描述您的视频内容（可选）" rows="3"></textarea>
      </div>
      <div class="form-group">
        <label>上传图片（最多20张）</label>
        <div class="upload-area" @dragover.prevent @drop.prevent="handleDrop">
          <input type="file" ref="fileInput" accept="image/*" multiple @change="handleFileSelect" style="display: none" />
          <div class="upload-prompt" @click="triggerFileInput">
            <span class="upload-icon">📁</span>
            <p>点击或拖拽图片到这里</p>
            <p class="upload-hint">支持 JPG, PNG 格式，每张最大 10MB</p>
          </div>
        </div>
      </div>
      <div v-if="previewImages.length > 0" class="preview-section">
        <h4>已选择 {{ previewImages.length }} 张图片</h4>
        <div class="preview-grid">
          <div v-for="(img, index) in previewImages" :key="index" class="preview-item">
            <img :src="img.preview" :alt="`图片 ${index + 1}`" />
            <button type="button" class="remove-btn" @click="removeImage(index)">×</button>
            <span class="image-order">{{ index + 1 }}</span>
          </div>
        </div>
      </div>
      <div class="form-group">
        <label class="checkbox-label">
          <input type="checkbox" v-model="isPublic" />
          <span>设为公开视频</span>
        </label>
      </div>
      <div v-if="error" class="error-message">{{ error }}</div>
      <div v-if="success" class="success-message">{{ success }}</div>
      <div class="form-actions">
        <button type="submit" :disabled="isSubmitting || previewImages.length === 0" class="submit-btn">
          {{ isSubmitting ? '生成中...' : '开始生成视频' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import axios from 'axios'

interface ImagePreview { file: File; preview: string }

const title = ref('')
const description = ref('')
const previewImages = ref<ImagePreview[]>([])
const isPublic = ref(true)
const isSubmitting = ref(false)
const error = ref('')
const success = ref('')
const fileInput = ref<HTMLInputElement | null>(null)

const triggerFileInput = () => fileInput.value?.click()

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files) addFiles(Array.from(target.files))
}

const handleDrop = (event: DragEvent) => {
  if (event.dataTransfer?.files) addFiles(Array.from(event.dataTransfer.files))
}

const addFiles = (files: File[]) => {
  const validFiles = files.filter(file => {
    if (!file.type.startsWith('image/')) { error.value = '只能上传图片文件'; return false }
    if (file.size > 10 * 1024 * 1024) { error.value = '每张图片不能超过10MB'; return false }
    return true
  })
  const remainingSlots = 20 - previewImages.value.length
  const filesToAdd = validFiles.slice(0, remainingSlots)
  filesToAdd.forEach(file => {
    const reader = new FileReader()
    reader.onload = (e) => {
      previewImages.value.push({ file, preview: e.target?.result as string })
    }
    reader.readAsDataURL(file)
  })
  if (previewImages.value.length >= 20) error.value = '已达到最大图片数量限制（20张）'
}

const removeImage = (index: number) => { previewImages.value.splice(index, 1); error.value = '' }

const handleSubmit = async () => {
  if (previewImages.value.length === 0) { error.value = '请至少上传一张图片'; return }
  isSubmitting.value = true; error.value = ''; success.value = ''
  try {
    const formData = new FormData()
    formData.append('title', title.value)
    formData.append('description', description.value)
    formData.append('is_public', isPublic.value.toString())
    previewImages.value.forEach((img, index) => { formData.append(`images[${index}]`, img.file) })
    await axios.post('/api/videos', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    success.value = '视频生成任务已提交，请稍候...'
    title.value = ''; description.value = ''; previewImages.value = []
  } catch (err: any) { error.value = err.response?.data?.message || '提交失败，请重试' }
  finally { isSubmitting.value = false }
}
</script>

<style scoped>
.create-video-container { max-width: 800px; margin: 0 auto; }
.create-video-container h2 { text-align: center; color: #2c3e50; margin-bottom: 2rem; }
.create-form { background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); }
.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; margin-bottom: 0.5rem; color: #2c3e50; font-weight: 500; }
.form-group input[type="text"], .form-group textarea {
  width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem;
}
.form-group input[type="text"]:focus, .form-group textarea:focus { outline: none; border-color: #667eea; }
.upload-area {
  border: 2px dashed #ccc; border-radius: 8px; padding: 2rem; text-align: center; cursor: pointer;
  transition: border-color 0.2s, background-color 0.2s;
}
.upload-area:hover { border-color: #667eea; background-color: #f8f9ff; }
.upload-prompt { pointer-events: none; }
.upload-icon { font-size: 3rem; display: block; margin-bottom: 0.5rem; }
.upload-hint { color: #999; font-size: 0.85rem; margin-top: 0.5rem; }
.preview-section { margin-bottom: 1.5rem; }
.preview-section h4 { color: #2c3e50; margin-bottom: 1rem; }
.preview-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 0.5rem; }
.preview-item { position: relative; aspect-ratio: 1; border-radius: 8px; overflow: hidden; }
.preview-item img { width: 100%; height: 100%; object-fit: cover; }
.remove-btn {
  position: absolute; top: 4px; right: 4px; width: 20px; height: 20px;
  background: rgba(220, 38, 38, 0.9); color: white; border: none; border-radius: 50%;
  cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 14px;
}
.image-order { position: absolute; bottom: 4px; left: 4px; background: rgba(0, 0, 0, 0.7); color: white; padding: 2px 6px; border-radius: 4px; font-size: 12px; }
.checkbox-label { display: flex !important; align-items: center; gap: 0.5rem; cursor: pointer; }
.checkbox-label input[type="checkbox"] { width: 18px; height: 18px; }
.error-message { background: #fee2e2; color: #dc2626; padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; }
.success-message { background: #dcfce7; color: #16a34a; padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; }
.form-actions { margin-top: 2rem; }
.submit-btn {
  width: 100%; padding: 0.75rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer;
}
.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
</style>
