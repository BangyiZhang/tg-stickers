#!/bin/bash
#
# Add Sticker to Collection
# Usage: ./add-sticker.sh <file_id> <emoji> [set_name] [tags...]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STICKERS_JSON="$SCRIPT_DIR/stickers.json"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <file_id> <emoji> [set_name] [tags...]"
    echo ""
    echo "Example:"
    echo "  $0 CAACAgEAA... 😀 TomTheLizard happy,excited,celebration"
    exit 1
fi

FILE_ID="$1"
EMOJI="$2"
SET_NAME="${3:-unknown}"
TAGS="${4:-}"

# Check if already exists
if jq -e --arg fid "$FILE_ID" '.collected[] | select(.file_id == $fid)' "$STICKERS_JSON" > /dev/null; then
    echo "⚠️  Sticker already exists in collection"
    exit 0
fi

# Convert tags to array
IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
TAGS_JSON=$(printf '%s\n' "${TAG_ARRAY[@]}" | jq -R . | jq -s .)

# Add to collection
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq --arg fid "$FILE_ID" \
   --arg emoji "$EMOJI" \
   --arg set "$SET_NAME" \
   --arg ts "$TIMESTAMP" \
   --argjson tags "$TAGS_JSON" \
   '.collected += [{
       "file_id": $fid,
       "emoji": $emoji,
       "set_name": $set,
       "added_at": $ts,
       "used_count": 0,
       "last_used": null,
       "tags": $tags
   }]' "$STICKERS_JSON" > "$STICKERS_JSON.tmp"

# Update stats
jq '.stats.total_collected += 1' "$STICKERS_JSON.tmp" > "$STICKERS_JSON"

rm "$STICKERS_JSON.tmp"

echo "✅ Added sticker to collection:"
echo "   File ID: $FILE_ID"
echo "   Emoji: $EMOJI"
echo "   Set: $SET_NAME"
echo "   Tags: ${TAG_ARRAY[*]}"
