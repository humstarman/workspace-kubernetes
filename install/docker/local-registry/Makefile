PORT=5000
DATA_ROOT=/var/lib/docker/regisrty
NAME=registry

build:
	-@mkdir -p $(DATA_ROOT)
	-@docker run -d -p $(PORT):5000 --restart=always --name $(NAME) -v $(DATA_ROOT):/var/lib/registry registry
	@docker ps -a --filter "name=$(NAME)"

test:
	@curl http://127.0.0.1:$(PORT)/v2/_catalog
