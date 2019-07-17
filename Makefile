# import makefile envrionment
SHELL=/bin/bash
$(shell source makefile.d/config)

welcome:
	@echo "welcome to container projects"

BUILD_SOURCE_PATH=$(CURDIR)
# source code branch name
BUILD_SOURCE_BRANCH?=rel
# project version
BUILD_PROJECT_VERSION?=1
# source code revision number
BUILD_SOURCE_REVISION?=0
# jenkins job build number
BUILD_JOB_NUMBER?=0

# local dtr
DOCKER_LOCAL_DTR?=dtr.example.com

os=centos
ifdef os
    base_os=$(os)
    ifeq ($(base_os), centos)
       name_pre=
    else
       name_pre=$(base_os)-
    endif
endif

ifdef type
    build_type=$(type)
endif

ifdef name
    build_name=$(name_pre)$(name)
endif

ifdef version
    IMAGE_MAIN_VERSION=$(version)
else
    IMAGE_MAIN_VERSION=$(shell ls $(CURDIR)/$(base_os)/$(build_type)/$(name) | sort -n |tail -1)
endif

define get_sha256
	$(shell docker inspect  --format='{{.RepoDigests}}' $1 | awk -F ':|\]' '{print $$(NF-1)}')
endef

# build image version - branch.major.middle.revision.job_number
BUILD_IMAGE_VERSION=$(BUILD_SOURCE_BRANCH).$(BUILD_PROJECT_VERSION).$(BUILD_SOURCE_REVISION).$(BUILD_JOB_NUMBER)
BUILD_DOCKERFILE_PATH=$(base_os)/$(build_type)/$(name)/$(IMAGE_MAIN_VERSION)/$(BUILD_SOURCE_BRANCH).$(BUILD_PROJECT_VERSION).$(BUILD_SOURCE_REVISION)

BUILD_DOCKER_IMAGE_TAG=$(shell echo $(BUILD_IMAGE_VERSION) | tr A-Z a-z)
BUILD_DOCKER_IMAGE_NAME=$(DOCKER_LOCAL_DTR)/$(build_type)/$(build_name)$(IMAGE_MAIN_VERSION):$(BUILD_DOCKER_IMAGE_TAG)

DOCKERFILE_LINT_IMAGE?=dtr.example.com/tools/dockerfile_lint18:rel.1.0.1

CONSUL_ADDRESS?=http://consul.example.com
CONSUL_TOKEN?=$(shell cat ~/.consul/config | head -1)

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

# single function
default: build-env check-validity

check-image-name:
	@$(call check_defined, name, name is required e.g: make <target> [os=centos] [version=9.2.14] type=jetty name=node)

check-image-type:
	@$(call check_defined, type, type is required e.g: make <target> [os=centos] [version=9.2.14] type=jetty name=node)

check-build-path:
	@ls -d $(BUILD_DOCKERFILE_PATH)

check-dockerfile:
	@echo "--- Checking Dockerfile ---"
	@cd $(BUILD_SOURCE_PATH)/$(BUILD_DOCKERFILE_PATH) && \
	docker run --rm --privileged -v $(BUILD_SOURCE_PATH)/$(BUILD_DOCKERFILE_PATH):/root/ $(DOCKERFILE_LINT_IMAGE) -p

image-check:
	@echo "check image size"

docker-bench:
	@echo "--- start docker bench scanning ---"
	@docker run --net host --pid host --cap-add audit_control \
	 -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST  \
	 -v /var/lib:/var/lib   \
	 -v /var/run/docker.sock:/var/run/docker.sock  \
	 -v /usr/lib/systemd:/usr/lib/systemd  \
	 -v /etc:/etc --label docker_bench_security  \
	 dtr.example.com/base/docker-bench-security

register-image2consul: push
	@echo "--- register image name to consul ---"
	@echo "name: $(BUILD_DOCKER_IMAGE_NAME)"
	@consul kv put --http-addr=$(CONSUL_ADDRESS) -token=$(CONSUL_TOKEN) "endpoints/images/$(base_os)/$(build_type)/$(build_name)/$(IMAGE_MAIN_VERSION)/name" "$(BUILD_DOCKER_IMAGE_NAME)"

	@echo "--- register sha256 to consul ---"
	@$(eval IMAGE_SHA256:=$(call get_sha256, $(BUILD_DOCKER_IMAGE_NAME)))
	@echo "sha256: $(IMAGE_SHA256)"
	@consul kv put --http-addr=$(CONSUL_ADDRESS) -token=$(CONSUL_TOKEN) "endpoints/images/$(base_os)/$(build_type)/$(build_name)/$(IMAGE_MAIN_VERSION)/sha256" "$(IMAGE_SHA256)"

docker-version:
	@echo "--- Docker Version ---"
	docker version
	@echo ""

dockerfile-output:
	@echo "--- Dockerfile ---"
	@cd $(BUILD_SOURCE_PATH)/$(BUILD_DOCKERFILE_PATH) && \
	cat Dockerfile

docker-image-rollback:
	@echo "--- Force Remove Image ---"
	@docker rmi -f $(BUILD_DOCKER_IMAGE_NAME)
	@echo ""

docker-clean-containers: docker-version
	@echo "--- Cleanup Exited Containers ---"
	$(eval DOCKER_EXITED_CONTAINERS:=$(shell docker ps -f status=exited -q | head))
	@if [ -n "$(DOCKER_EXITED_CONTAINERS)" ]; then docker rm -f -v $(DOCKER_EXITED_CONTAINERS); fi
	@echo ""

docker-clean-images: docker-version
	@echo "--- Cleanup Dangling Images ---"
	$(eval DOCKER_DANGLING_IMAGES=$(shell docker images -q -f dangling=true | head))
	@ if [ -n "$(DOCKER_DANGLING_IMAGES)" ]; then docker rmi -f $(DOCKER_DANGLING_IMAGES); fi
	@echo ""

build-env: check-validity
	@echo "--- Build Environment ---"
	@echo "BUILD_SOURCE_PATH:     $(BUILD_SOURCE_PATH)"
	@echo "BUILD_SOURCE_BRANCH:   $(BUILD_SOURCE_BRANCH)"
	@echo "BUILD_PROJECT_VERSION: $(BUILD_PROJECT_VERSION)"
	@echo "BUILD_SOURCE_REVISION: $(BUILD_SOURCE_REVISION)"
	@echo "BUILD_JOB_NUMBER:      $(BUILD_JOB_NUMBER)"
	@echo "BUILD_IMAGE_VERSION:   $(BUILD_IMAGE_VERSION)"
	@echo "BUILD_DOCKER_IMAGE_NAME: $(BUILD_DOCKER_IMAGE_NAME)"
	@echo ""

check-validity: check-image-type check-image-name

build: build-env docker-version docker-clean dockerfile-output
	@echo "--- Building Image ---"
	@cd $(BUILD_SOURCE_PATH)/$(BUILD_DOCKERFILE_PATH) && \
	docker build --file Dockerfile --rm --tag $(BUILD_DOCKER_IMAGE_NAME) .
	@echo ""

autoscope: image-check docker-bench

docker-clean: docker-clean-containers docker-clean-images

clean: docker-clean

rollback: docker-image-rollback clean

push: check-validity clean
	@echo "--- Pushing Image ---"
	@docker login -p exampleLOCAL@2017 -u local dtr.example.com
	docker push $(BUILD_DOCKER_IMAGE_NAME)

release: build test push register-image2consul

test: autoscope

register: push register-image2consul

setup::
	@echo "--- Setup Consul ---"
	@consul --help > /dev/null 2>&1 && \
	(echo "--- Consul Already Exists ---" && \
	consul --version ) || \
	(curl -o /usr/local/bin/consul http://repo.example.com/downloads/software/consul/consul_$(SETUP_CONSUL_VERSION)_$(SETUP_OS_TYPE) && \
	chmod +x /usr/local/bin/consul && \
	echo "--- Installed Consul ---")

# Ignore include errors
-include makefile.d/*