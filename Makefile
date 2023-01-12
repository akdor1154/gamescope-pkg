.ONESHELL:
.SHELL := bash
.SHELLFLAGS := -exc

include gamescope.mk

export VERSION := $(GAMESCOPE_VERSION)-$(DEB_RELEASE)

export EMAIL=akdor1154@noreply.users.github.com

.PHONY: changelog
changelog:
	(
		cd ubuntu_22.04/03-package
		dch -v $${VERSION:?} -c changelog
	)
	
.PHONY: release
release:
	(
		cd ubuntu_22.04/03-package
		dch -c changelog --distribution jammy --release
	)
	git add -p
	git commit -m "v$${VERSION:?}"
	git tag -a "v$${VERSION:?}" -m "v$${VERSION:?}"

.PHONY: github_release
github_release:
	git name-rev --name-only --tags --refs v$${VERSION:?} --no-undefined HEAD || exit 1
	dpkg-parsechangelog -l ubuntu_22.04/03-package/changelog > gh_changelog
	gh release create "v$${VERSION:?}" \
		--title "v$${VERSION:?}" \
		--notes-file gh_changelog \
		--draft \
		ubuntu_22.04/03-package/gamescope_$${VERSION:?}_amd64.deb
