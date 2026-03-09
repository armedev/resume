#!/bin/bash
set -e

BASE_URL="http://localhost:3000"
EMAIL="ci.user@example.com"
PASSWORD="CiPassword123!"
USERNAME="ci-user"
DISPLAY_USERNAME="ci-user"
RESUME_JSON_PATH="${1:-resume.json}"
OUTPUT_PDF="${2:-output/resume.pdf}"
CURL_TIMEOUT=20
COOKIE_JAR="${TMPDIR:-/tmp}/rxresume_cookies.txt"

echo "⏳ Waiting for RxResume to be ready..."
for i in {1..30}; do
  if curl -sf "$BASE_URL/api/health" > /dev/null; then
    echo "✅ RxResume is up!"
    break
  fi
  echo "Attempt $i/30 - not ready yet..."
  sleep 5
done

echo "📝 Registering CI user..."
curl -sS -X POST "$BASE_URL/api/auth/sign-up/email" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"CI User\",\"username\":\"$USERNAME\",\"displayUsername\":\"$DISPLAY_USERNAME\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"callbackURL\":\"/dashboard\"}" \
  --max-time "$CURL_TIMEOUT" > /dev/null || true

echo "🔐 Logging in..."
LOGIN_RESPONSE=$(curl -sS -X POST "$BASE_URL/api/auth/sign-in/email" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
  -c "$COOKIE_JAR" \
  -w "\n%{http_code}" \
  --max-time "$CURL_TIMEOUT")

LOGIN_STATUS="${LOGIN_RESPONSE##*$'\n'}"
LOGIN_BODY="${LOGIN_RESPONSE%$'\n'*}"

if [ "$LOGIN_STATUS" != "200" ]; then
  echo "❌ Login failed with status $LOGIN_STATUS"
  echo "$LOGIN_BODY"
  exit 1
fi

echo "✅ Logged in!"

echo "📤 Importing resume JSON..."
IMPORT_PAYLOAD_FILE=$(mktemp)
trap 'rm -f "$IMPORT_PAYLOAD_FILE"' EXIT
python3 - "$RESUME_JSON_PATH" "$IMPORT_PAYLOAD_FILE" <<'PY'
import json
import sys

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, "r", encoding="utf-8") as f:
    data = json.load(f)

with open(output_path, "w", encoding="utf-8") as f:
    json.dump({"json": {"data": data}, "meta": []}, f)
PY

IMPORT_RESPONSE=$(curl -sS -X POST "$BASE_URL/api/rpc/resume/import" \
  -H "Content-Type: application/json" \
  -b "$COOKIE_JAR" \
  -d @"$IMPORT_PAYLOAD_FILE" \
  --max-time "$CURL_TIMEOUT")

RESUME_ID=$(echo "$IMPORT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['json'])")
echo "✅ Resume imported with ID: $RESUME_ID"

echo "🖨️ Exporting PDF..."
PRINT_RESPONSE=$(curl -sS -X POST "$BASE_URL/api/rpc/printer/printResumeAsPDF" \
  -H "Content-Type: application/json" \
  -b "$COOKIE_JAR" \
  -d "{\"json\":{\"id\":\"$RESUME_ID\"},\"meta\":[]}" \
  --max-time "$CURL_TIMEOUT")

PDF_URL=$(echo "$PRINT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['json']['url'])")
mkdir -p "$(dirname "$OUTPUT_PDF")"
curl -sS "$PDF_URL" --output "$OUTPUT_PDF" --max-time "$CURL_TIMEOUT"

echo "✅ PDF saved to $OUTPUT_PDF"
