.ONESHELL:
.SHELL = bash
.SHELLFLAGS = -exc

include ../../gamescope.mk

export GAMESCOPE_VERSION
export DEB_RELEASE
export DEB_RELEASE_SUFFIX := $(shell \
	git name-rev --name-only --tags --refs v$(GAMESCOPE_VERSION)-$(DEB_RELEASE) --no-undefined HEAD 1>&2 \
	&& echo "" \
	|| echo "~git~$$(git show -s --format=%ct HEAD)~$$(git rev-parse --short HEAD)" \
)

export PACKAGE_VERSION=$(GAMESCOPE_VERSION)-$(DEB_RELEASE)$(DEB_RELEASE_SUFFIX)
export PACKAGE_NAME=gamescope_$(PACKAGE_VERSION)_amd64

.PHONY: default
default: package

.PHONY: package
package: | $(PACKAGE_NAME).deb

.PHONY: ./$(PACKAGE_NAME)
./$(PACKAGE_NAME):
	# cause an error if these are missing
	echo $${GAMESCOPE_VERSION:?} $${DEB_RELEASE:?}$${DEB_RELEASE_SUFFIX} $${PACKAGE_VERSION:?}

	rm -rf pkg_tmp $${PACKAGE_NAME:?}

	umask 0022

	mkdir -p pkg_tmp
	cp -rP ../02-gamescope/package/. pkg_tmp
	cp -r ./debian pkg_tmp/DEBIAN
	rm pkg_tmp/DEBIAN/substvars
	dpkg-gencontrol -cdebian/control -lchangelog -O -v$${PACKAGE_VERSION:?} > pkg_tmp/DEBIAN/control

	# drop dodgy symlinks from the -dev packages
	(
		cd pkg_tmp/opt/gamescope/lib/x86_64-linux-gnu
		rm libwayland-client.so libwayland-egl.so libwayland-cursor.so
	)

	# fix perms
	chmod ugo-x pkg_tmp/opt/gamescope/lib/x86_64-linux-gnu/*.so

	# patch rpath so we load bundled libs instead of system ones
	(
		cd pkg_tmp/opt/gamescope/bin
		patchelf --set-rpath '$$ORIGIN/../lib/x86_64-linux-gnu' --force-rpath \
			gamescope \
			gamescopereaper \
			gamescopestream \
			gamescopectl
	)

	mkdir -p pkg_tmp/usr/share/lintian/overrides
	cp ./lintian-overrides pkg_tmp/usr/share/lintian/overrides/gamescope

	mkdir -p pkg_tmp/usr/share/doc/gamescope
	cp pkg_tmp/opt/gamescope/doc/LICENSE pkg_tmp/usr/share/doc/gamescope/copyright
	cat changelog | gzip -9 > pkg_tmp/usr/share/doc/gamescope/changelog.Debian.gz

	# add to /usr/bin
	mkdir -p pkg_tmp/usr/bin
	ln -s -t pkg_tmp/usr/bin \
		/opt/gamescope/bin/gamescope \
		/opt/gamescope/bin/gamescopereaper \
		/opt/gamescope/bin/gamescopestream \
		/opt/gamescope/bin/gamescopectl

	# build manual
	mkdir -p pkg_tmp/usr/share/man/man1
	(
		echo "% GAMESCOPE(1) $${PACKAGE_VERSION:?} | Autogenned from gamescope readme"
		cat man_header.md
		cat pkg_tmp/opt/gamescope/doc/README.md
	) | pandoc --standalone --to man \
	| gzip -9 \
	>  pkg_tmp/usr/share/man/man1/gamescope.1.gz

	(
		cd pkg_tmp/usr/share/man/man1
		cp gamescope.1.gz gamescopectl.1.gz
		cp gamescope.1.gz gamescopereaper.1.gz
		cp gamescope.1.gz gamescopestream.1.gz
	)


	mv pkg_tmp $(PACKAGE_NAME)

$(PACKAGE_NAME).deb: ./$(PACKAGE_NAME)
	dpkg-deb -z5 --root-owner-group --build $${PACKAGE_NAME:?}

.PHONY: lint
lint: $(PACKAGE_NAME).deb
	lintian $${PACKAGE_NAME:?}.deb

.PHONY: compute-deps
compute-deps:
	# this outputs computed dependencies, which you can MANUALLY commit into
	# debian/substvars.
	dpkg-shlibdeps \
		-e ./$${PACKAGE_NAME:?}/opt/gamescope/bin/gamescope \
		-v \
		-l./$${PACKAGE_NAME:?}/opt/gamescope/lib/x86_64-linux-gnu \
		-xlibwayland-server0 \
		-xlibwayland-client0 \
		-xlibwayland-egl0 \
		-xlibwayland-egl1 \
		-xlibwayland-cursor0

.PHONY: test-install
test-install: test-image
	podman create \
		--name gamescopetest \
		--volume .:/pkg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt:U \
		--cap-add=CAP_SETFCAP,CAP_SYS_NICE \
		gamescopetestimg \
		/pkg/testinstall.sh
	trap "podman rm gamescopetest" EXIT

	podman start --attach gamescopetest

.PHONY: test-image
test-image:
	mkdir -p ../.cache/image-apt-cache
	podman build \
		--tag gamescopetestimg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt:U \
		-f test.Containerfile .
