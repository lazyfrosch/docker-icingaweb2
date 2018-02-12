FROM_IMAGE := $(shell grep -P ^FROM Dockerfile | cut -d' ' -f2)

all: pull build

pull:
	docker pull $(FROM_IMAGE)

build:
	docker build --rm -t lazyfrosch/icingaweb2 .
