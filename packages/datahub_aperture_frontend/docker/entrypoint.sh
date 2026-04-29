#!/bin/sh
set -eu

# Default to root if not set
BASE_HREF="${BASE_HREF:-/}"

# Ensure leading slash
case "$BASE_HREF" in
  /*) ;;
  *) BASE_HREF="/$BASE_HREF" ;;
esac

# Ensure trailing slash
case "$BASE_HREF" in
  */) ;;
  *) BASE_HREF="$BASE_HREF/" ;;
esac

sed -i "s|/__BASE_HREF__/|$BASE_HREF|g" /usr/share/caddy/index.html

exec "$@"