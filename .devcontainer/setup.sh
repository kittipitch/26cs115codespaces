#!/bin/bash
# Run this once to save your CS115 workspace to your own GitHub repo.
set -e

# Login with full repo permissions (opens browser once)
unset GITHUB_TOKEN
echo "unset GITHUB_TOKEN" >> ~/.bashrc
gh auth login -h github.com -w --git-protocol ssh

# Pre-accept GitHub SSH fingerprint so students aren't prompted
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

USERNAME=$(gh api user -q .login)
REPO_NAME="26cs115repo"
REMOTE_URL="git@github.com:${USERNAME}/${REPO_NAME}.git"

# Init git
cd /workspaces/26cs115codespaces
if [ -d ".git" ]; then
  rm -rf .git
fi
git init
git config user.name "$(gh api user -q .name)"
git config user.email "${USERNAME}@users.noreply.github.com"
git add .
git commit -m "Initial CS115 workspace" 2>/dev/null || true

# Create repo if new, otherwise connect to existing
if gh repo create "$REPO_NAME" --private --source=. --remote=origin --push 2>/dev/null; then
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
else
  echo "Repo already exists — connecting to it..."
  git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
  git push -u origin main --force
  echo ""
  echo "✅ Done! Your work is saved at: https://github.com/${USERNAME}/${REPO_NAME}"
fi
