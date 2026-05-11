#!/bin/bash
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
    
    # Check for uncommitted changes specifically in the course directory
    if [[ -n $(git status --porcelain "$COURSE_DIR") ]]; then
        # Check if any file in the course directory was modified recently
        RECENT_CHANGES=$(find "$COURSE_DIR" -type f -not -path '*/.*' -mmin -$IDLE_THRESHOLD)
        
        if [[ -z "$RECENT_CHANGES" ]]; then
            echo "Inactivity detected in $COURSE_DIR. Performing auto-sync..."
            git add "$COURSE_DIR"
            git commit -m "Auto-sync (idle) $(date +'%Y-%m-%d %H:%M')"
            git push origin main || echo "Auto-sync push failed. Will retry later."
        fi
    fi
done
