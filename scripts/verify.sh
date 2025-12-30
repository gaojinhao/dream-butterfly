#!/bin/bash

# Dream Butterfly CI/CD Verification Script
# This script verifies the CI/CD configuration is correct

set -e

echo "🦋 Dream Butterfly - CI/CD Verification"
echo "========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

FAILED=0

echo ""
echo "1. Checking GitHub Actions Workflows..."
echo "----------------------------------------"

workflows=(
    ".github/workflows/frontend-ci.yml:Frontend CI"
    ".github/workflows/backend-ci.yml:Backend CI"
    ".github/workflows/cd.yml:CD Deployment"
)

for item in "${workflows[@]}"; do
    IFS=':' read -r file desc <<< "$item"
    if [ -f "$file" ]; then
        print_status "$desc: $file"
        
        # Check file is valid YAML
        if command -v python3 &> /dev/null; then
            if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                print_status "  └─ Valid YAML syntax"
            else
                print_error "  └─ Invalid YAML syntax!"
                FAILED=1
            fi
        fi
        
        # Check for required sections
        if grep -q "on:" "$file"; then
            print_status "  └─ Has trigger conditions"
        else
            print_warning "  └─ Missing trigger conditions"
        fi
        
        if grep -q "jobs:" "$file"; then
            print_status "  └─ Has jobs defined"
        else
            print_error "  └─ Missing jobs!"
            FAILED=1
        fi
    else
        print_error "$desc: $file (MISSING)"
        FAILED=1
    fi
done

echo ""
echo "2. Checking Docker Configuration..."
echo "------------------------------------"

docker_files=(
    "docker-compose.yml:Docker Compose"
    "backend/Dockerfile:Backend Dockerfile"
    "frontend/Dockerfile:Frontend Dockerfile"
    "frontend/nginx.conf:Nginx Config"
)

for item in "${docker_files[@]}"; do
    IFS=':' read -r file desc <<< "$item"
    if [ -f "$file" ]; then
        print_status "$desc: $file"
    else
        print_error "$desc: $file (MISSING)"
        FAILED=1
    fi
done

echo ""
echo "3. Checking Backend Configuration..."
echo "-------------------------------------"

backend_files=(
    "backend/Cargo.toml:Cargo config"
    "backend/src/main.rs:Entry point"
    "backend/src/models.rs:Models"
    "backend/src/handlers/auth.rs:Auth handler"
    "backend/src/handlers/video.rs:Video handler"
    "backend/src/routes/auth.rs:Auth routes"
    "backend/src/routes/video.rs:Video routes"
    "backend/migrations/001_init.sql:DB migration"
)

for item in "${backend_files[@]}"; do
    IFS=':' read -r file desc <<< "$item"
    if [ -f "$file" ]; then
        print_status "$desc: $file"
    else
        print_error "$desc: $file (MISSING)"
        FAILED=1
    fi
done

echo ""
echo "4. Checking Frontend Configuration..."
echo "--------------------------------------"

frontend_files=(
    "frontend/package.json:NPM config"
    "frontend/vite.config.ts:Vite config"
    "frontend/tsconfig.json:TypeScript config"
    "frontend/src/main.ts:Entry point"
    "frontend/src/App.vue:Root component"
    "frontend/src/router/index.ts:Router"
    "frontend/src/stores/auth.ts:Auth store"
)

for item in "${frontend_files[@]}"; do
    IFS=':' read -r file desc <<< "$item"
    if [ -f "$file" ]; then
        print_status "$desc: $file"
    else
        print_error "$desc: $file (MISSING)"
        FAILED=1
    fi
done

echo ""
echo "5. Summary"
echo "---------"

if [ $FAILED -eq 0 ]; then
    print_status "All CI/CD configuration files are present and valid!"
    echo ""
    echo "To deploy locally with Docker:"
    echo "  1. Make sure Docker is running"
    echo "  2. Run: docker-compose up -d"
    echo "  3. Access frontend at http://localhost:3000"
    echo "  4. Access backend API at http://localhost:8080"
    exit 0
else
    print_error "Some configuration files are missing or invalid!"
    exit 1
fi
