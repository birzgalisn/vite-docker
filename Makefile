DOCKER_COMPOSE := docker compose --env-file .env

DEV := $(DOCKER_COMPOSE) -f .docker/development/docker-compose.yaml
PROD := $(DOCKER_COMPOSE) -f .docker/production/docker-compose.yaml

BUILD := build --parallel
UP := up
REMOVE := down -v --remove-orphans

.PHONY: build-dev
build-dev:
	$(DEV) $(BUILD)

.PHONY: start-dev
start-dev:
	$(DEV) $(UP)

.PHONY: remove-dev
remove-dev:
	$(DEV) $(REMOVE)

.PHONY: build-prod
build-prod:
	$(PROD) $(BUILD)

.PHONY: start-prod
start-prod:
	$(PROD) $(UP)

.PHONY: remove-prod
remove-prod:
	$(PROD) $(REMOVE)
