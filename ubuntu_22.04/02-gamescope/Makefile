.ONESHELL:
.SHELL = bash
.SHELLFLAGS = -ec

default: package

image:
	mkdir -p ../.cache/image-apt-cache
	podman build \
		--tag gamescopebuildimg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt \
		-f gamescope.Containerfile .

.PHONY: package
package: | ./package
./package: BUILD=./gamescope-build
./package: image
./package:
	set -x

	rm -rf ./package

	podman create \
		--name gamescopebuild \
		--volume ..:/build \
		--volume ../../gamescope:/gamescope \
		--workdir /build/02-gamescope \
		gamescopebuildimg \
		make -f Makefile.gamescope.inside \
			PACKAGEPREFIX=./package_tmp

	trap "podman rm gamescopebuild" EXIT

	podman start --attach gamescopebuild

	mv ./package_tmp ./package

clean:
	rm -rf ./deps-prefix
	rm -rf ./gamescope-prefix
	rm -rf ./gamescope-build
	rm -rf ./package
