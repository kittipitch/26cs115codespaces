#!/bin/bash
# Run this once to save your workspace to your own GitHub repo.
set -e

# Login with full repo permissions (opens browser once)
unset GITHUB_TOKEN
echo "unset GITHUB_TOKEN" >> ~/.bashrc
gh auth login -h github.com -w --git-protocol ssh

# Pre-accept GitHub SSH fingerprint so students aren't prompted
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

USERNAME=$(gh api user -q .login)
REPO_NAME="26cs115haskell"
REMOTE_URL="git@github.com:${USERNAME}/${REPO_NAME}.git"

# Init git
cd /workspaces/26cs115codespaces
rm -rf .git
git init
git checkout -b main

# Fallback identity if GitHub profile is incomplete
NAME=$(gh api user -q .name)
if [ -z "$NAME" ] || [ "$NAME" == "null" ]; then
  NAME="$USERNAME"
fi

git config user.name "$NAME"
git config user.email "${USERNAME}@users.noreply.github.com"
git add .
git commit -m "Initial workspace"

# Create repo if it doesn't exist, otherwise just connect to it
if gh repo create "$REPO_NAME" --private --source=. --remote=origin --push 2>/dev/null; then
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
else
  echo "Repo already exists — restoring your work from GitHub..."
  git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"

  if git fetch origin main 2>/dev/null && git rev-parse --verify -q origin/main >/dev/null; then
    # Your work on GitHub wins. Keep a copy of the fresh template first, so new
    # files from it (new weeks) and its updated .devcontainer scripts survive.
    TPL=$(mktemp -d)
    tar --exclude=.git -cf - . | tar -xf - -C "$TPL"
    git reset -q --hard origin/main
    cp -an "$TPL"/. .                         # add template files you don't have yet
    cp -a "$TPL"/.devcontainer/. .devcontainer/  # always use the latest workspace scripts
    rm -rf "$TPL"
    git add -A
    git diff --cached --quiet || git commit -q -m "Update workspace from template"
  fi

  git push -u origin main
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
fi
