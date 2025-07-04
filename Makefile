help:
	@echo "Makefile commands:"
	@echo "  \033[0;32mup\033[0m          - Start all services"
	@echo "  \033[0;32mup_fr\033[0m       - Start French services"
	@echo "  \033[0;32mup_ch\033[0m       - Start Swiss services"
	@echo "  \033[0;32mup_us\033[0m       - Start US services"
	@echo "  \033[0;32mdown\033[0m        - Stop all services"
	@echo "  \033[0;32mdown_fr\033[0m     - Stop French services"
	@echo "  \033[0;32mdown_ch\033[0m     - Stop Swiss services"
	@echo "  \033[0;32mdown_us\033[0m     - Stop US services"
	@echo "  \033[0;32mrmi\033[0m         - Remove all mspr-601 Docker images"
	@echo "  \033[0;32mbuild\033[0m       - Clean images and rebuild all services"
	@echo "  \033[0;32mbuild_fr\033[0m    - Clean images and rebuild French services"
	@echo "  \033[0;32mbuild_ch\033[0m    - Clean images and rebuild Swiss services"
	@echo "  \033[0;32mbuild_us\033[0m    - Clean images and rebuild US services"
	@echo "  \033[0;32mhelp\033[0m        - Show this help message"

up:
	$(MAKE) up_fr
	$(MAKE) up_ch
	$(MAKE) up_us

up_fr:
	docker compose -f docker-compose.fr.yaml up -d --build

up_ch:
	docker compose -f docker-compose.ch.yaml up -d --build

up_us:
	docker compose -f docker-compose.us.yaml up -d --build

down:
	$(MAKE) down_fr
	$(MAKE) down_ch
	$(MAKE) down_us

down_fr:
	docker compose -f docker-compose.fr.yaml down

down_ch:
	docker compose -f docker-compose.ch.yaml down

down_us:
	docker compose -f docker-compose.us.yaml down

rmi:
	docker rmi mspr-601-front-fr mspr-601-front-ch mspr-601-front-us mspr-601-ml-fr mspr-601-ml-us mspr-601-ml-ch mspr-601-postgres-us mspr-601-postgres-fr mspr-601-postgres-ch mspr-601-etl-us mspr-601-etl-fr mspr-601-etl-ch mspr-601-api-ia-us mspr-601-api-ia-fr mspr-601-api-ia-ch mspr-601-pg-admin-fr mspr-601-pg-admin-ch mspr-601-pg-admin-us

build:
	$(MAKE) down
	$(MAKE) rmi
	$(MAKE) up_fr
	$(MAKE) up_ch
	$(MAKE) up_us

build_fr:
	$(MAKE) down_fr
	$(MAKE) rmi
	$(MAKE) up_fr

build_ch:
	$(MAKE) down_ch
	$(MAKE) rmi
	$(MAKE) up_ch

build_us:
	$(MAKE) down_us
	$(MAKE) rmi
	$(MAKE) up_us



