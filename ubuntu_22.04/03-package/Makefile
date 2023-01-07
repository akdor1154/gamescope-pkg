.ONESHELL:
.SHELL = bash
.SHELLFLAGS = -exc

PACKAGE_NAME=gamescope_3.11.51-1

.PHONY: default
default: package

.PHONY: package
package: | $(PACKAGE_NAME).deb

.PHONY: ./$(PACKAGE_NAME)
./$(PACKAGE_NAME):
	rm -rf pkg_tmp $(PACKAGE_NAME)

	umask 0022

	mkdir -p pkg_tmp
	cp -rP ../02-gamescope/package/. pkg_tmp
	cp -r ./debian pkg_tmp/DEBIAN

	# drop dodgy symlinks from the -dev packages
	(
		cd pkg_tmp/opt/gamescope/lib/x86_64-linux-gnu
		rm libwayland-client.so libwayland-egl.so libdrm_nouveau.so libwayland-cursor.so
	)
	# fix dodgy symlinks from hwinfo
	(
		cd pkg_tmp/opt/gamescope/share
		mkdir -p misc
		cd misc
		ln -s /usr/share/misc/usb.ids usb.ids
		ln -s /usr/share/misc/pci.ids pci.ids
	)

	# fix perms
	chmod ugo-x pkg_tmp/opt/gamescope/lib/x86_64-linux-gnu/*.so

	mkdir -p pkg_tmp/usr/share/lintian/overrides
	cp ./lintian-overrides pkg_tmp/usr/share/lintian/overrides/gamescope

	mkdir -p pkg_tmp/usr/share/doc/gamescope
	cp pkg_tmp/opt/gamescope/doc/LICENSE pkg_tmp/usr/share/doc/gamescope/copyright
	cat changelog | gzip -9 > pkg_tmp/usr/share/doc/gamescope/changelog.Debian.gz

	# add to /usr/bin
	mkdir -p pkg_tmp/usr/bin
	ln -s /opt/gamescope/bin/gamescope pkg_tmp/usr/bin/gamescope

	# build manual
	mkdir -p pkg_tmp/usr/share/man/man1
	(
		echo "% GAMESCOPE(1) 3.11.51-1 | Autogenned from gamescope readme"
		cat man_header.md
		cat pkg_tmp/opt/gamescope/doc/README.md
	) | pandoc --standalone --to man -o pkg_tmp/usr/share/man/man1/gamescope.1
	
	mv pkg_tmp $(PACKAGE_NAME)

$(PACKAGE_NAME).deb: ./$(PACKAGE_NAME)
	dpkg-deb -z5 --root-owner-group --build $(PACKAGE_NAME)

.PHONY: lint
lint: $(PACKAGE_NAME).deb
	lintian $(PACKAGE_NAME).deb

.PHONY: compute-deps
compute-deps:
	# this outputs computed dependencies, which you can MANUALLY update+commit into
	# debian/control.
	dpkg-shlibdeps pkg_tmp/opt/gamescope/bin/gamescope.real \
		-O \
		-lpkg_tmp/opt/gamescope/lib/x86_64-linux-gnu \
		-xlibwayland-server0

.PHONY: test-install
test-install: test-image
	podman create \
		--name gamescopetest \
		--volume .:/pkg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt \
		gamescopetestimg \
		/pkg/testinstall.sh
	trap "podman rm gamescopetest" EXIT

	podman start --attach gamescopetest

.PHONY: test-image
test-image:
	mkdir -p ../.cache/image-apt-cache
	podman build \
		--tag gamescopetestimg \
		--volume $$(pwd)/../.cache/image-apt-cache:/var/cache/apt \
		-f test.Containerfile .