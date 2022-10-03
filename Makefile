GOLANG_VERSION := 1.19.1
ALPINE_VERSION := 3.16

DOCKER_REPO := michalsw
APPNAME := https-web-server

LOCAL_PORT ?= 8443
SERVER_PORT ?= 443

APP_PATH ?= /app

.DEFAULT_GOAL := help
.PHONY: run build docker-build docker-run docker-stop

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

run: ## Run app
	SERVER_PORT=$(LOCAL_PORT) \
	go run .

build: ## Build bin
	CGO_ENABLED=0 \
	go build \
	-v \
	-o $(APPNAME) .

docker-build: ## Build docker image
	docker build \
	--pull \
	--platform linux/amd64 \
	--build-arg GOLANG_VERSION="$(GOLANG_VERSION)" \
	--build-arg ALPINE_VERSION="$(ALPINE_VERSION)" \
	--build-arg APPNAME="$(APPNAME)" \
	--build-arg APP_PATH="$(APP_PATH)" \
	--tag="$(DOCKER_REPO)/$(APPNAME):latest" \
	.

docker-run: ## Run docker
	docker run --rm -d \
	--pull \
	--env SERVER_PORT=$(SERVER_PORT) \
	-v $(realpath certs):"$(APP_PATH)/certs" \
	-p $(SERVER_PORT):$(SERVER_PORT) \
	--name $(APPNAME) \
	$(DOCKER_REPO)/$(APPNAME):latest && \
	docker ps

docker-stop: ## Stop docker
	docker stop $(APPNAME)
