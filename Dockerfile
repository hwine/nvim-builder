ARG DEBIAN_VERSION=bookworm
ARG BRANCH=stable
FROM debian:${DEBIAN_VERSION}-slim AS debug

# do as root - install all tooling

RUN apt update
RUN apt-get install -y git make cmake
RUN git clone https://github.com/neovim/neovim
WORKDIR /neovim
RUN git checkout ${BRANCH} && make
#RUN make test

# install, then tar up
RUN make install

# by inspection, that installs ~2106 files under /usr/local as follows:
#   bin/nvim
#   share/nvim/
#   lib/nvim/
# N.B. if you change the above, change the Uninstall commands below.
RUN mkdir dist ; tar czf dist/nvim-dbg.tgz /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/
#
# Extract the binaries with:
#   docker run -it --rm -v $PWD/dist:/output cp -f /neovim/dist/nvim-dbg.tgz /output/

FROM debug AS release

WORKDIR /neovim

RUN make distclean && git checkout ${BRANCH} && make CMAKE_BUILD_TYPE=RelWithDebInfo
#RUN make test

# Uninstall any previous build
RUN rm -rf /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/
RUN make install
RUN tar czf dist/nvim-rel.tgz /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/

#
# Extract the binaries with:
#   docker run -it --rm -v $PWD/dist:/output cp -f /neovim/dist/nvim-rel.tgz /output/

# vim: ts=4 sw=4 sts=4 et ai :
