SHELL=/bin/bash
URL=https://raw.githubusercontent.com/humstarman/ikube-scripts/master
MANIFEST=./manifests

all: check_install deploy
install: all

check_install: export SCRIPT=${URL}/check-k8s-cluster.sh
check_install:
	@curl ${SCRIPT} | /bin/bash

deploy:
	@kubectl create -f ${MANIFEST}/dashboard-rbac.yaml
	@kubectl create -f ${MANIFEST}/dashboard-configmap.yaml
	@kubectl create -f ${MANIFEST}/dashboard-secret.yaml
	@kubectl create -f ${MANIFEST}/dashboard-service.yaml
	@kubectl create -f ${MANIFEST}/dashboard-controller.yaml
