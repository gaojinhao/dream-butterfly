use axum::{Router, routing::{post, get}};
use tower_http::cors::CorsLayer;
use sqlx::mysql::MySqlPoolOptions;
use dotenvy::dotenv;
use std::env;

mod models;
mod handlers;
mod routes;
mod middleware;
mod utils;

use routes::auth::auth_routes;
use routes::video::video_routes;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    dotenv().ok();
    
    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");
    
    let pool = MySqlPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await?;

    let app = Router::new()
        .route("/", get(|| async { "Dream Butterfly API Server" }))
        .merge(auth_routes())
        .merge(video_routes())
        .layer(CorsLayer::permissive())
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    println!("Server running on http://0.0.0.0:8080");
    axum::serve(listener, app).await.unwrap();

    Ok(())
}
