VERSION ?= 5.14.3.1
REGISTRY ?= docker.seibert-media.net

default: build

all: build upload clean

clean: checkvars
	docker rmi $(REGISTRY)/seibertmedia/atlassian-bamboo:$(VERSION)

build: checkvars
	docker build --no-cache --rm=true --build-arg VERSION=$(VERSION) -t $(REGISTRY)/seibertmedia/atlassian-bamboo:$(VERSION) .

upload: checkvars
	docker push $(REGISTRY)/seibertmedia/atlassian-bamboo:$(VERSION)

checkvars:
ifndef VERSION
	$(error env variable VERSION has to be set)
endif