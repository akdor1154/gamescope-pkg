# Gamescope packages for Ubuntu 22.04

This repo contains unofficial [Gamescope](https://github.com/Plagman/gamescope) packages for Ubuntu/Pop!_OS 22.04. Currently they are published as .deb files in Github releases, though I would like to make a proper deban archive in future.

I should do a reasonable job of keeping them up to date with Gamescope releases, as there's a bot which should raise a PR when a new release needs packaging.

## Support

These are unsupported by me, but they are even more unsupported by the Gamescope team who have nothing to do with them. Please don't raise issues on the Gamescope issue tracker without reproducing against Gamescope master. Feel free to raise issues / discussions in this repo though.

## Licence

These build scripts are GPL licenced. Gamescope itself is MIT. (Gamescope guys, if you'd like this MIT I'll happily relicence). If you PR to this repo, please give a comment that you assign me the right to relicence your code under any GPL-compatible OSI-approved licence, to allow me to switch to MIT if needed.

## Maybe TODO

 - [ ] debian archive (in gh pages? ubuntu ppa?)
 - [ ] more OSes than just Ubuntu 22.04? (though the packages as-is should work on 22.10 and newish Debian as well)
 - [ ] gpg signing
 - [ ] master / nightly builds
 - [ ] bot to update vendored deps as well as gamescope itself

## Technical notes

### Dependencies

A lot of gamescope's dependencies are newer than what's available in Ubuntu 22.04. To address this, I'm pulling new versions from other dists (Debian Sid and Ubuntu 22.10), compiling them, and "vendoring" the compiled versions as part of the gamescope package. This is done in a way that won't interfere with anything else on your system: they're all in `/opt/gamescope/lib/...`, and `gamescope` dynamically links against them in an isolated way that shouldn't affect subprocesses (your games). See [ubuntu_22.04/02-gamescope/gamescope-wrapper.sh](ubuntu_22.04/02-gamescope/gamescope-wrapper.sh) for details.

### Build scripts

The package build scripts here are almost aggressively not DRY, because generalized packaging scripts are unreadable to me. This is also a nearly pedagogical exercize in figuring out how to build a binary debian package from scratch. This may have to change if I support more dists etc in future, but for now at least you can read what's going on...