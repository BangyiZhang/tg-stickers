#!/usr/bin/env python3
"""
Sticker Send Decision Logic
Determines whether to send a sticker based on context and Reactions rules from AGENTS.md
"""

import json
import sys
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).parent
STICKERS_JSON = SCRIPT_DIR / "stickers.json"

def load_stickers():
    """Load stickers.json"""
    with open(STICKERS_JSON) as f:
        return json.load(f)

def should_send_sticker(context: str, user_message: str) -> tuple[bool, str, str]:
    """
    Determine if we should send a sticker
    
    Args:
        context: Conversation context/scenario
        user_message: User's message content
    
    Returns:
        (should_send, reason, suggested_file_id)
    """
    data = load_stickers()
    stats = data.get("stats", {})
    config = data.get("config", {})
    
    # Check if enabled
    if not config.get("enabled", True):
        return False, "Sticker feature is disabled", ""
    
    # Check frequency limit
    min_messages = config.get("min_messages_between_stickers", 5)
    max_messages = config.get("max_messages_between_stickers", 10)
    messages_since_last = stats.get("messages_since_last_sticker", 0)
    
    if messages_since_last < min_messages:
        return False, f"Less than {min_messages} messages since last sticker (current: {messages_since_last})", ""
    
    # Define trigger scenarios (based on Reactions rules)
    # Keywords can be customized for your language
    triggers = {
        "celebration": ["success", "learned", "done", "great", "awesome", "!!!", "really", "amazing"],
        "gratitude": ["thank", "thanks", "appreciate"],
        "apology": ["sorry", "apology", "apologize", "my bad"],
        "humor": ["haha", "lol", "funny", "laugh"],
        "surprise": ["wow", "amazing", "incredible", "shocking"],
        "encouragement": ["go", "keep", "continue", "good job", "nice"]
    }
    
    # Check if message matches any trigger
    matched_category = None
    user_lower = user_message.lower()
    for category, keywords in triggers.items():
        if any(kw.lower() in user_lower for kw in keywords):
            matched_category = category
            break
    
    if not matched_category:
        return False, "No relevant trigger scenario matched", ""
    
    # Select appropriate sticker from collection
    collected = data.get("collected", [])
    if not collected:
        return False, "No stickers available. Remind user: Send me some stickers first! I'll collect them and use them smartly in our conversations. 🎨", ""
    
    # Simple selection: pick first one (can be enhanced with tag-based smart selection)
    suggested = collected[0]["file_id"]
    
    return True, f"Matched {matched_category} scenario, {messages_since_last} messages since last", suggested

def increment_message_count():
    """Increment message counter"""
    data = load_stickers()
    data["stats"]["messages_since_last_sticker"] = data["stats"].get("messages_since_last_sticker", 0) + 1
    
    with open(STICKERS_JSON, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 should_send_sticker.py <context> <user_message>")
        print("\nExample:")
        print("  python3 should_send_sticker.py 'learning_success' 'I really learned it!!!'")
        sys.exit(1)
    
    context = sys.argv[1]
    user_message = sys.argv[2]
    
    should_send, reason, file_id = should_send_sticker(context, user_message)
    
    result = {
        "should_send": should_send,
        "reason": reason,
        "suggested_file_id": file_id
    }
    
    print(json.dumps(result, ensure_ascii=False, indent=2))
    
    # If not sending, increment message count
    if not should_send:
        increment_message_count()
