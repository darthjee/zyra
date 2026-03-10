.PHONY: build dev tests

PROJECT?=zyra
IMAGE?=$(PROJECT)
BASE_IMAGE?=$(DOCKER_ID_USER)/$(PROJECT)-base
DOCKER_FILE_BASE=Dockerfile.$(PROJECT)-base

all:
	@echo "Usage:"
	@echo "  make build\n    Build docker image for $(PROJECT)"
	@echo "  make dev\n    Run development environment for $(PROJECT)"
	@echo "  make tests\n    Run tests for $(PROJECT)"

build:
	docker build -f Dockerfile.$(PROJECT) . -t $(IMAGE) -t $(PUSH_IMAGE):latest

tests:
	docker-compose run $(PROJECT)_tests /bin/bash

dev:
	docker-compose run $(PROJECT) /bin/bash
