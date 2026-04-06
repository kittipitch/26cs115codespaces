FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install system dependencies + gh CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libffi-dev libffi8 libgmp-dev libgmp10 \
    libncurses-dev pkg-config git \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
    BOOTSTRAP_HASKELL_INSTALL_STACK=1 \
    GHCUP_USE_XDG_DIRS=0 \
    GHCUP_INSTALL_BASE_PREFIX=/opt \
    CABAL_DIR=/opt/.cabal

# Install GHCup + GHC + cabal + HUnit + Ormolu in one shell so PATH is active
SHELL ["/bin/bash", "-c"]
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh \
    && source /opt/.ghcup/env \
    && cabal update \
    && cabal install --lib HUnit \
    && cabal install ormolu

# Make tools available to all users
RUN echo 'source /opt/.ghcup/env' >> /etc/bash.bashrc \
    && echo 'export GHC_ENVIRONMENT=/opt/.cabal/environments/default' >> /etc/bash.bashrc
