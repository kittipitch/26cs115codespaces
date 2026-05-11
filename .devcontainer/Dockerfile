FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# System dependencies + gh CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl xz-utils libffi-dev libgmp-dev libgmp10 \
    libncurses-dev pkg-config git \
    python3 python3-pip python3-venv \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && pip3 install --no-cache-dir mypy --break-system-packages

# Part 1: Install GHC 9.6.7 globally
RUN cd /tmp \
    && curl -L -O https://downloads.haskell.org/~ghc/9.6.7/ghc-9.6.7-x86_64-ubuntu22_04-linux.tar.xz \
    && tar xf ghc-*.tar.xz \
    && cd ghc-9.6.7*/ \
    && ./configure \
    && make install \
    && ln -sf /usr/local/bin/ghc /usr/bin/ghc \
    && cd / && rm -rf /tmp/ghc*

# Part 2: Install GHCup binary globally
RUN curl -L -o /usr/local/bin/ghcup \
    https://downloads.haskell.org/~ghcup/0.1.50.2/x86_64-linux-ghcup-0.1.50.2 \
    && chmod +x /usr/local/bin/ghcup

# Part 3: Install Cabal globally via GHCup
ENV GHCUP_INSTALL_BASE_PREFIX=/usr/local
RUN ghcup install cabal 3.10.3.0 \
    && ghcup set cabal 3.10.3.0 \
    && ln -sf /usr/local/.ghcup/bin/cabal /usr/local/bin/cabal

# Part 4: Install HUnit into global package database
RUN cabal update \
    && cabal --store-dir=/usr/local/lib/ghc-9.6.7/cabal-store install --lib HUnit call-stack \
        --package-db=/usr/local/lib/ghc-9.6.7/lib/package.conf.d \
        --package-env=/usr/local/lib/ghc-9.6.7/lib/ghc.env \
        --global --overwrite-policy=always

# Part 5: Install Ormolu
RUN cabal install ormolu \
    && ln -sf /root/.cabal/bin/ormolu /usr/local/bin/ormolu

# Part 6: Install HLS (Haskell Language Server) globally via GHCup
RUN ghcup install hls latest \
    && ghcup set hls latest \
    && for f in /usr/local/.ghcup/bin/haskell-language-server*; do \
         ln -sf "$f" /usr/local/bin/$(basename "$f"); \
       done
