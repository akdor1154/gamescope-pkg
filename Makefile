.ONESHELL:
default: build_in_container


.PHONY: build_in_container
build_in_container: image
	set -ex

	podman create \
		--name wlbuild \
		--volume .:/build \
		--workdir /build \
		wlbuildimg \
		make -f Makefile.inside
	trap "podman rm wlbuild" EXIT

	podman start --attach wlbuild


.PHONY: image
	podman build --tag wlbuildimg .