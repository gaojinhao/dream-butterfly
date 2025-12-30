use axum::{extract::{State, Path}, Json, response::Result};
use sqlx::MySqlPool;
use crate::models::{VideoWithUser, UserStats, ErrorResponse, VideoListResponse};

pub async fn list_videos(
    State(pool): State<MySqlPool>,
) -> Result<Json<VideoListResponse>, Json<ErrorResponse>> {
    let videos = sqlx::query_as!(
        VideoWithUser,
        r#"SELECT v.id, v.user_id, u.username, v.title, v.description, v.video_url, v.thumbnail_url, v.is_public, v.created_at FROM videos v JOIN users u ON v.user_id = u.id WHERE v.is_public = TRUE ORDER BY v.created_at DESC LIMIT 50"#
    ).fetch_all(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "获取视频列表失败".to_string() }))?;

    Ok(Json(VideoListResponse {
        videos,
        total: videos.len() as i64,
        page: 1,
        per_page: 50,
    }))
}

pub async fn get_video(
    State(pool): State<MySqlPool>,
    Path(id): Path<i32>,
) -> Result<Json<VideoWithUser>, Json<ErrorResponse>> {
    let video = sqlx::query_as!(
        VideoWithUser,
        r#"SELECT v.id, v.user_id, u.username, v.title, v.description, v.video_url, v.thumbnail_url, v.is_public, v.created_at FROM videos v JOIN users u ON v.user_id = u.id WHERE v.id = ?"#,
        id
    ).fetch_optional(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "获取视频失败".to_string() }))?;

    match video {
        Some(v) if v.is_public => Ok(Json(v)),
        Some(_) => Err(Json(ErrorResponse { message: "视频不存在或已被删除".to_string() })),
        None => Err(Json(ErrorResponse { message: "视频不存在".to_string() })),
    }
}

pub async fn list_my_videos(
    State(pool): State<MySqlPool>,
    user_id: i32,
) -> Result<Json<Vec<VideoWithUser>>, Json<ErrorResponse>> {
    let videos = sqlx::query_as!(
        VideoWithUser,
        r#"SELECT v.id, v.user_id, u.username, v.title, v.description, v.video_url, v.thumbnail_url, v.is_public, v.created_at FROM videos v JOIN users u ON v.user_id = u.id WHERE v.user_id = ? ORDER BY v.created_at DESC"#,
        user_id
    ).fetch_all(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "获取视频列表失败".to_string() }))?;

    Ok(Json(videos))
}

pub async fn delete_video(
    State(pool): State<MySqlPool>,
    Path(id): Path<i32>,
    user_id: i32,
) -> Result<Json<()>, Json<ErrorResponse>> {
    let result = sqlx::query!("DELETE FROM videos WHERE id = ? AND user_id = ?", id, user_id)
        .execute(&pool).await
        .map_err(|_| Json(ErrorResponse { message: "删除视频失败".to_string() }))?;

    if result.rows_affected() == 0 {
        return Err(Json(ErrorResponse { message: "视频不存在或无权删除".to_string() }));
    }

    Ok(Json(()))
}

pub async fn get_user_stats(
    State(pool): State<MySqlPool>,
    user_id: i32,
) -> Result<Json<UserStats>, Json<ErrorResponse>> {
    let total: i64 = sqlx::query_scalar!(
        "SELECT COUNT(*) FROM videos WHERE user_id = ?", user_id
    ).fetch_one(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "获取统计失败".to_string() }))?;

    let public_videos: i64 = sqlx::query_scalar!(
        "SELECT COUNT(*) FROM videos WHERE user_id = ? AND is_public = TRUE", user_id
    ).fetch_one(&pool).await
    .map_err(|_| Json(ErrorResponse { message: "获取统计失败".to_string() }))?;

    Ok(Json(UserStats {
        total_videos: total,
        public_videos,
        private_videos: total - public_videos,
    }))
}
