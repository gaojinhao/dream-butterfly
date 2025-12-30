<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <router-link to="/">🦋 Dream Butterfly</router-link>
      </div>
      <div class="nav-links">
        <router-link to="/">首页</router-link>
        <template v-if="isLoggedIn">
          <router-link to="/create">创建视频</router-link>
          <router-link to="/my-videos">我的视频</router-link>
          <router-link to="/profile">个人中心</router-link>
          <button @click="logout" class="logout-btn">退出</button>
        </template>
        <template v-else>
          <router-link to="/login">登录</router-link>
          <router-link to="/register">注册</router-link>
        </template>
      </div>
    </nav>
    <main class="main-content">
      <router-view />
    </main>
    <footer class="footer">
      <p>&copy; 2025 Dream Butterfly. Licensed under Mulan PSL v2.</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const isLoggedIn = computed(() => authStore.isAuthenticated)

const logout = () => {
  authStore.logout()
  router.push('/')
}
</script>

<style scoped>
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
.nav-brand a {
  font-size: 1.5rem;
  font-weight: bold;
  color: white;
  text-decoration: none;
}
.nav-links {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}
.nav-links a {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  transition: background-color 0.3s;
}
.nav-links a:hover {
  background-color: rgba(255, 255, 255, 0.2);
}
.logout-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
}
.main-content {
  min-height: calc(100vh - 140px);
  padding: 2rem;
  background: linear-gradient(180deg, #f5f7fa 0%, #e4e8ec 100%);
}
.footer {
  text-align: center;
  padding: 1rem;
  background: #2c3e50;
  color: white;
}
</style>
