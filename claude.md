# Dream Butterfly 项目 Claude AI 开发规范

## 一、核心角色定位

### 1.1 Claude职责范围
- **主要职责**：功能开发、代码实现、Bug修复
- **辅助职责**：编写单元测试、编写API文档
- **禁止操作**：代码审查、安全漏洞检测、架构设计决策

### 1.2 Git分支策略
```
main        ───────── stable, production-ready
dev         ───────── development integration
feature/*   ───────── Claude开发单个功能的分支
```

### 1.3 分支命名规范
```
feature/user-auth          # 用户认证功能
feature/image-upload       # 图片上传功能
feature/video-generation   # 视频生成功能
feature/video-management   # 视频管理功能
fix/login-bug              # 修复登录Bug
```

## 二、开发工作流程

### 2.1 准备阶段
1. 从dev分支创建功能分支：
```bash
git checkout dev
git pull origin dev
git checkout -b feature/xxx
```

2. 创建功能目录（符合项目结构）：
```
frontend/src/
├── views/       # 页面组件
├── components/  # 通用组件
├── stores/      # Pinia状态管理
├── router/      # 路由配置
├── api/         # API调用
└── utils/       # 工具函数

backend/src/
├── models/      # 数据模型
├── handlers/    # 业务逻辑
├── middleware/  # 中间件
├── routes/      # 路由定义
└── utils/       # 工具函数
```

### 2.2 代码开发规范

#### 前端代码规范（Vue 3）
- 使用Composition API（`<script setup>`）
- 类型定义使用TypeScript
- 组件文件命名：PascalCase（如 UserLogin.vue）
- 样式使用scoped CSS或Tailwind CSS

#### 后端代码规范（Rust）
- 使用Axum Web框架
- 数据访问层使用SQLx
- 错误处理使用thiserror
- 配置管理使用dotenvy

### 2.3 提交信息规范

#### 提交信息格式
```
<type>: <subject>

<body>

<footer>
```

#### Type类型
| 类型 | 描述 | 示例 |
|------|------|------|
| feat | 新功能 | `feat: 实现用户注册功能` |
| fix | Bug修复 | `fix: 修复登录密码验证漏洞` |
| docs | 文档更新 | `docs: 更新API接口文档` |
| style | 代码格式 | `style: 格式化代码风格` |
| refactor | 重构代码 | `refactor: 重构认证中间件` |
| test | 测试相关 | `test: 添加登录单元测试` |
| chore | 构建配置 | `chore: 更新依赖版本` |

#### 提交示例
```
feat: 实现用户注册API接口

- 添加用户注册POST端点 /api/auth/register
- 实现密码bcrypt加密存储
- 添加邮箱格式验证
- 返回JWT令牌

Closes #123
```

#### 每提交限制
- **核心要求**：单个提交不超过200行代码变化
- **特殊情况**：如功能必须超过200行，拆分为多个原子提交
- **提交粒度**：每个提交只做一件事情

### 2.4 提交检查清单

提交前必须确认：
- [ ] 代码编译/构建通过
- [ ] 遵循代码风格规范
- [ ] 已添加必要的类型注解
- [ ] 提交信息符合规范格式
- [ ] 代码变化不超过200行（或已拆分）

### 2.5 提交并推送流程

```bash
# 1. 开发完成，添加到暂存区
git add <files>

# 2. 编写规范提交信息
git commit -m "feat: 实现用户登录功能

- 添加登录表单组件
- 实现JWT令牌生成
- 添加认证中间件

Closes #123"

# 3. 推送到远程功能分支
git push origin feature/user-auth

# 4. 创建Pull Request到dev分支
```

## 三、功能开发模板

### 3.1 功能开发检查表
- [ ] 创建功能分支
- [ ] 实现核心功能代码
- [ ] 添加必要的类型定义
- [ ] 编写单元测试
- [ ] 更新API文档
- [ ] 提交代码（符合规范）
- [ ] 创建PR请求审核

### 3.2 代码变更限制确认
```
本次提交变更行数：____ 行（限制200行以内）
如超过，请说明拆分情况：
_______________________________________________
```

## 四、PR模板

```markdown
## 功能描述
<!-- 描述本次提交的功能或修复的问题 -->

## 代码变更
<!-- 列出变更的文件和行数 -->

## 测试情况
<!-- 描述测试方法和结果 -->

## 自检项
- [ ] 代码编译/构建通过
- [ ] 符合代码风格规范
- [ ] 有必要的类型注解
- [ ] 提交信息格式正确
- [ ] 单次提交不超过200行

## 关联Issue
<!-- 关联的Issue编号 -->
```

## 五、项目技术栈

- **前端**：Vue 3 + TypeScript + Vite + Pinia + Axios
- **后端**：Rust + Axum + SQLx + MySQL
- **认证**：JWT（JSON Web Tokens）

## 六、API端点规范

### 认证接口
| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/auth/register | 用户注册 |
| POST | /api/auth/login | 用户登录 |
| POST | /api/auth/logout | 退出登录 |
| GET | /api/auth/me | 获取当前用户 |

### 视频接口
| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/videos | 创建视频 |
| GET | /api/videos | 视频列表 |
| GET | /api/videos/:id | 视频详情 |
| DELETE | /api/videos/:id | 删除视频 |

## 七、数据库表结构

### users用户表
- id：主键
- username：用户名（唯一）
- email：邮箱（唯一）
- password_hash：密码哈希
- created_at：创建时间
- updated_at：更新时间

### videos视频表
- id：主键
- user_id：外键关联用户
- title：标题
- description：描述
- video_url：视频地址
- thumbnail_url：缩略图地址
- is_public：是否公开
- created_at：创建时间
- updated_at：更新时间

## 八、关键开发原则

1. **禁止直接提交到main或dev分支**
2. **每个功能一个独立分支**
3. **提交信息必须包含类型前缀**
4. **单次提交不超过200行**
5. **必须创建PR进行代码审核**
6. **遵循Git提交原子性原则**

## 九、联系与协作

- **代码审查**：由Gemini AI负责
- **安全审计**：由Gemini AI负责
- **最终审核**：人工审核确认
