.ONESHELL:

default: build_deps_in_container

.PHONY: build_deps_in_container
build_deps_in_container: BUILD=./build
build_deps_in_container: DEST_RPATH=/opt/gamescope/lib/x86_64-linux-gnu
build_deps_in_container: image
	set -ex

	podman create \
		--name wlbuild \
		--volume .:/build \
		--workdir /build \
		wlbuildimg \
		make -f Makefile.deps.inside
	trap "podman rm wlbuild" EXIT

	podman start --attach wlbuild
	
	# patch pkgconfig prefix= into the build path...
	ABS_BUILD=$$(realpath $(BUILD))
	sed -i -e "s|prefix=/usr|prefix=$${ABS_BUILD}|" $(BUILD)/lib/x86_64-linux-gnu/pkgconfig/* $(BUILD)/share/pkgconfig/*

.PHONY: image
image:
	mkdir -p .cache/image-apt-cache
	podman build \
		--tag wlbuildimg \
		--volume $$(pwd)/.cache/image-apt-cache:/var/cache/apt \
		-f deps.Containerfile .

clean:
	rm -rf .cache/image-apt-cache
	$(MAKE) -f Makefile.deps.inside clean


gamescope:
	set -e

	cd ../gamescope
	export PKG_CONFIG_PATH=../gamescope-pkg/build/lib/x86_64-linux-gnu/pkgconfig:../gamescope-pkg/build/share/pkgconfig
	
	meson build/
	ninja -C build/