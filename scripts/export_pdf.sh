#!/bin/bash
set -e

BASE_URL="http://localhost:3000"
EMAIL="ci@resume.local"
PASSWORD="ci_password_123"
RESUME_JSON_PATH="${1:-resume.json}"
OUTPUT_PDF="${2:-output/resume.pdf}"

echo "⏳ Waiting for RxResume to be ready..."
until curl -sf "$BASE_URL/api/health" > /dev/null; do
  sleep 3
done
echo "✅ RxResume is up!"

echo "📝 Registering CI user..."
REGISTER_RESPONSE=$(curl -sf -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"CI User\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" || true)

echo "🔐 Logging in..."
LOGIN_RESPONSE=$(curl -sf -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"identifier\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
echo "✅ Logged in!"

echo "📤 Importing resume JSON..."
IMPORT_RESPONSE=$(curl -sf -X POST "$BASE_URL/api/resume/import" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @"$RESUME_JSON_PATH")

RESUME_ID=$(echo "$IMPORT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "✅ Resume imported with ID: $RESUME_ID"

echo "🖨️ Exporting PDF..."
mkdir -p "$(dirname "$OUTPUT_PDF")"
curl -sf -X GET "$BASE_URL/api/resume/$RESUME_ID/print" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --output "$OUTPUT_PDF"

echo "✅ PDF saved to $OUTPUT_PDF"
