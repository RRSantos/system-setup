#!/bin/bash

# --- Check if it's a Git repository ---
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: You are not inside a Git repository."
    echo "Please navigate to the root folder of your Git project and try again."
    exit 1
fi
# --- End of check ---

echo "Fetching remote branches to ensure your local list is up-to-date..."
git fetch -p

echo "Local branches that will be removed (no longer exist on the remote server):"

# Get a list of local branches and check if their upstream exists
git branch -vv | grep ': gone]' | awk '{print $1}' | while read branch; do
    if [[ "$branch" == "main" || "$branch" == "master" ]]; then
        echo "Skipping branch '$branch' as it's a main branch."
        continue
    fi
    echo "  - $branch"
    git branch -D "$branch"
done

echo ""
echo "Cleanup complete."