SHELL=/bin/bash

all: deploy
install: all

deploy: export MANIFEST=./manifests
deploy:
	@kubectl create -f namespace.yaml
	@kubectl create -f rbac.yaml
	@sleep 1
	@kubectl create -f default-backend.yaml
	@kubectl create -f configmap.yaml
	@kubectl create -f tcp-services-configmap.yaml
	@kubectl create -f udp-services-configmap.yaml
	@sleep 1
	@kubectl create -f service.yaml
	@kubectl create -f with-rbac.yaml
