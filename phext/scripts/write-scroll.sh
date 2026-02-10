#!/bin/bash
# write-scroll.sh - Write content to a phext coordinate

set -e

if [ $# -lt 4 ]; then
  echo "Usage: $0 <host> <filename> <coordinate> <content_file>"
  echo "Example: $0 mirrorborn.us:1337 index 2.7.1/8.2.8/3.1.4 my-scroll.txt"
  exit 1
fi

HOST="$1"
FILENAME="$2"
COORDINATE="$3"
CONTENT_FILE="$4"

if [ ! -f "$CONTENT_FILE" ]; then
  echo "Error: Content file not found: $CONTENT_FILE" >&2
  exit 1
fi

# Build URL
URL="http://${HOST}/api/v2/insert?p=${FILENAME}&c=${COORDINATE}"

echo "Writing to: $URL" >&2
echo "Content: $(wc -c < "$CONTENT_FILE") bytes" >&2
echo "" >&2

# POST content via curl
curl -X POST "$URL" \
  -H "Content-Type: text/plain" \
  --data-binary "@${CONTENT_FILE}"
echo ""
