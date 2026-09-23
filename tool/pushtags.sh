#!/usr/bin/env bash
set -euo pipefail

REMOTE="${1:-origin}"

local_tags=$(git tag)
remote_tags=$(git ls-remote --tags "$REMOTE" | awk -F'refs/tags/' '{print $2}' | sed 's/\^{}//' | sort -u)

for tag in $local_tags; do
    if ! grep -qx "$tag" <<< "$remote_tags"; then
        echo "Pushing new tag: $tag"
        git push "$REMOTE" "$tag"
    fi
done