.PHONY: up down build logs restart laravel-migrate laravel-shell spring-shell mysql-shell fresh help

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
	@echo ""
	@echo "  Laravel"
	@echo "  -------"
	@echo "  make laravel-migrate   Run database migrations"
	@echo "  make laravel-seed      Run database seeders"
	@echo "  make laravel-fresh     Fresh migrate + seed"
	@echo "  make laravel-shell     Open shell in Laravel container"
	@echo "  make laravel-tinker    Open Laravel Tinker"
	@echo ""
	@echo "  Spring"
	@echo "  ------"
	@echo "  make spring-shell    Open shell in Spring container"
	@echo ""
	@echo "  Database"
	@echo "  --------"
	@echo "  make mysql-shell     Open MySQL shell"
	@echo ""
	@echo "  Utilities"
	@echo "  ---------"
	@echo "  make fresh           Stop, rebuild, and restart everything"
	@echo "  make ps              Show running containers"
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

# ─── Laravel ──────────────────────────────────────────────────────────────────
laravel-migrate:
	docker compose exec laravel php artisan migrate

laravel-seed:
	docker compose exec laravel php artisan db:seed

laravel-fresh:
	docker compose exec laravel php artisan migrate:fresh --seed

laravel-shell:
	docker compose exec laravel sh

laravel-tinker:
	docker compose exec laravel php artisan tinker

laravel-test:
	docker compose exec laravel php artisan test

laravel-cache-clear:
	docker compose exec laravel php artisan cache:clear
	docker compose exec laravel php artisan config:clear
	docker compose exec laravel php artisan route:clear
	docker compose exec laravel php artisan view:clear

# ─── Spring ───────────────────────────────────────────────────────────────────
spring-shell:
	docker compose exec spring sh

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
	docker compose exec laravel php artisan migrate --force

env:
	cp .env.example .env
	@echo ".env created from .env.example"
