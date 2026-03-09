#!/bin/bash
set -e

BASE_URL="${RXRESUME_BASE_URL:-http://localhost:3000}"
RESUME_JSON_PATH="${1:-resume.json}"
OUTPUT_PDF="${2:-output/resume.pdf}"

if ! curl -sf --max-time 3 "$BASE_URL/api/health" > /dev/null; then
  echo "🚀 Starting RxResume stack..."
  docker compose -f docker-compose.ci.yml up -d --wait --wait-timeout 120 app
fi

python3 scripts/generate_pdf.py "$RESUME_JSON_PATH" "$OUTPUT_PDF"

echo "ℹ️ Stack left running for faster repeats."
echo "   Stop it with: docker compose -f docker-compose.ci.yml down"
