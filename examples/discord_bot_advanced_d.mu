# 高度なDiscord Bot機能デモ（d.muモジュール使用）
# ボタン、セレクトメニュー、ロール管理などの機能

import "d.mu" as d;

print("=== Advanced Discord Bot with d.mu ===");

# Botを作成
d.create_bot("!");

# グローバル変数（統計用）
let message_count = 0;
let command_count = 0;

# Bot起動時
d.on_ready(lambda() {
    print("✅ Advanced Bot is ready!");
    print("   Features: Buttons, Roles, Moderation");
});

# メッセージカウント
d.on_message(lambda(message) {
    let author = message["author"];
    if (!author["bot"]) {
        message_count = message_count + 1;
    }
});

# ============================================================================
# 基本コマンド
# ============================================================================

# 統計情報
d.command("stats", lambda(ctx, args) {
    command_count = command_count + 1;
    let stats_msg = "📊 Bot Statistics:\n";
    stats_msg = stats_msg + "Messages received: " + str(message_count) + "\n";
    stats_msg = stats_msg + "Commands executed: " + str(command_count);
    d.reply(ctx, stats_msg);
});

# ヘルプコマンド
d.command("help", lambda(ctx, args) {
    command_count = command_count + 1;
    let help_msg = "🤖 Available Commands:\n\n";
    help_msg = help_msg + "**Basic:**\n";
    help_msg = help_msg + "!help - Show this help\n";
    help_msg = help_msg + "!stats - Show bot statistics\n";
    help_msg = help_msg + "!button - Test button interaction\n";
    help_msg = help_msg + "!menu - Test select menu\n\n";
    help_msg = help_msg + "**Moderation:**\n";
    help_msg = help_msg + "!kick <user_id> <reason> - Kick a member\n";
    help_msg = help_msg + "!role <user_id> <role_id> - Add role to member\n";
    help_msg = help_msg + "!clear <count> - Delete messages\n";
    d.reply(ctx, help_msg);
});

# ============================================================================
# インタラクション（ボタン・メニュー）
# ============================================================================

# ボタンテスト
d.command("button", lambda(ctx, args) {
    command_count = command_count + 1;
    let channel_id = ctx["channel_id"];

    # ボタンクリック時のコールバック
    let button_callback = lambda(interaction) {
        let user = interaction["user"];
        d.respond(interaction, "✅ Button clicked by " + user["name"] + "!");
    };

    d.send_button(
        channel_id,
        "Click the button below! 👇",
        "Click Me!",
        "test_button",
        button_callback
    );
});

# セレクトメニューテスト
d.command("menu", lambda(ctx, args) {
    command_count = command_count + 1;
    let channel_id = ctx["channel_id"];

    # メニュー選択時のコールバック
    let select_callback = lambda(interaction, selected) {
        let user = interaction["user"];
        d.respond(interaction, "You selected: " + selected + " ✅");
    };

    # オプションのリスト
    let options = [
        {"label": "Option 1", "value": "opt1"},
        {"label": "Option 2", "value": "opt2"},
        {"label": "Option 3", "value": "opt3"}
    ];

    d.send_select(
        channel_id,
        "Choose an option from the menu below:",
        options,
        select_callback
    );
});

# ============================================================================
# モデレーション機能
# ============================================================================

# メンバーキック
d.command("kick", lambda(ctx, args) {
    command_count = command_count + 1;

    if (len(args) < 2) {
        d.reply(ctx, "❌ Usage: !kick <user_id> <reason>");
        return None;
    }

    let guild_id = ctx["guild_id"];
    let user_id = args[0];
    let reason = join(" ", args[1:]);

    try {
        d.kick(guild_id, user_id, reason);
        d.reply(ctx, "✅ Kicked user " + user_id + "\nReason: " + reason);
    } catch (e) {
        d.reply(ctx, "❌ Failed to kick: " + e);
    }
});

# ロール付与
d.command("role", lambda(ctx, args) {
    command_count = command_count + 1;

    if (len(args) < 2) {
        d.reply(ctx, "❌ Usage: !role <user_id> <role_id>");
        return None;
    }

    let guild_id = ctx["guild_id"];
    let user_id = args[0];
    let role_id = args[1];

    try {
        d.add_role(guild_id, user_id, role_id);
        d.reply(ctx, "✅ Added role to user");
    } catch (e) {
        d.reply(ctx, "❌ Failed to add role: " + e);
    }
});

# メッセージ一括削除
d.command("clear", lambda(ctx, args) {
    command_count = command_count + 1;

    if (len(args) < 1) {
        d.reply(ctx, "❌ Usage: !clear <count>");
        return None;
    }

    let count = int(args[0]);
    let channel_id = ctx["channel_id"];

    if (count < 1 or count > 100) {
        d.reply(ctx, "❌ Count must be between 1 and 100");
        return None;
    }

    # メッセージ履歴を取得して削除
    let messages = d.get_messages(channel_id, count);
    for (msg in messages) {
        d.delete_message(msg["id"], channel_id);
    }

    d.reply(ctx, "🗑️ Deleted " + str(count) + " messages");
});

# ============================================================================
# チャンネル・サーバー管理
# ============================================================================

# チャンネル作成
d.command("createchannel", lambda(ctx, args) {
    command_count = command_count + 1;

    if (len(args) < 1) {
        d.reply(ctx, "❌ Usage: !createchannel <name>");
        return None;
    }

    let guild_id = ctx["guild_id"];
    let name = join("-", args);

    try {
        let channel = d.create_text_channel(guild_id, name);
        d.reply(ctx, "✅ Created channel: " + name);
    } catch (e) {
        d.reply(ctx, "❌ Failed to create channel: " + e);
    }
});

# ============================================================================
# Webhook機能
# ============================================================================

# Webhook経由でメッセージ送信
d.command("webhook", lambda(ctx, args) {
    command_count = command_count + 1;

    if (len(args) < 2) {
        d.reply(ctx, "❌ Usage: !webhook <webhook_url> <message>");
        return None;
    }

    let webhook_url = args[0];
    let message = join(" ", args[1:]);

    try {
        d.webhook_send(webhook_url, message);
        d.reply(ctx, "✅ Sent message via webhook");
    } catch (e) {
        d.reply(ctx, "❌ Failed to send webhook: " + e);
    }
});

# ============================================================================
# スラッシュコマンド
# ============================================================================

# /info スラッシュコマンド
d.slash_command("info", "Show bot information", lambda(interaction) {
    let info_msg = "🤖 Advanced Mumei Bot\n";
    info_msg = info_msg + "Messages: " + str(message_count) + "\n";
    info_msg = info_msg + "Commands: " + str(command_count);
    d.respond(interaction, info_msg);
});

# /poll スラッシュコマンド
d.slash_command("poll", "Create a poll", lambda(interaction) {
    # モーダルでpoll内容を入力
    let fields = [
        {"label": "Poll Question", "id": "question"},
        {"label": "Option 1", "id": "opt1"},
        {"label": "Option 2", "id": "opt2"}
    ];

    let modal_callback = lambda(modal_interaction, values) {
        let question = values["question"];
        let opt1 = values["opt1"];
        let opt2 = values["opt2"];

        let poll_msg = "📊 **Poll:** " + question + "\n";
        poll_msg = poll_msg + "1️⃣ " + opt1 + "\n";
        poll_msg = poll_msg + "2️⃣ " + opt2;

        d.respond(modal_interaction, poll_msg);
    };

    d.send_modal(interaction, "Create Poll", fields, modal_callback);
});

print("");
print("🚀 Advanced features loaded:");
print("   - Button interactions");
print("   - Select menus");
print("   - Moderation (kick, role, clear)");
print("   - Channel management");
print("   - Webhooks");
print("   - Slash commands with modals");
print("");

# Botを起動
let token = env("DISCORD_TOKEN");

if (token == None or token == "") {
    print("❌ Error: DISCORD_TOKEN not set");
} else {
    print("🔑 Starting advanced bot...");
    d.run(token);
}
