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

clean: export OP=delete 
clean: export MANIFEST=./manifests
clean:
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/default-backend.yaml
	@kubectl ${OP} -f ${MANIFEST}/configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/tcp-services-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/udp-services-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/with-rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/namespace.yaml

test: export OP=create
test: export MANIFEST=./manifests
test:
	-@kubectl ${OP} -f ${MANIFEST}/namespace.yaml

