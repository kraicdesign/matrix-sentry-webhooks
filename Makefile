$(shell (if [ ! -e .env ]; then echo 'Please, create .env file first!'; exit; fi))
include .env
export

CUR_DIR = $(shell basename $(CURDIR))

.PHONY: install
install: erase build start## clean current environment, recreate dependencies and spin up again

.PHONY: start
start: ##up-services ## spin up environment
	docker-compose up -d

.PHONY: stop
stop: ## stop environment
	docker-compose stop

.PHONY: remove
remove: ## remove project docker containers
	docker-compose rm -v -f

.PHONY: erase
erase: stop remove remove-images ## stop and delete containers, clean volumes

.PHONY: build
build: ## build environment and initialize composer and project dependencies
	docker build . -t docker.local/$(CI_PROJECT_PATH)/webhook

.PHONY: remove-images
remove-images: ## Remove generated images
	$(shell [ ! -z "$(docker images -q docker.local/$(CI_PROJECT_PATH)/webhook)" ] && docker image rm docker.local/$(CI_PROJECT_PATH)/webhook)

.PHONY: apply-env
apply-env: ## Applies content of .env file to running docker container
	docker exec -i webhook /bin/bash -c ""

.PHONY: logs
logs: ## Monitor docker logs
	docker-compose logs -f

.PHONY: bash
bash: ## Open container bash
	docker exec -it webhook bash