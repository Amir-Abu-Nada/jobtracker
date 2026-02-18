.PHONY: up down build logs restart ps fresh env help \
        laravel-auth-keys laravel-auth-migrate laravel-auth-seed laravel-auth-fresh laravel-auth-shell laravel-auth-tinker laravel-auth-test laravel-auth-cache-clear \
        laravel-emails-shell laravel-emails-logs \
        spring-api-shell spring-scraping-shell \
        mysql-shell

# ─── Default ──────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  JobTracker - Available Commands"
	@echo "  ================================"
	@echo ""
	@echo "  Docker"
	@echo "  ------"
	@echo "  make up              Start all services"
	@echo "  make down            Stop all services"
	@echo "  make build           Build all images"
	@echo "  make restart         Restart all services"
	@echo "  make logs            Tail logs for all services"
	@echo "  make logs s=<name>   Tail logs for a specific service"
	@echo "  make ps              Show running containers"
	@echo ""
	@echo "  Laravel Auth"
	@echo "  ------------"
	@echo "  make laravel-auth-keys        Generate RSA key pair for JWT"
	@echo "  make laravel-auth-migrate     Run database migrations"
	@echo "  make laravel-auth-seed        Run database seeders"
	@echo "  make laravel-auth-fresh       Fresh migrate + seed"
	@echo "  make laravel-auth-shell       Open shell in laravel-auth container"
	@echo "  make laravel-auth-tinker      Open Laravel Tinker"
	@echo "  make laravel-auth-test        Run tests"
	@echo "  make laravel-auth-cache-clear Clear all caches"
	@echo ""
	@echo "  Laravel Emails"
	@echo "  --------------"
	@echo "  make laravel-emails-shell     Open shell in laravel-emails container"
	@echo "  make laravel-emails-logs      Tail laravel-emails logs"
	@echo ""
	@echo "  Spring"
	@echo "  ------"
	@echo "  make spring-api-shell         Open shell in spring-api container"
	@echo "  make spring-scraping-shell    Open shell in spring-scraping container"
	@echo ""
	@echo "  Database"
	@echo "  --------"
	@echo "  make mysql-shell     Open MySQL shell"
	@echo ""
	@echo "  Utilities"
	@echo "  ---------"
	@echo "  make fresh           Stop, rebuild, and restart everything"
	@echo ""

# ─── Docker ───────────────────────────────────────────────────────────────────
up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

restart:
	docker compose restart

logs:
ifdef s
	docker compose logs -f $(s)
else
	docker compose logs -f
endif

ps:
	docker compose ps

# ─── Laravel Auth ─────────────────────────────────────────────────────────────
laravel-auth-keys:
	docker compose exec laravel-auth php artisan auth:generate-keys

laravel-auth-migrate:
	docker compose exec laravel-auth php artisan migrate

laravel-auth-seed:
	docker compose exec laravel-auth php artisan db:seed

laravel-auth-fresh:
	docker compose exec laravel-auth php artisan migrate:fresh --seed

laravel-auth-shell:
	docker compose exec laravel-auth sh

laravel-auth-tinker:
	docker compose exec laravel-auth php artisan tinker

laravel-auth-test:
	docker compose exec laravel-auth php artisan test

laravel-auth-cache-clear:
	docker compose exec laravel-auth php artisan cache:clear
	docker compose exec laravel-auth php artisan config:clear
	docker compose exec laravel-auth php artisan route:clear
	docker compose exec laravel-auth php artisan view:clear

# ─── Laravel Emails ───────────────────────────────────────────────────────────
laravel-emails-shell:
	docker compose exec laravel-emails sh

laravel-emails-logs:
	docker compose logs -f laravel-emails

# ─── Spring ───────────────────────────────────────────────────────────────────
spring-api-shell:
	docker compose exec spring-api sh

spring-scraping-shell:
	docker compose exec spring-scraping sh

# ─── Database ─────────────────────────────────────────────────────────────────
mysql-shell:
	docker compose exec mysql mysql -u $${DB_USERNAME:-jobtracker} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-jobtracker}

# ─── Utilities ────────────────────────────────────────────────────────────────
fresh:
	docker compose down -v
	docker compose build --no-cache
	docker compose up -d
	@echo "Waiting for services to start..."
	@sleep 10
	docker compose exec laravel-auth php artisan migrate --force

env:
	cp .env.example .env
	@echo ".env created from .env.example"
