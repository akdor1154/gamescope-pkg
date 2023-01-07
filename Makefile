.ONESHELL:

default: build_deps_in_container

.PHONY: build_deps_in_container
build_deps_in_container: BUILD=./build
build_deps_in_container: DEST_RPATH=/opt/gamescope/lib/x86_64-linux-gnu
build_deps_in_container: image_deps
	set -ex

	podman create \
		--name wlbuild \
		--volume .:/build \
		--workdir /build \
		wlbuildimg \
		make -f Makefile.deps.inside
	trap "podman rm wlbuild" EXIT

	podman start --attach wlbuild
	
.PHONY: image_deps
image_deps:
	mkdir -p .cache/image-apt-cache
	podman build \
		--tag wlbuildimg \
		--volume $$(pwd)/.cache/image-apt-cache:/var/cache/apt \
		-f deps.Containerfile .

clean:
	rm -rf .cache/image-apt-cache
	$(MAKE) -f Makefile.deps.inside clean
	$(MAKE) -f Makefile.gamescope.inside clean

image_gamescope:
	mkdir -p .cache/image-apt-cache
	podman build \
		--tag gamescopebuildimg \
		--volume $$(pwd)/.cache/image-apt-cache:/var/cache/apt \
		-f gamescope.Containerfile .

.PHONY: build_gamescope_in_container
build_gamescope_in_container: BUILD=./gamescope_build
build_gamescope_in_container: image_gamescope
build_gamescope_in_container:
	set -ex

	podman create \
		--name gamescopebuild \
		--volume .:/build \
		--workdir /build \
		gamescopebuildimg \
		make -f Makefile.gamescope.inside
	trap "podman rm gamescopebuild" EXIT

	podman start --attach gamescopebuild
