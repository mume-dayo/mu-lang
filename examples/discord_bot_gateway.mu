# Discord Bot with Gateway (Full-Featured Rust Implementation)
# リアルタイムイベント、スラッシュコマンド、ボタン、セレクトメニュー
# 使用例: mumei discord_bot_gateway.mu

import "d_rust_full.mu" as d;

print("=== Discord Bot (Gateway + UI Components) ===");
print("100% Rust implementation with real-time events");
print("");

# ============================================================================
# Bot設定
# ============================================================================

d.create_bot("!");

# Application IDを設定（スラッシュコマンド用）
let app_id = env("DISCORD_APPLICATION_ID");
if (app_id != None and app_id != "") {
    d.set_application_id(app_id);
}

# ============================================================================
# イベントハンドラー
# ============================================================================

# Bot起動時
d.on_ready(lambda() {
    print("🤖 Bot is ready!");
    print("   Listening for real-time events...");
    print("");
});

# メッセージ受信時
d.on_message(lambda(message) {
    let author = message["author"];
    let content = message["content"];

    # Bot自身は無視
    if (has_key(author, "bot") and author["bot"]) {
        return None;
    }

    print("📨 [" + author["username"] + "]: " + content);
});

# インタラクション受信時（ボタン、スラッシュコマンドなど）
d.on_interaction(lambda(interaction) {
    print("⚡ Interaction received: " + interaction["type"]);
});

# ============================================================================
# テキストコマンド
# ============================================================================

# !ping
d.command("ping", lambda(ctx, args) {
    print("  → !ping command");
    d.reply(ctx, "🏓 Pong! Gateway is active!");
});

# !hello
d.command("hello", lambda(ctx, args) {
    let author = ctx["author"];
    print("  → !hello command from " + author["username"]);
    d.reply(ctx, "Hello, " + author["username"] + "! 👋");
});

# !button - ボタンデモ
d.command("button", lambda(ctx, args) {
    print("  → !button command");

    let channel_id = ctx["channel_id"];

    # ボタンクリック時のコールバック
    let button_callback = lambda(interaction) {
        print("  → Button clicked!");
        d.respond(interaction, "✅ Button clicked! Thanks!");
    };

    d.send_button(
        channel_id,
        "Click the button below! 👇",
        "Click Me!",
        "button_demo",
        button_callback,
        d.BUTTON_PRIMARY  # 青色ボタン
    );
});

# !menu - セレクトメニューデモ
d.command("menu", lambda(ctx, args) {
    print("  → !menu command");

    let channel_id = ctx["channel_id"];

    # メニュー選択時のコールバック
    let select_callback = lambda(interaction) {
        let selected = interaction["data"]["values"][0];
        print("  → Selected: " + selected);
        d.respond(interaction, "You selected: " + selected + " ✅");
    };

    let options = [
        {"label": "Option 1", "value": "opt1"},
        {"label": "Option 2", "value": "opt2"},
        {"label": "Option 3", "value": "opt3"}
    ];

    d.send_select(
        channel_id,
        "Choose an option from the menu:",
        "select_demo",
        options,
        select_callback
    );
});

# !info
d.command("info", lambda(ctx, args) {
    print("  → !info command");
    d.send_embed(
        ctx["channel_id"],
        "Bot Information",
        "This bot is powered by 100% Rust implementation!\\n\\nFeatures:\\n• Real-time events (Gateway)\\n• Slash commands\\n• Buttons & Select menus\\n• No Python dependencies!",
        d.COLOR_GREEN
    );
});

# ============================================================================
# スラッシュコマンド
# ============================================================================

# /ping
d.slash_command("ping", "Check bot status", lambda(interaction) {
    print("  → /ping slash command");
    d.respond(interaction, "🏓 Pong! Gateway is active!");
});

# /hello
d.slash_command("hello", "Say hello", lambda(interaction) {
    let user = interaction["user"];
    print("  → /hello slash command from " + user["username"]);
    d.respond(interaction, "Hello, " + user["username"] + "! 👋");
});

# /vote
d.slash_command("vote", "Create a vote with buttons", lambda(interaction) {
    print("  → /vote slash command");

    # まず返信
    d.respond(interaction, "Creating vote...");

    # ボタン付きメッセージを送信
    let channel_id = interaction["channel_id"];

    let yes_callback = lambda(int) {
        d.respond(int, "You voted Yes! ✅");
    };

    let no_callback = lambda(int) {
        d.respond(int, "You voted No! ❌");
    };

    d.send_button(channel_id, "Vote: Do you like this bot?", "Yes", "vote_yes", yes_callback, d.BUTTON_SUCCESS);
    d.send_button(channel_id, "", "No", "vote_no", no_callback, d.BUTTON_DANGER);
});

# ============================================================================
# Botを起動
# ============================================================================

let token = env("DISCORD_TOKEN");

if (token == None or token == "") {
    print("❌ Error: DISCORD_TOKEN not set");
    print("   Set it with: export DISCORD_TOKEN='your-token'");
} else {
    print("✅ Commands registered:");
    print("   Text: !ping, !hello, !button, !menu, !info");
    print("   Slash: /ping, /hello, /vote");
    print("");

    if (app_id == None or app_id == "") {
        print("💡 Tip: Set DISCORD_APPLICATION_ID for slash commands");
        print("   export DISCORD_APPLICATION_ID='your-app-id'");
        print("");
    }

    # Gateway接続（リアルタイムイベント）
    # intents: 32767 = all intents
    # d.run()はmm_discord.pyのbot.run()と同じくブロッキングで動作
    # 内部で常時監視ループが回るため、この後のコードは実行されない
    d.run(token, 32767);
}
