# Telegram Stickers Skill

🎨 Smart Telegram sticker collection and sending for OpenClaw agents.

## Features

- **Auto-collect** stickers sent by users
- **Smart sending** based on context and Reactions-style rules
- **Frequency limits** (max 1 sticker per 5-10 messages)
- **Native Telegram API** for reliable delivery
- **Usage tracking** and statistics

## Installation

```bash
# Clone to your OpenClaw workspace
git clone <repo-url> ~/.openclaw/workspace/skills/tg-stickers

# Or download and extract
cd ~/.openclaw/workspace/skills
tar -xzf tg-stickers.tar.gz
```

## Quick Start

### 🔍 Check Your Collection

After installation, check if you have stickers ready:

```bash
cd ~/.openclaw/workspace/skills/tg-stickers
chmod +x check-collection.sh
./check-collection.sh
```

**If empty:** Follow the "First Use" steps below.

---

### 🚀 First Use

**Important:** This skill needs stickers to work! When you first install it:

1. **Send me some stickers** in Telegram
2. I'll automatically collect them (file_id, emoji, set name)
3. Then I can send them back smartly based on context

**Empty collection?** If `stickers.json` is empty or missing, I'll remind you:
> "Send me some stickers first! I'll collect them and use them in our chats. 🎨"

---

### 1. Sticker Collection

**🆕 Import entire sticker pack (NEW in v0.1.1):**

```bash
cd ~/.openclaw/workspace/skills/tg-stickers
./import-sticker-pack.sh <pack_name>
```

Example:
```bash
./import-sticker-pack.sh "p_8RnHygLOjgFhGENFwoc1_by_SigStick11Bot"
```

**Or add individual stickers:**

```bash
./add-sticker.sh <file_id> <emoji> [set_name] [tags]
```

Example:
```bash
./add-sticker.sh "CAACAgEAAxUA..." "😀" "TomTheLizard" "happy,celebration"
```

### 2. Sending Stickers

Check if you should send a sticker:

```bash
python3 should_send_sticker.py "context" "user_message"
```

If yes, send it:

```bash
./send-sticker.sh <file_id> <chat_id> "context description"
```

## Configuration

Edit `stickers.json`:

```json
{
  "config": {
    "min_messages_between_stickers": 5,
    "max_messages_between_stickers": 10,
    "enabled": true
  }
}
```

## Sending Rules

Based on OpenClaw's Reactions guidelines:

**✅ Send stickers when:**
- Celebrating success
- Expressing gratitude or apology
- Adding humor
- Showing genuine emotion
- Emphasizing important moments

**❌ Don't send when:**
- Routine updates
- Technical answers
- Data reports
- Too frequently

**Frequency:** Max 1 sticker per 5-10 messages

## Integration with AGENTS.md

Add to your `AGENTS.md`:

```markdown
### 🎨 Send Stickers Like a Human!
On Telegram, use the `tg-stickers` skill to collect and send stickers smartly.

**Usage:**
\`\`\`bash
cd /Users/ben/clawd/skills/tg-stickers
python3 should_send_sticker.py "context" "user_message"
./send-sticker.sh <file_id> 5594967800 "context"
\`\`\`

**Core principle:** Stickers amplify emotion. Use sparingly and meaningfully.
```

## Files

- `SKILL.md` - Detailed documentation
- `stickers.json` - Sticker collection database
- `send-sticker.sh` - Send sticker via Telegram API
- `add-sticker.sh` - Add sticker to collection
- `should_send_sticker.py` - Smart decision logic
- `README.md` - This file

## Requirements

- OpenClaw with Telegram channel configured
- `jq` for JSON manipulation
- Python 3.6+ for decision logic
- Telegram Bot Token in `~/.openclaw/openclaw.json`

## Usage Example

```bash
# User says: "I really learned it!!!"
# Check if should send
result=$(python3 should_send_sticker.py "learning_success" "I really learned it!!!")

# If yes, send celebration sticker
if echo "$result" | jq -e '.should_send'; then
    file_id=$(echo "$result" | jq -r '.suggested_file_id')
    ./send-sticker.sh "$file_id" 5594967800 "User celebrated learning success"
fi
```

## License

MIT

## Credits

Created with ❤️ for the OpenClaw community.

---

**Questions?** Open an issue or discuss on [OpenClaw Discord](https://discord.com/invite/clawd)
