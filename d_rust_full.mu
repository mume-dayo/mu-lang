# Discord Bot Module for Mumei Language (Rust Full-Featured)
# 100% Rust実装 - Gateway + REST API + UI Components
# 使用例: import "d_rust_full.mu" as d;

# ============================================================================
# グローバル変数
# ============================================================================

let _bot_token = None;
let _bot_prefix = "!";
let _application_id = None;
let _command_handlers = {};
let _interaction_handlers = {};
let _slash_commands = {};
let _event_handlers = {
    "ready": [],
    "message": [],
    "interaction": []
};
let _is_gateway_mode = True;  # True = Gateway (real-time), False = Polling

# ============================================================================
# Bot管理
# ============================================================================

# Botインスタンスを作成
# prefix: コマンドのプレフィックス（例: "!", "/"）
fun create_bot(prefix) {
    _bot_prefix = prefix;
    print("✅ Discord Bot created with prefix: " + prefix);
}

# アプリケーションIDを設定（スラッシュコマンド用）
# app_id: Discord Application ID
fun set_application_id(app_id) {
    _application_id = app_id;
    print("🔑 Application ID set");
}

# Botを起動（Gateway接続）
# token: Discord Bot Token
# intents: Gateway intents (デフォルト: 32767 = all intents)
fun run(token, intents) {
    _bot_token = token;
    discord_set_token(token);

    if (_is_gateway_mode) {
        print("🚀 Starting Discord Bot (Gateway mode)...");
        print("   Mode: WebSocket (real-time events)");
        print("   Prefix: " + _bot_prefix);

        # Gateway接続
        if (intents == None) {
            intents = 32767;  # All intents
        }
        gateway_connect(token, intents);

        # イベントハンドラーを登録
        gateway_on("ready", lambda() {
            print("📡 Bot is ready!");
            _trigger_event("ready", []);
        });

        gateway_on("message", lambda(message) {
            _trigger_event("message", [message]);
            _process_command(message);
        });

        gateway_on("interaction", lambda(interaction) {
            _trigger_event("interaction", [interaction]);
            _process_interaction(interaction);
        });

        print("✅ Gateway connected!");
        print("🔄 Bot is running... (Press Ctrl+C to stop)");
        print("");

        # mm_discord.pyのbot.run()と同じように常時監視
        # Gatewayはバックグラウンドで動作するため、メインスレッドを維持する必要がある
        _keep_alive();
    } else {
        print("🚀 Starting Discord Bot (Polling mode)...");
        print("   Mode: REST API polling");
        print("   Use start_polling(channel_id) to begin");
    }
}

# Bot常時監視ループ（mm_discord.pyのbot.run()相当）
# Gatewayがバックグラウンドで動作している間、メインスレッドを維持
fun _keep_alive() {
    print("💤 Entering event loop (keeping bot alive)...");

    # 無限ループでBotを稼働し続ける
    # mm_discord.pyの_bot.run()も内部的にasyncioイベントループを回している
    while (True) {
        sleep(1);  # 1秒ごとにチェック（CPU負荷を抑える）
    }
}

# ============================================================================
# イベントハンドラー
# ============================================================================

# Bot起動時のイベント
fun on_ready(callback) {
    if (!has_key(_event_handlers, "ready")) {
        _event_handlers["ready"] = [];
    }
    _event_handlers["ready"] = _event_handlers["ready"] + [callback];
}

# メッセージ受信時のイベント
fun on_message(callback) {
    if (!has_key(_event_handlers, "message")) {
        _event_handlers["message"] = [];
    }
    _event_handlers["message"] = _event_handlers["message"] + [callback];
}

# インタラクション受信時のイベント（ボタン、スラッシュコマンドなど）
fun on_interaction(callback) {
    if (!has_key(_event_handlers, "interaction")) {
        _event_handlers["interaction"] = [];
    }
    _event_handlers["interaction"] = _event_handlers["interaction"] + [callback];
}

# イベントトリガー
fun _trigger_event(event_name, args) {
    if (has_key(_event_handlers, event_name)) {
        let handlers = _event_handlers[event_name];
        for (handler in handlers) {
            if (len(args) == 0) {
                handler();
            } else if (len(args) == 1) {
                handler(args[0]);
            }
        }
    }
}

# ============================================================================
# コマンド登録
# ============================================================================

# テキストコマンドを登録
fun command(name, callback) {
    _command_handlers[name] = callback;
    print("📝 Registered text command: " + _bot_prefix + name);
}

# スラッシュコマンドを登録
# name: コマンド名
# description: コマンドの説明
# callback: fun(interaction) { ... }
fun slash_command(name, description, callback) {
    _slash_commands[name] = {
        "description": description,
        "callback": callback
    };

    # サーバーに登録
    if (_application_id != None) {
        gateway_register_slash_command(_application_id, name, description, None);
        print("⚡ Registered slash command: /" + name);
    } else {
        print("⚠️  Slash command registered locally: /" + name);
        print("   Call set_application_id() to register on Discord");
    }
}

# コマンド処理
fun _process_command(message) {
    let content = message["content"];

    if (!startswith(content, _bot_prefix)) {
        return None;
    }

    let command_text = content[len(_bot_prefix):];
    let parts = split(command_text, " ");

    if (len(parts) == 0) {
        return None;
    }

    let command_name = parts[0];
    let args = parts[1:];

    if (has_key(_command_handlers, command_name)) {
        let handler = _command_handlers[command_name];
        let ctx = {
            "message": message,
            "channel_id": message["channel_id"],
            "author": message["author"],
            "guild_id": message["guild_id"]
        };
        handler(ctx, args);
    }
}

# インタラクション処理
fun _process_interaction(interaction) {
    let custom_id = interaction["data"]["custom_id"];

    if (has_key(_interaction_handlers, custom_id)) {
        let handler = _interaction_handlers[custom_id];
        handler(interaction);
    }

    # スラッシュコマンド
    if (interaction["type"] == 2) {  # APPLICATION_COMMAND
        let command_name = interaction["data"]["name"];
        if (has_key(_slash_commands, command_name)) {
            let cmd = _slash_commands[command_name];
            cmd["callback"](interaction);
        }
    }
}

# ============================================================================
# メッセージ送信
# ============================================================================

# チャンネルにメッセージを送信
fun send(channel_id, content) {
    return discord_send_message(channel_id, content);
}

# 返信（コンテキスト経由）
fun reply(ctx, content) {
    return send(ctx["channel_id"], content);
}

# Embed送信
fun send_embed(channel_id, title, description, color) {
    return discord_send_embed(channel_id, title, description, color);
}

# インタラクションに返信
fun respond(interaction, content) {
    let interaction_id = interaction["id"];
    let interaction_token = interaction["token"];
    return gateway_interaction_respond(interaction_id, interaction_token, content);
}

# ============================================================================
# UI Components (Buttons, Select Menus)
# ============================================================================

# ボタン付きメッセージを送信
# channel_id: チャンネルID
# content: メッセージ内容
# button_label: ボタンのラベル
# button_id: ボタンのカスタムID
# callback: fun(interaction) { ... }
# style: ボタンのスタイル (1=Blue, 2=Gray, 3=Green, 4=Red)
fun send_button(channel_id, content, button_label, button_id, callback, style) {
    if (style == None) {
        style = 1;  # Default: Blue
    }

    # コールバックを登録
    _interaction_handlers[button_id] = callback;

    # ボタン送信
    return gateway_send_button(channel_id, content, button_label, button_id, style);
}

# セレクトメニュー付きメッセージを送信
# channel_id: チャンネルID
# content: メッセージ内容
# custom_id: カスタムID
# options: オプションリスト [{"label": "...", "value": "..."}]
# callback: fun(interaction) { ... }
fun send_select(channel_id, content, custom_id, options, callback) {
    # コールバックを登録
    _interaction_handlers[custom_id] = callback;

    # オプションを(label, value)ペアに変換
    let option_pairs = [];
    for (opt in options) {
        option_pairs = option_pairs + [(opt["label"], opt["value"])];
    }

    return gateway_send_select(channel_id, content, custom_id, option_pairs);
}

# ============================================================================
# チャンネル・ロール・メンバー操作（REST API）
# ============================================================================

fun create_text_channel(guild_id, name) {
    return discord_create_text_channel(guild_id, name);
}

fun create_voice_channel(guild_id, name) {
    return discord_create_voice_channel(guild_id, name);
}

fun delete_channel(channel_id) {
    return discord_delete_channel(channel_id);
}

fun rename_channel(channel_id, new_name) {
    return discord_rename_channel(channel_id, new_name);
}

fun get_channel(channel_id) {
    return discord_get_channel(channel_id);
}

fun create_role(guild_id, name, color) {
    return discord_create_role(guild_id, name, color);
}

fun add_role(guild_id, user_id, role_id) {
    return discord_add_role_to_member(guild_id, user_id, role_id);
}

fun remove_role(guild_id, user_id, role_id) {
    return discord_remove_role_from_member(guild_id, user_id, role_id);
}

fun kick(guild_id, user_id, reason) {
    return discord_kick_member(guild_id, user_id, reason);
}

fun ban(guild_id, user_id, reason) {
    return discord_ban_member(guild_id, user_id, reason);
}

fun set_nickname(guild_id, user_id, nickname) {
    return discord_set_nickname(guild_id, user_id, nickname);
}

fun delete_message(message_id, channel_id) {
    return discord_delete_message(channel_id, message_id);
}

fun edit_message(message_id, channel_id, new_content) {
    return discord_edit_message(channel_id, message_id, new_content);
}

fun add_reaction(message_id, channel_id, emoji) {
    return discord_add_reaction(channel_id, message_id, emoji);
}

# ============================================================================
# Webhook
# ============================================================================

fun create_webhook(channel_id, name) {
    return discord_create_webhook(channel_id, name);
}

fun webhook_send(webhook_url, content) {
    return discord_webhook_post(webhook_url, content);
}

fun webhook_send_embed(webhook_url, embed_data) {
    return discord_webhook_post_embed(webhook_url, embed_data);
}

# ============================================================================
# ユーティリティ
# ============================================================================

fun get_user(user_id) {
    return discord_get_user(user_id);
}

fun get_guild(guild_id) {
    return discord_get_guild(guild_id);
}

fun get_messages(channel_id, limit) {
    return discord_get_message_history(channel_id, limit);
}

# ============================================================================
# カラー定数
# ============================================================================

fun rgb_to_color(r, g, b) {
    return r * 65536 + g * 256 + b;
}

let COLOR_RED = 16711680;
let COLOR_GREEN = 65280;
let COLOR_BLUE = 255;
let COLOR_YELLOW = 16776960;
let COLOR_PURPLE = 8388736;
let COLOR_ORANGE = 16753920;
let COLOR_CYAN = 65535;
let COLOR_MAGENTA = 16711935;
let COLOR_BLACK = 0;
let COLOR_WHITE = 16777215;
let COLOR_GRAY = 8421504;
let COLOR_GOLD = 16766720;

# ボタンスタイル定数
let BUTTON_PRIMARY = 1;    # 青
let BUTTON_SECONDARY = 2;  # グレー
let BUTTON_SUCCESS = 3;    # 緑
let BUTTON_DANGER = 4;     # 赤
let BUTTON_LINK = 5;       # リンク

# ============================================================================
# モジュール情報
# ============================================================================

fun info() {
    print("=== Discord Bot Module (Rust Full-Featured) ===");
    print("Version: 3.0 (Gateway + REST + UI)");
    print("Implementation: 100% Rust");
    print("");
    print("Features:");
    print("  ✅ WebSocket Gateway (real-time events)");
    print("  ✅ Text commands");
    print("  ✅ Slash commands");
    print("  ✅ Buttons");
    print("  ✅ Select menus");
    print("  ✅ Message operations");
    print("  ✅ Channel/Role/Member management");
    print("  ✅ Webhooks");
    print("");
    print("🚀 Full-featured Discord Bot in Rust!");
    print("================================================");
}

# ============================================================================
# エクスポート
# ============================================================================

print("📦 Discord Rust Full Module (d_rust_full.mu) loaded!");
print("   100% Rust - Gateway + REST API + UI Components");
print("   Use: import \"d_rust_full.mu\" as d;");
