REGISTRY=ghcr.io
IMAGE=diztortion/radicale
REGISTRY_IMAGE=${REGISTRY}/${IMAGE}

.PHONY: all build push clean clean_all

all: build push clean

build: check-env
	@echo Building ${REGISTRY_IMAGE}:${TAG}
	@docker build --label "org.opencontainers.image.created=$(shell date --rfc-3339=seconds)" --label "org.opencontainers.image.version=$(TAG)" --build-arg TAG=${TAG} --tag ${REGISTRY_IMAGE}:${TAG} --pull .
	@docker images --filter label=name=drone-oss --filter label=stage=builder --quiet | xargs --no-run-if-empty docker rmi

push: check-env
	@echo Pushing ${REGISTRY_IMAGE}:${TAG}
	@docker push ${REGISTRY_IMAGE}:${TAG}

clean: check-env
	@docker rmi ${REGISTRY_IMAGE}:${TAG}

clean_all:
	@docker images --filter "reference=${REGISTRY_IMAGE}" --quiet | xargs --no-run-if-empty docker rmi
	@docker images --filter label=name=drone-oss --filter label=stage=builder --quiet | xargs --no-run-if-empty docker rmi

check-env:
ifndef TAG
        TAG := $(shell curl -sL https://api.github.com/repos/kozea/radicale/releases?per_page=1 | grep -oP '"tag_name": "\K(.*)(?=")')
        $(info TAG is undefined. Using latest release: $(TAG))
endif
