SHELL=/bin/bash

all: deploy
install: all

deploy: export MANIFEST=./manifests
deploy: export OP=create 
deploy:
	-@kubectl ${OP} -f ${MANIFEST}/namespace.yaml
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml
	@sleep 1
	@kubectl ${OP} -f ${MANIFEST}/default-backend.yaml
	@kubectl ${OP} -f ${MANIFEST}/configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/tcp-services-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/udp-services-configmap.yaml
	@sleep 1
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/with-rbac.yaml

deploy: export OP=delete 
clean:
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/default-backend.yaml
	@kubectl ${OP} -f ${MANIFEST}/configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/tcp-services-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/udp-services-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/with-rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/namespace.yaml
