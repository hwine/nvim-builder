ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim AS base

# do as root - install all tooling

RUN apt update
RUN apt-get install -y git make cmake
RUN git clone https://github.com/neovim/neovim
RUN cd neovim && make

WORKDIR /neovim

# install, then tar up
RUN make install

# by inspection, that installs ~2106 files under /usr/local as follows:
#   bin/nvim
#   share/nvim/
#   lib/nvim/
RUN tar czf build/nvim.tgz /usr/local/bin/nvim /usr/local/share/nvim/ /usr/local/lib/nvim/
# COPY /build/bin/* ./bin/
#
# Extract the binaries with:
#   docker run -it --rm -v $PWD/bin:/output cp -f /neovim/build/bin/nvim.tgz /output/



# vim: ts=4 sw=4 sts=4 et ai :
