.ONESHELL:
.SHELL = bash
.SHELLFLAGS = -ec

default: ./build

./build: image
	set -ex

	rm -rf ./build

	podman create \
		--name gamescopedeps \
		--volume .:/01-deps \
		--workdir /01-deps \
		gamescopedepsimg \
		make -f Makefile.deps.inside BUILD=./build_tmp
	trap "podman rm gamescopedeps" EXIT

	podman start --attach gamescopedeps

	mv build_tmp ./build

.PHONY: shell
shell: image
	set -ex

	exec podman run -it --rm \
		--name gamescopedeps \
		--volume .:/01-deps \
		--workdir /01-deps \
		gamescopedepsimg \
		bash


	
.PHONY: image
image:
	mkdir -p ../.cache/image-apt-cache
	podman build \
		--tag gamescopedepsimg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt:U \
		-f deps.Containerfile .

clean:
	rm -rf ./build
	rm -rf ./packages
	podman image rm gamescopedepsimg || true
	podman rm gamescopedeps || true

.PHONY: check-deps
check-deps: image
	exec podman run -i --rm \
		--name gamescopedeps \
		--volume .:/01-deps \
		--workdir /01-deps \
		gamescopedepsimg \
		python3 query-deps.py > versions_new.mk
