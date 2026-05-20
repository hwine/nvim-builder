ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim AS builder
ARG BRANCH=release-0.12

# do as root - install all tooling

WORKDIR /neovim
RUN apt-get update ; apt-get install -y git make cmake ; git clone https://github.com/neovim/neovim

# We need to override the mason installed tree-sitter, as it requires glibc 2.39, which bookworm does not have
FROM builder AS tree-sitter-prep
RUN \
    apt install -y wget gcc-12 libclang1 libgcc-12-dev libstdc++-12-dev ; \
    wget -O rustup.sh https://sh.rustup.rs ; \
    bash rustup.sh -y ; echo "EC=$?" &>2 ; \
    . ~/.cargo/env ; \
    export CPATH=/usr/lib/gcc/aarch64-linux-gnu/12/include ; \
    cargo install tree-sitter-cli ; \
    :

FROM tree-sitter-prep AS tree-sitter
RUN \
    ls -lR ~/.cargo/ ; \
    cp ~/.cargo/bin/tree-sitter /bin
#
# Extract the binaries with:
#   docker run -it --rm --user "$(id -u):$(id -g)" -v $PWD/dist:/output neovim-treesitter cp -f /bin/tree-sitter /output/

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
