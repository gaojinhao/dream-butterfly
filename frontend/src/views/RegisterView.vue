<template>
  <div class="register-container">
    <div class="register-card">
      <h2>创建账号</h2>
      <form @submit.prevent="handleRegister">
        <div class="form-group">
          <label for="username">用户名</label>
          <input type="text" id="username" v-model="username" required placeholder="请输入用户名" minlength="3" maxlength="20" />
        </div>
        <div class="form-group">
          <label for="email">邮箱</label>
          <input type="email" id="email" v-model="email" required placeholder="请输入邮箱地址" />
        </div>
        <div class="form-group">
          <label for="password">密码</label>
          <input type="password" id="password" v-model="password" required placeholder="请输入密码" minlength="6" />
        </div>
        <div class="form-group">
          <label for="confirmPassword">确认密码</label>
          <input type="password" id="confirmPassword" v-model="confirmPassword" required placeholder="请再次输入密码" />
        </div>
        <div v-if="passwordMismatch" class="error-message">两次输入的密码不一致</div>
        <div v-if="authStore.error" class="error-message">{{ authStore.error }}</div>
        <button type="submit" :disabled="authStore.loading || !!passwordMismatch" class="submit-btn">
          {{ authStore.loading ? '注册中...' : '注册' }}
        </button>
      </form>
      <p class="switch-form">已有账号？<router-link to="/login">立即登录</router-link></p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const username = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')

const passwordMismatch = computed(() => {
  return password.value && confirmPassword.value && password.value !== confirmPassword.value
})

const handleRegister = async () => {
  if (passwordMismatch.value) return
  const success = await authStore.register(username.value, email.value, password.value)
  if (success) router.push('/')
}
</script>

<style scoped>
.register-container { display: flex; justify-content: center; align-items: center; min-height: calc(100vh - 200px); }
.register-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
}
.register-card h2 { text-align: center; color: #2c3e50; margin-bottom: 2rem; }
.form-group { margin-bottom: 1.25rem; }
.form-group label { display: block; margin-bottom: 0.5rem; color: #2c3e50; font-weight: 500; }
.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
}
.form-group input:focus { outline: none; border-color: #667eea; }
.error-message { background: #fee2e2; color: #dc2626; padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; font-size: 0.9rem; }
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
