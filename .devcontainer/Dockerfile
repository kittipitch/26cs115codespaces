FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install system dependencies + gh CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libffi-dev libffi8 libgmp-dev libgmp10 \
    libncurses-dev pkg-config git \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GHCup non-interactively (installs to /root/.ghcup by default)
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
    BOOTSTRAP_HASKELL_INSTALL_STACK=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Install HUnit and Ormolu using sourced env
RUN bash -c 'source /root/.ghcup/env && cabal update && cabal install --lib HUnit && cabal install ormolu'

# Symlink binaries to /usr/local/bin so all users (vscode) can access them
RUN bash -c 'source /root/.ghcup/env && \
    for bin in ghc runghc ghci cabal stack ghcup ormolu; do \
        ln -sf "$(which $bin)" /usr/local/bin/$bin 2>/dev/null || true; \
    done'

# Allow vscode user to read ghcup/cabal package databases
RUN chmod a+rx /root && chmod -R a+rX /root/.ghcup /root/.cabal
