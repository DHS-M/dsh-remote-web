#!/usr/bin/env bash
set -Eeuo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/deepseek-ai/deepseek-harness.git}"
UPSTREAM_COMMIT="${UPSTREAM_COMMIT:-b150a551b8d465e31e418e1b2eaf5e79bbb7d28e}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="$SCRIPT_DIR/patches/open-authority-web-only.patch"
TARGET_DIR="${1:-$PWD/deepseek-harness-remote}"
BUILD="${BUILD:-1}"

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target already exists: $TARGET_DIR" >&2
  echo "Choose another target directory or remove the existing directory." >&2
  exit 2
fi

mkdir -p "$(dirname -- "$TARGET_DIR")"
echo "Cloning official DeepSeek Harness at $UPSTREAM_COMMIT..."
git clone "$UPSTREAM_URL" "$TARGET_DIR"
cd "$TARGET_DIR"
git checkout --detach "$UPSTREAM_COMMIT"
echo "Applying the remote/web-only product patch..."
git apply --3way "$PATCH_FILE"
echo "Installing dependencies..."
pnpm install --frozen-lockfile

if [[ "$BUILD" == "1" ]]; then
  echo "Building client libraries, host libraries, and web assets..."
  pnpm run build:lib:client
  pnpm run build:lib:host
  pnpm run build:web
fi

echo
echo "Installation complete: $TARGET_DIR"
echo "Run locally:"
echo "  pnpm dsh web --host 0.0.0.0 --open-authority --no-open"
echo ""
echo "Security note: open-authority grants every reachable caller host authority."
