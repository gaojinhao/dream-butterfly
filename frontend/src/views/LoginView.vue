<template>
  <div class="login-container">
    <div class="login-card">
      <h2>欢迎回来</h2>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="email">邮箱</label>
          <input type="email" id="email" v-model="email" required placeholder="请输入邮箱地址" />
        </div>
        <div class="form-group">
          <label for="password">密码</label>
          <input type="password" id="password" v-model="password" required placeholder="请输入密码" />
        </div>
        <div v-if="authStore.error" class="error-message">{{ authStore.error }}</div>
        <button type="submit" :disabled="authStore.loading" class="submit-btn">
          {{ authStore.loading ? '登录中...' : '登录' }}
        </button>
      </form>
      <p class="switch-form">还没有账号？<router-link to="/register">立即注册</router-link></p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')

const handleLogin = async () => {
  const success = await authStore.login(email.value, password.value)
  if (success) {
    const redirect = route.query.redirect as string
    router.push(redirect || '/')
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 200px);
}
.login-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
}
.login-card h2 {
  text-align: center;
  color: #2c3e50;
  margin-bottom: 2rem;
}
.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; margin-bottom: 0.5rem; color: #2c3e50; font-weight: 500; }
.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
}
.form-group input:focus { outline: none; border-color: #667eea; }
.error-message {
  background: #fee2e2;
  color: #dc2626;
  padding: 0.75rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
.submit-btn {
  width: 100%;
  padding: 0.75rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
}
.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.switch-form { text-align: center; margin-top: 1.5rem; color: #666; }
.switch-form a { color: #667eea; text-decoration: none; font-weight: 500; }
</style>
