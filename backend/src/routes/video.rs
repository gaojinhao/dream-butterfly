use axum::{routing::{get, delete}, Router};
use crate::handlers::video::{list_videos, get_video, list_my_videos, delete_video, get_user_stats};

pub fn video_routes() -> Router {
    Router::new()
        .route("/api/videos", get(list_videos))
        .route("/api/videos/my", get(list_my_videos))
        .route("/api/videos/:id", get(get_video))
        .route("/api/videos/:id", delete(delete_video))
        .route("/api/users/me/stats", get(get_user_stats))
}
