---
name: tg-stickers
description: "Collect and send Telegram stickers smartly. Learns from stickers sent by user, sends them back following Reactions rules (max 1/5-10 exchanges, only when truly relevant)."
---

# Telegram Stickers Skill

Collect stickers sent by users and intelligently send them back at appropriate moments.

## Features

1. **Auto-collect** - Automatically save file_id and emoji when users send stickers
2. **Smart sending** - Send stickers based on AGENTS.md Reactions rules
3. **Categorization** - Organize stickers by emoji/emotion

## Usage

### 🚀 First Use
**Important:** This skill requires stickers to function!

**On first use:**
1. User sends you stickers in Telegram
2. Agent collects them (file_id, emoji, set_name)
3. Agent can then intelligently send them back

**Empty collection reminder:**
If no stickers available, agent should prompt:
> "Send me some stickers first! I'll collect them and use them smartly in our conversations. 🎨"

---

### Collect Stickers
User sends sticker → Auto-save to `stickers.json`

### Send Stickers
```bash
# Using native Telegram API
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendSticker" \
  -d "chat_id=<CHAT_ID>" \
  -d "sticker=<FILE_ID>"
```

Or using OpenClaw command:
```bash
openclaw message sticker send \
  --channel telegram \
  --target <CHAT_ID> \
  --sticker-id <FILE_ID>
```

## Sending Rules (Based on Reactions)

### ✅ **Send stickers when:**
1. **Celebrating success** - User completes important tasks, learns new skills
2. **Humorous response** - Funny moments in conversation
3. **Expressing emotion** - Thanks, apology, surprise, encouragement
4. **Emphasizing key points** - Important reminders or warnings

### ❌ **Don't send stickers when:**
1. Routine status updates
2. Technical answers
3. Data reports
4. Every few messages

### 📏 **Frequency Limit**
- **Max 1 sticker / 5-10 messages**
- **Only when truly relevant**
- **Enhance emotion**, don't dominate

## File Structure

```
/Users/ben/clawd/skills/tg-stickers/
├── SKILL.md           # This documentation
├── stickers.json      # Sticker storage (file_id, emoji, usage count)
└── send-sticker.sh    # Send script
```

## stickers.json Format

```json
{
  "collected": [
    {
      "file_id": "CAACAgEAAxUAAWmqdOXhcUn5bv_z9t8aqnah9zHYAALbBgACXXhZROozzi8ktqoROgQ",
      "emoji": "🌞",
      "set_name": "p_8RnHygLOjgFhGENFwoc1_by_SigStick11Bot",
      "added_at": "2026-03-06T14:31:00Z",
      "used_count": 0,
      "last_used": null,
      "tags": ["happy", "sunny", "positive"]
    }
  ],
  "usage_log": [
    {
      "file_id": "...",
      "sent_at": "2026-03-06T14:36:00Z",
      "context": "User praised successful learning"
    }
  ],
  "stats": {
    "total_collected": 1,
    "total_sent": 0,
    "last_sent_at": null
  }
}
```

## Usage Examples

### Scenario 1: User Praise
```
User: "I really learned it!!!"
Assistant: 🎉 [send celebration sticker]
```

### Scenario 2: Completing Difficult Task
```
User: "Finally got MiniMem installed"
Assistant: ✅ Success! [send celebration/encouragement sticker]
```

### Scenario 3: Humorous Moment
```
User: "You're so silly"
Assistant: 😅 My bad! [send self-deprecating sticker]
```

## Integration with Conversation Flow

1. **After each message** → Determine if sticker should be sent
2. **Check rules** → Frequency, relevance, emotional match
3. **Select sticker** → Choose appropriate one from `stickers.json`
4. **Send** → Use native API or OpenClaw command
5. **Record** → Update usage_log and stats

## Development TODO

- [ ] Create stickers.json storage file
- [ ] Implement sticker collection logic (monitor user-sent stickers)
- [ ] Implement smart sending decision (based on Reactions rules)
- [ ] Create send script (send-sticker.sh)
- [ ] Add sticker categorization and tagging system
- [ ] Implement frequency limiting (1/5-10 messages)
- [ ] Integrate into AGENTS.md workflow

---

**Core Philosophy:** Use stickers like humans do - moderately, relevantly, with emotional value.
