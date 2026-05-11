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
git config user.name "$(gh api user -q .name)"
git config user.email "${USERNAME}@users.noreply.github.com"
git add .
git commit -m "Initial workspace" 2>/dev/null || true

# Create repo if it doesn't exist, otherwise just connect to it
if gh repo create "$REPO_NAME" --private --source=. --remote=origin --push 2>/dev/null; then
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
else
  echo "Repo already exists — connecting to it..."
  git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
  
  # Pull existing work if any
  echo "Syncing with GitHub..."
  git fetch origin main 2>/dev/null || true
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git pull origin main --rebase --allow-unrelated-histories
  fi
  
  git push -u origin main
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
fi
