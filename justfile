# https://just.systems

Commands:
  @just --list

version:
    nvim -V1 -v

delete-installed: version
  #!/usr/bin/env bash
  set -euo pipefail
  read -p 'Are you sure you want to delete that? [yN]: '
  case "${REPLY:-N}" in
    y|Y)  echo "Continuing with delete" ;;
    *)    echo "Cancelled at user request" ; exit 3 ;;
  esac

  sudo bash -c "rm -rf /usr/local/{bin,lib,share}/nvim"

_check-release:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! test -f dist/nvim-rel.tgz ; then
    echo "release tarball not found, aborting"
    exit 3
  fi

install-release: _check-release delete-installed
  sudo tar xzf dist/nvim-rel.tgz -C /

_check-debug:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! test -f dist/nvim-dbg.tgz ; then
    echo "debug tarball not found, aborting"
    exit 3
  fi

install-debug: _check-debug delete-installed
  sudo tar xzf dist/nvim-dbg.tgz -C /
