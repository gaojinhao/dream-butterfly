import express from 'express'
import cors from 'cors'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = 3001

app.use(cors())
app.use(express.json())

const users = new Map()
const videos = []
const tokens = new Map()

app.post('/api/auth/register', (req, res) => {
  const { username, email, password } = req.body
  if (users.has(email)) {
    return res.status(400).json({ message: '用户名或邮箱已存在' })
  }
  const userId = users.size + 1
  const token = `mock-jwt-token-${Date.now()}`
  users.set(email, { id: userId, username, email, password })
  tokens.set(token, userId)
  res.json({
    user: { id: userId, username, email, created_at: new Date().toISOString() },
    token
  })
})

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body
  const user = users.get(email)
  if (!user || user.password !== password) {
    return res.status(401).json({ message: '邮箱或密码错误' })
  }
  const token = `mock-jwt-token-${Date.now()}`
  tokens.set(token, user.id)
  res.json({
    user: { id: user.id, username: user.username, email, created_at: new Date().toISOString() },
    token
  })
})

app.get('/api/auth/me', (req, res) => {
  const authHeader = req.headers.authorization
  if (!authHeader) return res.status(401).json({ message: '未登录' })
  const token = authHeader.replace('Bearer ', '')
  const userId = tokens.get(token)
  if (!userId) return res.status(401).json({ message: '无效令牌' })
  for (const user of users.values()) {
    if (user.id === userId) {
      return res.json({ id: user.id, username: user.username, email: user.email, created_at: new Date().toISOString() })
    }
  }
  res.status(401).json({ message: '用户不存在' })
})

app.get('/api/videos', (req, res) => {
  res.json(videos.filter(v => v.is_public))
})

app.get('/api/videos/my', (req, res) => {
  const authHeader = req.headers.authorization
  if (!authHeader) return res.status(401).json({ message: '未登录' })
  const token = authHeader.replace('Bearer ', '')
  const userId = tokens.get(token)
  res.json(videos.filter(v => v.user_id === userId))
})

app.get('/api/videos/:id', (req, res) => {
  const video = videos.find(v => v.id === parseInt(req.params.id))
  if (!video) return res.status(404).json({ message: '视频不存在' })
  res.json(video)
})

app.post('/api/videos', (req, res) => {
  const authHeader = req.headers.authorization
  if (!authHeader) return res.status(401).json({ message: '未登录' })
  const token = authHeader.replace('Bearer ', '')
  const userId = tokens.get(token)
  if (!userId) return res.status(401).json({ message: '无效令牌' })
  const video = {
    id: videos.length + 1,
    user_id: userId,
    title: req.body.title,
    description: req.body.description,
    video_url: 'https://example.com/video.mp4',
    thumbnail_url: 'https://picsum.photos/640/360',
    is_public: req.body.is_public,
    created_at: new Date().toISOString()
  }
  videos.push(video)
  res.json({ message: '视频创建成功', id: video.id })
})

app.delete('/api/videos/:id', (req, res) => {
  const authHeader = req.headers.authorization
  if (!authHeader) return res.status(401).json({ message: '未登录' })
  const token = authHeader.replace('Bearer ', '')
  const userId = tokens.get(token)
  const idx = videos.findIndex(v => v.id === parseInt(req.params.id) && v.user_id === userId)
  if (idx === -1) return res.status(404).json({ message: '视频不存在或无权删除' })
  videos.splice(idx, 1)
  res.json({ message: '删除成功' })
})

app.get('/api/users/me/stats', (req, res) => {
  const authHeader = req.headers.authorization
  if (!authHeader) return res.status(401).json({ message: '未登录' })
  const token = authHeader.replace('Bearer ', '')
  const userId = tokens.get(token)
  if (!userId) return res.status(401).json({ message: '无效令牌' })
  const userVideos = videos.filter(v => v.user_id === userId)
  res.json({
    total_videos: userVideos.length,
    public_videos: userVideos.filter(v => v.is_public).length,
    private_videos: userVideos.filter(v => !v.is_public).length
  })
})

app.listen(PORT, () => {
  console.log(`🦋 Mock API Server running on http://localhost:${PORT}`)
})
