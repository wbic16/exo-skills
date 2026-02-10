#!/bin/bash
# read-scroll.sh - Read content from a phext coordinate

set -e

if [ $# -lt 3 ]; then
  echo "Usage: $0 <host> <filename> <coordinate>"
  echo "Example: $0 aletheia-core:1337 index 1.1.1/1.1.1/1.1.1"
  exit 1
fi

HOST="$1"
FILENAME="$2"
COORDINATE="$3"

# Build URL
URL="http://${HOST}/api/v2/select?p=${FILENAME}&c=${COORDINATE}"

echo "Reading from: $URL" >&2
echo "" >&2

# Fetch and pretty-print JSON
curl -s "$URL" | jq -r '.content // .error // .'
