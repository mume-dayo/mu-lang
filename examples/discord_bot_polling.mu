# Discord Bot with Polling (Python-compatible API, Rust-based)
# Python版と同じインターフェース、100% Rust実装
# 使用例: mumei discord_bot_polling.mu

import "d_rust.mu" as d;

print("=== Discord Bot (Polling Mode) ===");
print("Python-compatible API, Rust implementation");
print("");

# ============================================================================
# Botセットアップ
# ============================================================================

# Botを作成（Python版と同じAPI）
d.create_bot("!");

# Bot起動時のイベント
d.on_ready(lambda() {
    print("🤖 Bot is ready and listening!");
    print("   Monitoring for messages...");
});

# メッセージ受信時のイベント
d.on_message(lambda(message) {
    let author = message["author"];
    let content = message["content"];

    # Bot自身のメッセージは無視
    if (has_key(author, "bot") and author["bot"]) {
        return None;
    }

    print("📨 Message from " + author["username"] + ": " + content);
});

# ============================================================================
# コマンド登録（Python版と同じAPI）
# ============================================================================

# !ping コマンド
d.command("ping", lambda(ctx, args) {
    print("  → Executing !ping command");
    d.reply(ctx, "🏓 Pong! Bot is responsive!");
});

# !hello コマンド
d.command("hello", lambda(ctx, args) {
    let author = ctx["author"];
    let username = author["username"];
    print("  → Executing !hello command for " + username);
    d.reply(ctx, "Hello, " + username + "! 👋 Welcome to Rust Bot!");
});

# !info コマンド
d.command("info", lambda(ctx, args) {
    print("  → Executing !info command");
    d.send_embed(
        ctx["channel_id"],
        "Bot Information",
        "This bot is powered by 100% Rust implementation!\\nNo Python dependencies!",
        d.COLOR_GREEN
    );
});

# !echo コマンド
d.command("echo", lambda(ctx, args) {
    if (len(args) == 0) {
        d.reply(ctx, "Usage: !echo <message>");
    } else {
        let message = join(" ", args);
        print("  → Echoing: " + message);
        d.reply(ctx, "Echo: " + message);
    }
});

# !help コマンド
d.command("help", lambda(ctx, args) {
    print("  → Executing !help command");
    let help_msg = "**Available Commands:**\\n";
    help_msg = help_msg + "!ping - Check bot status\\n";
    help_msg = help_msg + "!hello - Greet the bot\\n";
    help_msg = help_msg + "!info - Bot information\\n";
    help_msg = help_msg + "!echo <msg> - Echo a message\\n";
    help_msg = help_msg + "!help - Show this help";

    d.reply(ctx, help_msg);
});

# ============================================================================
# Botを起動
# ============================================================================

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");
let channel_id = env("DISCORD_CHANNEL_ID");

if (token == None or token == "") {
    print("❌ Error: DISCORD_TOKEN environment variable not set");
    print("   Set it with: export DISCORD_TOKEN='your-bot-token'");
} else if (channel_id == None or channel_id == "") {
    print("❌ Error: DISCORD_CHANNEL_ID environment variable not set");
    print("   Set it with: export DISCORD_CHANNEL_ID='your-channel-id'");
    print("");
    print("💡 To get channel ID:");
    print("   1. Enable Developer Mode in Discord settings");
    print("   2. Right-click on a channel");
    print("   3. Click 'Copy ID'");
} else {
    # Botを起動
    d.run(token);

    print("✅ Commands registered:");
    print("   !ping, !hello, !info, !echo, !help");
    print("");

    # ポーリングループを開始（5秒ごと）
    print("🔄 Starting polling loop (Ctrl+C to stop)...");
    d.start_polling(channel_id, 5);
}
