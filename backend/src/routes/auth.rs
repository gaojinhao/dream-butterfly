use axum::{routing::post, Router};
use crate::handlers::auth::{register, login};

pub fn auth_routes() -> Router {
    Router::new()
        .route("/api/auth/register", post(register))
        .route("/api/auth/login", post(login))
}
