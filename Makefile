FROM_IMAGE := $(shell grep -P ^FROM Dockerfile | cut -d' ' -f2)

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

ifeq ($(GIT_BRANCH),master)
  DOCKER_TAG := latest
else
  DOCKER_TAG := $(GIT_BRANCH)
endif

IMAGE := lazyfrosch/icingaweb2:$(DOCKER_TAG)

all: pull build

pull:
	docker pull $(IMAGE) || true
	docker pull $(FROM_IMAGE)

build:
	docker build --force-rm --tag $(IMAGE) .

push:
	docker push $(IMAGE)
