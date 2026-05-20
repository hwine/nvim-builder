# https://just.systems

_Commands:
  @just --list --unsorted

# Display installed nvim version
nvim-version:
    nvim -V1 -v

# Build release
build-release:
  docker compose build release
  @ mkdir -p dist
  docker run -it --rm --user "$(id -u):$(id -g)" -v $PWD/dist:/output neovim-release \
      cp -f /neovim/dist/nvim-rel.tgz /output/
  @rm -rf dist/usr
  @tar xzf dist/nvim-rel.tgz -C dist/
  dist/usr/local/bin/nvim -V1 -v
  @rm -rf dist/usr

# Build debug
build-debug:
  docker compose build debug
  @ mkdir -p dist
  docker run -it --rm --user "$(id -u):$(id -g)" -v $PWD/dist:/output neovim-debug \
      cp -f /neovim/dist/nvim-dbg.tgz /output/
  @rm -rf dist/usr
  @tar xzf dist/nvim-dbg.tgz -C dist/
  dist/usr/local/bin/nvim -V1 -v
  @rm -rf dist/usr

# Remove the current nvim
_delete-installed: nvim-version
  #!/usr/bin/env bash
  set -euo pipefail
  read -p 'Are you sure you want to delete that? [yN]: '
  case "${REPLY:-N}" in
    y|Y)  echo "Continuing with delete" ;;
    *)    echo "Cancelled at user request" ; exit 3 ;;
  esac

  sudo bash -c "rm -rf /usr/local/{bin,lib,share}/nvim"

# Verify that a release tarball is where we expect it
_check-release:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! test -f dist/nvim-rel.tgz ; then
    echo "release tarball not found, aborting"
    exit 3
  fi

# Install the release build of nvim
install-release: _check-release _delete-installed
  sudo tar xzf dist/nvim-rel.tgz -C /

_check-debug:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! test -f dist/nvim-dbg.tgz ; then
    echo "debug tarball not found, aborting"
    exit 3
  fi

# Install the debug build of nvim
install-debug: _check-debug _delete-installed
  sudo tar xzf dist/nvim-dbg.tgz -C /

# Remove the build images
docker-cleanup:
  docker image remove $(docker images --quiet neovim\*)
  docker image prune
