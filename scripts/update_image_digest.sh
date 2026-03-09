#!/bin/bash
set -e

IMAGE_REPO="amruthpillai/reactive-resume"
IMAGE_TAG="latest"
COMPOSE_FILE="docker-compose.ci.yml"

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ docker is required."
  exit 1
fi

echo "📦 Pulling $IMAGE_REPO:$IMAGE_TAG..."
docker pull "$IMAGE_REPO:$IMAGE_TAG"

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_REPO:$IMAGE_TAG")
if [ -z "$DIGEST" ]; then
  echo "❌ Unable to resolve image digest."
  exit 1
fi

echo "✅ Resolved digest: $DIGEST"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ $COMPOSE_FILE not found."
  exit 1
fi

echo "📝 Updating $COMPOSE_FILE..."
python3 - "$COMPOSE_FILE" "$DIGEST" <<'PY'
import sys

path = sys.argv[1]
digest = sys.argv[2]

with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

updated = False
for i, line in enumerate(lines):
    if "image: amruthpillai/reactive-resume" in line:
        indent = line.split("image:")[0]
        lines[i] = f"{indent}image: {digest}\n"
        updated = True
        break

if not updated:
    raise SystemExit("❌ image line not found in compose file")

with open(path, "w", encoding="utf-8") as f:
    f.writelines(lines)
PY

echo "✅ Updated $COMPOSE_FILE"
