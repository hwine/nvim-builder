ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim AS builder
ARG BRANCH=stable

# do as root - install all tooling

RUN apt-get update
RUN apt-get install -y git make cmake
RUN git clone https://github.com/neovim/neovim
WORKDIR /neovim

FROM builder AS release
RUN git checkout ${BRANCH} && make CMAKE_BUILD_TYPE=Release
#RUN make test

# install, then tar up
RUN make install

# by inspection, that installs ~2106 files under /usr/local as follows:
#   bin/nvim
#   share/nvim/
#   lib/nvim/
# N.B. if you change the above, change the Uninstall commands below.
RUN mkdir dist ; tar czf dist/nvim-rel.tgz /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/
#
# Extract the binaries with:
#   docker run -it --rm --user "$(id -u):$(id -g)" -v $PWD/dist:/output neovim-release cp -f /neovim/dist/nvim-rel.tgz /output/

FROM builder AS debug

RUN git checkout ${BRANCH} && make CMAKE_BUILD_TYPE=RelWithDebInfo

RUN mkdir dist ; make install && tar czf dist/nvim-dbg.tgz /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/

#
# Extract the binaries with:
#   docker run -it --rm --user "$(id -u):$(id -g)" -v $PWD/dist:/output neovim-debug cp -f /neovim/dist/nvim-dbg.tgz /output/

# vim: ts=4 sw=4 sts=4 et ai :
