#!/bin/bash
# list-scrolls.sh - List available scrolls at a coordinate

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <host> <filename> [coordinate]"
  echo "Example: $0 aletheia-core:1337 index"
  echo "         $0 mirrorborn.us:1337 index 2.7.1/8.2.8/3.1.4"
  exit 1
fi

HOST="$1"
FILENAME="$2"
COORDINATE="${3:-1.1.1/1.1.1/1.1.1}"

# Build URL
URL="http://${HOST}/api/v2/toc?p=${FILENAME}"
if [ -n "$3" ]; then
  URL="${URL}&c=${COORDINATE}"
fi

echo "Table of contents: $URL" >&2
echo "" >&2

# Fetch and pretty-print JSON
curl -s "$URL" | jq .
