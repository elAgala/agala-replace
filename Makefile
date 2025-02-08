DOCKER_REGISTRY = ghcr.io
DOCKER_REPO = elagala/agala-replace
DOCKER_TAG = latest
DOCKER_IMAGE = $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)

build:
	@echo "Building Docker image: $(DOCKER_IMAGE)"
	docker build -t $(DOCKER_IMAGE) .

run-local:
	@echo "Building Docker image: $(DOCKER_IMAGE)"
	docker build -t agala-replace:local .
	op inject --in-file .env --out-file .env.resolved -f && \
	docker run --rm -it \
		--env-file .env.resolved \
		-v ./dist:/app/dist \
		agala-replace:local && \
	rm .env.resolved

push:
	@echo "Pushing Docker image: $(DOCKER_IMAGE)"
	docker push $(DOCKER_IMAGE)

build-and-push: build push

clean:
	@echo "Removing local Docker image: $(DOCKER_IMAGE)"
	docker rmi $(DOCKER_IMAGE)

