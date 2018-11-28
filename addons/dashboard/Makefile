SHELL=/bin/bash
URL=https://raw.githubusercontent.com/humstarman/ikube-scripts/master
MANIFEST=./manifests

all: deploy
install: all

deploy: export OP=create
deploy:
	@kubectl ${OP} -f ${MANIFEST}/dashboard-rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-secret.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-service.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-controller.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-ingress.yaml

clean: export OP=delete
clean:
	@kubectl ${OP} -f ${MANIFEST}/dashboard-rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-configmap.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-secret.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-service.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-controller.yaml
	@kubectl ${OP} -f ${MANIFEST}/dashboard-ingress.yaml
