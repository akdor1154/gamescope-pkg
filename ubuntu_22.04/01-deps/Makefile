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
	
.PHONY: image
image:
	mkdir -p ../.cache/image-apt-cache
	podman build \
		--tag gamescopedepsimg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt \
		-f deps.Containerfile .

clean:
	rm -r ./build
	rm -r ./packages