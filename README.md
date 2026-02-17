# JobTracker

A job application tracking system built with a microservices architecture.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Nginx (port 80)                   │
│                     Reverse Proxy / Router               │
└──────┬──────────────────────┬────────────────┬──────────┘
       │                      │                │
       ▼                      ▼                ▼
┌─────────────┐     ┌─────────────────┐  ┌──────────────┐
│  React/Vite  │     │   Laravel API   │  │ Spring Boot  │
│  (port 5173) │     │   (port 8000)   │  │ (port 8080)  │
│   Frontend   │     │  Auth / Users   │  │ Applications │
└─────────────┘     └────────┬────────┘  └──────┬───────┘
                              │                  │
                    ┌─────────▼──────────────────▼───────┐
                    │              MySQL (port 3306)       │
                    │              Redis (port 6379)       │
                    └────────────────────────────────────┘
```

## Services

| Service           | Port | Description                        |
|-------------------|------|------------------------------------|
| nginx             | 80   | Reverse proxy & router             |
| laravel           | 8000 | Auth, users, internal APIs         |
| laravel-worker    | -    | Queue worker                       |
| laravel-scheduler | -    | Scheduled tasks (cron)             |
| spring            | 8080 | Applications, extractor, analytics |
| frontend          | 5173 | React + TypeScript UI (Vite)       |
| mysql             | 3306 | MySQL 8.0 database                 |
| redis             | 6379 | Cache & queue                      |

## API Routing

| Path Pattern                    | Service      |
|---------------------------------|--------------|
| `/api/auth/**`                  | Laravel      |
| `/api/user/**`                  | Laravel      |
| `/api/internal/**`              | Laravel      |
| `/api/applications/**`          | Spring Boot  |
| `/api/extractor/**`             | Spring Boot  |
| `/api/analytics/**`             | Spring Boot  |
| `/**`                           | Frontend     |

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 20+ (for local frontend dev)
- Make

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/jobtracker.git
cd jobtracker

# 2. Create environment file
make env
# Edit .env with your values

# 3. Build and start all services
make build
make up

# 4. Run database migrations
make laravel-migrate
```

The app will be available at [http://localhost](http://localhost).

## Common Commands

```bash
make up                  # Start all services
make down                # Stop all services
make build               # Build all images
make logs                # Tail all logs
make logs s=laravel      # Tail Laravel logs only
make laravel-migrate     # Run Laravel migrations
make laravel-fresh       # Fresh migrate + seed
make laravel-shell       # Shell into Laravel container
make spring-shell        # Shell into Spring container
make mysql-shell         # Open MySQL shell
make fresh               # Rebuild everything from scratch
```

## Project Structure

```
jobtracker/
├── services/
│   ├── laravel-api/     # Laravel 12 - Auth & User Management
│   ├── spring-api/      # Spring Boot 4 - Application Tracking
│   └── frontend/        # React + TypeScript (Vite)
├── nginx/
│   └── conf.d/          # Nginx configuration
├── docker/
│   ├── mysql/init/      # MySQL initialization scripts
│   └── redis/           # Redis configuration
├── docker-compose.yml       # Development
├── docker-compose.prod.yml  # Production
├── Makefile
└── .env.example
```

## Development

Each service can also be run independently for development:

```bash
# Laravel
cd services/laravel-api
composer install
cp .env.example .env
php artisan serve

# Spring Boot
cd services/spring-api
./mvnw spring-boot:run

# Frontend
cd services/frontend
npm install
npm run dev
```
