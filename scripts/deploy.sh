#!/bin/bash

# Dream Butterfly Local Deployment Script
# This script helps set up the development environment

set -e

echo "🦋 Dream Butterfly - Local Deployment Setup"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo ""
echo "Checking prerequisites..."

# Check Docker
if command -v docker &> /dev/null; then
    print_status "Docker is installed: $(docker --version)"
else
    print_warning "Docker is not installed. Please install Docker first."
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    print_status "Docker Compose is installed: $(docker-compose --version)"
else
    print_warning "Docker Compose is not installed."
fi

# Check MySQL
if command -v mysql &> /dev/null; then
    print_status "MySQL client is installed: $(mysql --version)"
else
    print_warning "MySQL client is not installed."
fi

# Check Rust
if command -v cargo &> /dev/null; then
    print_status "Rust is installed: $(cargo --version)"
else
    print_warning "Rust is not installed."
fi

# Check Node.js
if command -v node &> /dev/null; then
    print_status "Node.js is installed: $(node --version)"
else
    print_warning "Node.js is not installed."
fi

echo ""
echo "Setup Options:"
echo "1. Quick start with Docker (recommended)"
echo "2. Manual setup for backend only"
echo "3. Manual setup for frontend only"
echo "4. Verify configuration files"
echo "5. Exit"

read -p "Please select an option (1-5): " option

case $option in
    1)
        echo ""
        echo "Starting Docker deployment..."
        if [ -f "docker-compose.yml" ]; then
            print_status "docker-compose.yml found"
            echo ""
            echo "To start the application:"
            echo "  docker-compose up -d"
            echo ""
            echo "To view logs:"
            echo "  docker-compose logs -f"
            echo ""
            echo "To stop the application:"
            echo "  docker-compose down"
        else
            print_error "docker-compose.yml not found!"
        fi
        ;;
    2)
        echo ""
        echo "Backend Setup Instructions:"
        echo "==========================="
        echo ""
        echo "1. Install Rust:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo ""
        echo "2. Install MySQL and create database:"
        echo "   sudo apt install mysql-server"
        echo "   sudo mysql"
        echo "   > CREATE DATABASE dream_butterfly;"
        echo ""
        echo "3. Copy environment file:"
        echo "   cp backend/.env.example backend/.env"
        echo "   # Edit backend/.env with your database credentials"
        echo ""
        echo "4. Run database migrations:"
        echo "   mysql -u root -p dream_butterfly < backend/migrations/001_init.sql"
        echo ""
        echo "5. Build and run backend:"
        echo "   cd backend"
        echo "   cargo run"
        ;;
    3)
        echo ""
        echo "Frontend Setup Instructions:"
        echo "============================"
        echo ""
        echo "1. Install Node.js (if not installed):"
        echo "   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
        echo "   sudo apt-get install -y nodejs"
        echo ""
        echo "2. Install dependencies:"
        echo "   cd frontend"
        echo "   npm install"
        echo ""
        echo "3. Create .env file:"
        echo "   echo 'VITE_API_URL=http://localhost:8080' > .env"
        echo ""
        echo "4. Run development server:"
        echo "   npm run dev"
        echo ""
        echo "5. Build for production:"
        echo "   npm run build"
        ;;
    4)
        echo ""
        echo "Verifying configuration files..."
        echo ""
        
        files=(
            "backend/Cargo.toml:Backend package config"
            "backend/src/main.rs:Backend entry point"
            "backend/src/models.rs:Data models"
            "backend/src/handlers/auth.rs:Auth handlers"
            "backend/src/handlers/video.rs:Video handlers"
            "backend/src/routes/auth.rs:Auth routes"
            "backend/src/routes/video.rs:Video routes"
            "backend/migrations/001_init.sql:Database migration"
            "frontend/package.json:Frontend package config"
            "frontend/vite.config.ts:Vite configuration"
            "frontend/tsconfig.json:TypeScript config"
            "frontend/src/main.ts:Frontend entry"
            "frontend/src/App.vue:Root component"
            "frontend/src/router/index.ts:Router config"
            "frontend/src/views/HomeView.vue:Home view"
            "frontend/src/stores/auth.ts:Auth store"
            "docker-compose.yml:Docker compose config"
            "backend/Dockerfile:Backend Docker image"
            "frontend/Dockerfile:Frontend Docker image"
        )
        
        all_found=true
        for item in "${files[@]}"; do
            IFS=':' read -r file desc <<< "$item"
            if [ -f "$file" ]; then
                print_status "$desc: $file"
            else
                print_error "Missing: $desc ($file)"
                all_found=false
            fi
        done
        
        echo ""
        if $all_found; then
            print_status "All configuration files are present!"
        else
            print_error "Some files are missing!"
        fi
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option!"
        exit 1
        ;;
esac

echo ""
echo "Deployment setup complete!"
