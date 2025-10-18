# Discord Bot with Pure Rust Implementation
# Python依存なし - 100% Rust実装
# 使用例: mumei discord_bot_rust.mu

import "d_rust.mu" as d;

print("=== Discord Bot (Pure Rust) ===");
print("No Python dependencies!");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == None or token == "") {
    print("❌ Error: DISCORD_TOKEN environment variable not set");
    print("   Set it with: export DISCORD_TOKEN='your-bot-token'");
} else {
    # トークンを設定
    d.set_token(token);
    print("✅ Discord token configured");
    print("");

    # ============================================================================
    # サンプルコマンド実装（Webhook経由）
    # ============================================================================

    print("📝 Example Usage:");
    print("");

    # チャンネルIDを環境変数から取得（テスト用）
    let channel_id = env("DISCORD_CHANNEL_ID");

    if (channel_id != None and channel_id != "") {
        print("Testing Discord REST API...");
        print("");

        # 1. メッセージ送信
        print("1. Sending message...");
        try {
            let response = d.send(channel_id, "Hello from Mumei Rust Bot! 🦀");
            print("   ✅ Message sent");
            print("   Response: " + str(response));
        } catch (e) {
            print("   ❌ Error: " + str(e));
        }
        print("");

        # 2. Embed送信
        print("2. Sending embed...");
        try {
            let response = d.send_embed(
                channel_id,
                "Rust Bot Status",
                "This message was sent using 100% Rust implementation!",
                d.COLOR_GREEN
            );
            print("   ✅ Embed sent");
        } catch (e) {
            print("   ❌ Error: " + str(e));
        }
        print("");

        # 3. チャンネル情報取得
        print("3. Getting channel info...");
        try {
            let channel = d.get_channel(channel_id);
            print("   Channel name: " + channel["name"]);
            print("   Channel type: " + str(channel["type"]));
        } catch (e) {
            print("   ❌ Error: " + str(e));
        }
        print("");

        # 4. メッセージ履歴取得
        print("4. Getting message history...");
        try {
            let messages = d.get_messages(channel_id, 5);
            print("   Retrieved " + str(len(messages)) + " messages");
            for (msg in messages) {
                print("     - " + msg["content"]);
            }
        } catch (e) {
            print("   ❌ Error: " + str(e));
        }
        print("");

    } else {
        print("💡 Set DISCORD_CHANNEL_ID to test REST API calls");
        print("   export DISCORD_CHANNEL_ID='your-channel-id'");
        print("");
    }

    # ============================================================================
    # Webhook例
    # ============================================================================

    let webhook_url = env("DISCORD_WEBHOOK_URL");

    if (webhook_url != None and webhook_url != "") {
        print("5. Sending via Webhook...");
        try {
            d.webhook_send(webhook_url, "Message via Webhook from Rust Bot! 🚀");
            print("   ✅ Webhook message sent");
        } catch (e) {
            print("   ❌ Error: " + str(e));
        }
        print("");
    }

    # ============================================================================
    # HTTP API デモ
    # ============================================================================

    print("6. HTTP API Example (GET request)...");
    try {
        let response = d.http_get("https://api.github.com/users/github", None);
        let data = d.parse_json(response);
        print("   GitHub user: " + data["login"]);
        print("   Public repos: " + str(data["public_repos"]));
    } catch (e) {
        print("   ❌ Error: " + str(e));
    }
    print("");

    # ============================================================================
    # 情報表示
    # ============================================================================

    d.info();
    print("");

    print("✨ Features:");
    print("  ✅ Pure Rust HTTP client (reqwest)");
    print("  ✅ Discord REST API integration");
    print("  ✅ No Python dependencies");
    print("  ✅ High performance");
    print("  ✅ Type-safe");
    print("");

    print("📚 Available Functions:");
    print("  - d.send(channel_id, content)");
    print("  - d.send_embed(channel_id, title, desc, color)");
    print("  - d.delete_message(channel_id, message_id)");
    print("  - d.edit_message(channel_id, message_id, content)");
    print("  - d.add_reaction(channel_id, message_id, emoji)");
    print("  - d.create_text_channel(guild_id, name)");
    print("  - d.create_voice_channel(guild_id, name)");
    print("  - d.delete_channel(channel_id)");
    print("  - d.rename_channel(channel_id, name)");
    print("  - d.get_channel(channel_id)");
    print("  - d.create_role(guild_id, name, color)");
    print("  - d.add_role(guild_id, user_id, role_id)");
    print("  - d.remove_role(guild_id, user_id, role_id)");
    print("  - d.kick(guild_id, user_id, reason)");
    print("  - d.ban(guild_id, user_id, reason)");
    print("  - d.set_nickname(guild_id, user_id, nickname)");
    print("  - d.webhook_send(url, content)");
    print("  - d.webhook_send_embed(url, embed_json)");
    print("  - d.create_webhook(channel_id, name)");
    print("  - d.get_user(user_id)");
    print("  - d.get_guild(guild_id)");
    print("  - d.get_messages(channel_id, limit)");
    print("  - d.http_get(url, headers)");
    print("  - d.http_post(url, json, headers)");
    print("  - d.parse_json(json_str)");
    print("  - d.to_json(obj)");
    print("");

    print("🎨 Color Constants:");
    print("  - d.COLOR_RED, d.COLOR_GREEN, d.COLOR_BLUE");
    print("  - d.COLOR_YELLOW, d.COLOR_PURPLE, d.COLOR_ORANGE");
    print("  - d.COLOR_BLACK, d.COLOR_WHITE");
    print("");
}

print("=== Discord Rust Bot Demo Complete ===");
