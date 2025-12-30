FROM rust:1.75-alpine AS builder

WORKDIR /app

RUN apk add --no-cache musl-dev openssl-dev

COPY backend/Cargo.toml backend/Cargo.lock ./
RUN mkdir src && touch src/main.rs
RUN cargo build --release --locked

COPY backend/src ./src
RUN cargo build --release --locked

FROM alpine:3.19

RUN apk add --no-cache openssl ca-certificates

WORKDIR /app

COPY --from=builder /app/target/release/dream-butterfly-backend .

EXPOSE 8080

ENV DATABASE_URL=mysql://root:password@localhost:3306/dream_butterfly

CMD ["./dream-butterfly-backend"]
