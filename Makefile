FROM_IMAGE := $(shell grep -P ^FROM Dockerfile | cut -d' ' -f2)
IMAGE := lazyfrosch/icingaweb2:latest

all: pull build

pull:
	docker pull $(IMAGE) || true
	docker pull $(FROM_IMAGE)

build:
	docker build --rm --cache-from $(IMAGE) --tag $(IMAGE) .

push:
	docker push $(IMAGE)
