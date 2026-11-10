#!/usr/bin/env bash
# Background script to auto-commit and push when idle.

# CONFIGURATION
CHECK_INTERVAL=600   # Check every 10 minutes
IDLE_THRESHOLD=30    # Must be idle for 30 minutes
COURSE_DIR="homework"

# Find the workspace root (first dir in /workspaces)
WS_ROOT=$(ls -d /workspaces/*/ | head -n 1 | sed 's/\/$//')

if [ -z "$WS_ROOT" ]; then
    echo "Could not find workspace root in /workspaces"
    exit 1
fi

echo "Autosync started for $WS_ROOT/$COURSE_DIR"

while true; do
    sleep $CHECK_INTERVAL

    if [ ! -d "$WS_ROOT/.git" ]; then continue; fi

    cd "$WS_ROOT"

    # Commit idle changes in the course directory
    if [[ -n $(git status --porcelain "$COURSE_DIR") ]]; then
        # Check if any file in the course directory was modified recently
        RECENT_CHANGES=$(find "$COURSE_DIR" -type f -not -path '*/.*' -mmin -$IDLE_THRESHOLD)

        if [[ -z "$RECENT_CHANGES" ]]; then
            echo "Inactivity detected in $COURSE_DIR. Committing..."
            git add "$COURSE_DIR"
            git commit -m "Auto-sync (idle) $(date +'%Y-%m-%d %H:%M')"
        fi
    fi

    # Push every commit GitHub does not have yet, including ones left over from a
    # failed push. First replay them on top of GitHub's main, in case the student
    # pushed from another machine; a rejected push would otherwise repeat forever.
    git fetch -q origin main 2>/dev/null || { echo "Auto-sync: cannot reach GitHub. Will retry later."; continue; }
    if [[ $(git rev-list --count origin/main..HEAD 2>/dev/null) -gt 0 ]]; then
        if ! git rebase -q --autostash origin/main; then
            git rebase --abort 2>/dev/null
            echo "Auto-sync: your changes conflict with GitHub. Your commits are kept locally."
            echo "           Run: git pull --rebase origin main   (fix the conflict), then git push"
            continue
        fi
        git push -q origin main && echo "Auto-sync: pushed $(date +'%Y-%m-%d %H:%M')" \
            || echo "Auto-sync push failed. Will retry later."
    fi
done
