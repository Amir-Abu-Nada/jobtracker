# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

JobTracker is a monorepo with a microservices architecture. All traffic enters through Nginx (port 80), which routes by URL prefix:

- `/api/auth/**`, `/api/user/**`, `/api/internal/**` → **laravel-auth** (port 8000): JWT auth, user management
- `/api/extractor/**` → **spring-scraping** (port 8081): job listing scraping & extraction
- `/api/applications/**`, `/api/analytics/**` → **spring-api** (port 8080): applications CRUD & analytics
- Everything else → **React/Vite Frontend** (port 5173)

All 4 backend services + frontend are **git submodules** with their own GitHub repos:

| Submodule | GitHub Repo | Role |
|---|---|---|
| `services/laravel-auth` | `jobtracker-laravel-auth` | Auth web server (PHP-FPM) |
| `services/laravel-emails` | `jobtracker-laravel-emails` | Email queue worker only (no HTTP port) |
| `services/spring-api` | `jobtracker-spring-api` | Applications & analytics |
| `services/spring-scraping` | `jobtracker-spring-scraping` | Web scraping & extractor |
| `services/frontend` | `jobtracker-frontend` | React + Vite UI |

The single root `.env` file is shared across all services via `env_file: - .env` in `docker-compose.yml`.

`laravel-emails` is a queue-worker-only service — it consumes from the `emails` Redis queue and sends transactional emails. It has no exposed HTTP port.

## Common Commands

All orchestration is through `make` from the repo root:

```bash
make up                        # Start all services
make down                      # Stop all services
make build                     # Build all Docker images
make fresh                     # Full teardown + rebuild + restart + migrate (deletes volumes)
make logs                      # Tail all logs
make logs s=laravel-auth       # Tail logs for a specific service
make ps                        # Show running containers

make laravel-auth-migrate      # Run Laravel Auth migrations
make laravel-auth-fresh        # migrate:fresh --seed
make laravel-auth-shell        # Shell into laravel-auth container
make laravel-auth-tinker       # Laravel Tinker REPL
make laravel-auth-test         # Run Laravel Auth tests
make laravel-auth-cache-clear  # Clear all Laravel caches

make laravel-emails-shell      # Shell into laravel-emails container
make laravel-emails-logs       # Tail laravel-emails logs

make spring-api-shell          # Shell into spring-api container
make spring-scraping-shell     # Shell into spring-scraping container
make mysql-shell               # Open MySQL shell
```

## Service-Specific Development

### Laravel Auth (`services/laravel-auth`)

- Laravel 12, PHP 8.2+, MySQL + Redis
- **Tests**: `make laravel-auth-test` (Docker) or `php artisan test` (local)
- **Single test**: `php artisan test --filter=TestClassName`
- **Linting/Formatting**: `./vendor/bin/pint` (Laravel Pint)
- **Local dev**: `composer install && php artisan serve`

### Laravel Emails (`services/laravel-emails`)

- Laravel 12 queue worker — no web server
- Consumes the `emails` Redis queue: `php artisan queue:work --queue=emails`
- Dockerfile uses `php:8.3-cli-alpine` (no FPM/nginx layers)
- **Local dev**: `composer install && php artisan queue:work --queue=emails`

### Spring API (`services/spring-api`)

- Spring Boot 4.0.2, Java 25, Maven, Spring Security, Lombok, JDBC
- Handles `/api/applications/**` and `/api/analytics/**`
- **Build**: `./mvnw package`
- **Run locally**: `./mvnw spring-boot:run`
- **Tests**: `./mvnw test` | Single test: `./mvnw test -Dtest=ClassName`
- Docker profile: `SPRING_PROFILES_ACTIVE=docker`

### Spring Scraping (`services/spring-scraping`)

- Spring Boot 4.0.2, Java 25, Maven — same stack as spring-api
- Handles `/api/extractor/**`
- **Build/run/test**: same Maven commands as spring-api above
- Runs on host port 8081 (container port 8080)

### Frontend (`services/frontend`)

- React 19 + TypeScript 5.9 + Vite 7
- **Dev server**: `npm run dev` (from `services/frontend/`)
- **Build**: `npm run build` (`tsc -b && vite build`)
- **Lint**: `npm run lint`
- API base URL configured via `VITE_API_URL` env var

## Initial Setup

```bash
make env        # Copy .env.example to .env (then fill in values)
make build      # Build all Docker images
make up         # Start services
make laravel-auth-migrate  # Run database migrations
```

After `make fresh` (destroys volumes), re-run `make laravel-auth-migrate` or `make laravel-auth-fresh`.

## Key Environment Variables

| Variable | Purpose |
|---|---|
| `APP_KEY` | Laravel app key (generate with `php artisan key:generate`) |
| `JWT_SECRET` | Shared JWT secret for inter-service auth |
| `DB_*` | MySQL credentials (shared between all services) |
| `REDIS_*` | Redis connection (Laravel cache/queue/session, Spring cache) |
| `VITE_API_URL` | Frontend API base URL |
| `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` | Optional: AI-powered extractor features in spring-scraping |
