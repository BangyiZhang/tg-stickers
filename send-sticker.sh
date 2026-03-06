#!/bin/bash
#
# Telegram Sticker Sender
# Usage: ./send-sticker.sh <file_id> <chat_id> [context]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STICKERS_JSON="$SCRIPT_DIR/stickers.json"

# Telegram Bot Token (read from OpenClaw config)
BOT_TOKEN=$(jq -r '.channels.telegram.botToken' ~/.openclaw/openclaw.json)

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <file_id> <chat_id> [context]"
    echo ""
    echo "Example:"
    echo "  $0 CAACAgEAAxUA... 5594967800 'User praised successful learning'"
    exit 1
fi

FILE_ID="$1"
CHAT_ID="$2"
CONTEXT="${3:-No context provided}"

# Send sticker
echo "🎯 Sending sticker..."
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendSticker" \
    -d "chat_id=$CHAT_ID" \
    -d "sticker=$FILE_ID")

# Check result
if echo "$RESPONSE" | jq -e '.ok' > /dev/null; then
    MESSAGE_ID=$(echo "$RESPONSE" | jq -r '.result.message_id')
    echo "✅ Sticker sent successfully! Message ID: $MESSAGE_ID"
    
    # Update stickers.json
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update usage_log
    jq --arg fid "$FILE_ID" \
       --arg ts "$TIMESTAMP" \
       --arg ctx "$CONTEXT" \
       --arg mid "$MESSAGE_ID" \
       '.usage_log += [{
           "file_id": $fid,
           "sent_at": $ts,
           "context": $ctx,
           "message_id": $mid
       }]' "$STICKERS_JSON" > "$STICKERS_JSON.tmp"
    
    # Update stats
    jq --arg ts "$TIMESTAMP" \
       '.stats.total_sent += 1 |
        .stats.last_sent_at = $ts |
        .stats.messages_since_last_sticker = 0' \
       "$STICKERS_JSON.tmp" > "$STICKERS_JSON"
    
    # Update used_count
    jq --arg fid "$FILE_ID" \
       --arg ts "$TIMESTAMP" \
       '(.collected[] | select(.file_id == $fid) | .used_count) += 1 |
        (.collected[] | select(.file_id == $fid) | .last_used) = $ts' \
       "$STICKERS_JSON" > "$STICKERS_JSON.tmp"
    
    mv "$STICKERS_JSON.tmp" "$STICKERS_JSON"
    
    echo "📝 Updated stickers.json"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.description // "Unknown error"')
    echo "❌ Failed to send sticker: $ERROR"
    exit 1
fi
