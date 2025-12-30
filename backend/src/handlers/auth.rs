use axum::{extract::State, Json, response::Result};
use sqlx::MySqlPool;
use crate::models::{CreateUserRequest, LoginRequest, AuthResponse, UserResponse, ErrorResponse};
use crate::utils::{hash_password, verify_password, create_jwt_token, validate_email, validate_password, validate_username};

pub async fn register(
    State(pool): State<MySqlPool>,
    Json(req): Json<CreateUserRequest>,
) -> Result<Json<AuthResponse>, Json<ErrorResponse>> {
    if !validate_username(&req.username) {
        return Err(Json(ErrorResponse { message: "用户名必须为3-20个字母、数字或下划线".to_string() }));
    }
    if !validate_email(&req.email) {
        return Err(Json(ErrorResponse { message: "邮箱格式不正确".to_string() }));
    }
    if !validate_password(&req.password) {
        return Err(Json(ErrorResponse { message: "密码必须至少6个字符".to_string() }));
    }

    let password_hash = hash_password(&req.password).map_err(|_| {
        Json(ErrorResponse { message: "密码处理失败".to_string() })
    })?;

    let result = sqlx::query!(
        "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)",
        req.username, req.email, password_hash
    ).execute(&pool).await;

    match result {
        Ok(res) => {
            let user_id = res.last_insert_id() as i32;
            let token = create_jwt_token(user_id, &req.email).map_err(|_| {
                Json(ErrorResponse { message: "生成令牌失败".to_string() })
            })?;

            let user = UserResponse {
                id: user_id,
                username: req.username,
                email: req.email,
                created_at: chrono::Utc::now().naive_utc(),
            };

            Ok(Json(AuthResponse { user, token }))
        }
        Err(sqlx::Error::Database(err)) => {
            if err.is_unique_constraint_violation() {
                Err(Json(ErrorResponse { message: "用户名或邮箱已存在".to_string() }))
            } else {
                Err(Json(ErrorResponse { message: "注册失败".to_string() }))
            }
        }
        Err(_) => Err(Json(ErrorResponse { message: "服务器错误".to_string() })),
    }
}

pub async fn login(
    State(pool): State<MySqlPool>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<AuthResponse>, Json<ErrorResponse>> {
    let user: Option<(i32, String, String, String)> = sqlx::query_as(
        "SELECT id, username, email, password_hash FROM users WHERE email = ?"
    ).bind(&req.email)
    .fetch_optional(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "服务器错误".to_string() }))?;

    match user {
        Some((id, username, email, password_hash)) => {
            let valid = verify_password(&req.password, &password_hash).map_err(|_| {
                Json(ErrorResponse { message: "密码验证失败".to_string() })
            })?;

            if !valid {
                return Err(Json(ErrorResponse { message: "密码错误".to_string() }));
            }

            let token = create_jwt_token(id, &email).map_err(|_| {
                Json(ErrorResponse { message: "生成令牌失败".to_string() })
            })?;

            let user = UserResponse {
                id,
                username,
                email,
                created_at: chrono::Utc::now().naive_utc(),
            };

            Ok(Json(AuthResponse { user, token }))
        }
        None => Err(Json(ErrorResponse { message: "用户不存在".to_string() })),
    }
}
