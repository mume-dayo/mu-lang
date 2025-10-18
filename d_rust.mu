# Discord Bot Module for Mumei Language (Rust-based)
# 100% Rust実装 - Python版と同じ使い勝手
# 使用例: import "d_rust.mu" as d;

# ============================================================================
# グローバル変数（Botの状態管理）
# ============================================================================

let _bot_token = None;
let _bot_prefix = "!";
let _command_handlers = {};
let _event_handlers = {
    "ready": [],
    "message": []
};
let _is_running = False;
let _last_message_id = None;

# ============================================================================
# Bot管理
# ============================================================================

# Botインスタンスを作成
# prefix: コマンドのプレフィックス（例: "!", "/"）
fun create_bot(prefix) {
    _bot_prefix = prefix;
    print("✅ Discord Bot created with prefix: " + prefix);
}

# Botを起動（ポーリングベース）
# token: Discord Bot Token
fun run(token) {
    _bot_token = token;
    discord_set_token(token);
    _is_running = True;

    print("🚀 Starting Discord Bot (Rust-based)...");
    print("   Mode: REST API polling");
    print("   Prefix: " + _bot_prefix);

    # ready イベントを発火
    _trigger_event("ready", []);

    print("✅ Bot is ready!");
    print("");
    print("💡 Note: This is a REST API implementation.");
    print("   Use 'poll_messages(channel_id)' to check for new messages.");
    print("   Or set up webhooks for real-time events.");
    print("");
}

# メッセージをポーリング（手動でメッセージチェック）
# channel_id: チャンネルID
# limit: 取得数
fun poll_messages(channel_id, limit) {
    if (_bot_token == None) {
        print("❌ Bot not started. Call run(token) first.");
        return [];
    }

    let messages = discord_get_message_history(channel_id, limit);

    # 新しいメッセージのみ処理
    for (msg in messages) {
        let msg_id = msg["id"];

        # 最後に処理したメッセージより新しいか確認
        if (_last_message_id == None or msg_id != _last_message_id) {
            # message イベントを発火
            _trigger_event("message", [msg]);

            # コマンドチェック
            _process_command(msg);
        }
    }

    # 最新メッセージIDを保存
    if (len(messages) > 0) {
        _last_message_id = messages[0]["id"];
    }

    return messages;
}

# コマンド処理
fun _process_command(message) {
    let content = message["content"];

    # プレフィックスチェック
    if (!startswith(content, _bot_prefix)) {
        return None;
    }

    # コマンドとargsを分離
    let command_text = content[len(_bot_prefix):];
    let parts = split(command_text, " ");

    if (len(parts) == 0) {
        return None;
    }

    let command_name = parts[0];
    let args = parts[1:];

    # ハンドラーがあれば実行
    if (has_key(_command_handlers, command_name)) {
        let handler = _command_handlers[command_name];

        # コンテキストオブジェクト作成
        let ctx = {
            "message": message,
            "channel_id": message["channel_id"],
            "author": message["author"],
            "guild_id": message["guild_id"]
        };

        handler(ctx, args);
    }
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
            } else if (len(args) == 2) {
                handler(args[0], args[1]);
            }
        }
    }
}

# ============================================================================
# イベントハンドラー
# ============================================================================

# Bot起動時のイベント
# callback: fun() { ... }
fun on_ready(callback) {
    if (!has_key(_event_handlers, "ready")) {
        _event_handlers["ready"] = [];
    }
    _event_handlers["ready"] = _event_handlers["ready"] + [callback];
}

# メッセージ受信時のイベント
# callback: fun(message) { ... }
fun on_message(callback) {
    if (!has_key(_event_handlers, "message")) {
        _event_handlers["message"] = [];
    }
    _event_handlers["message"] = _event_handlers["message"] + [callback];
}

# ============================================================================
# コマンド登録
# ============================================================================

# テキストコマンドを登録
# name: コマンド名
# callback: fun(ctx, args) { ... }
fun command(name, callback) {
    _command_handlers[name] = callback;
    print("📝 Registered command: " + _bot_prefix + name);
}

# ============================================================================
# メッセージ送信
# ============================================================================

# チャンネルにメッセージを送信
# channel_id: チャンネルID
# content: メッセージ内容
fun send(channel_id, content) {
    return discord_send_message(channel_id, content);
}

# 返信メッセージを送信（コンテキスト経由）
# ctx: コマンドコンテキスト
# content: メッセージ内容
fun reply(ctx, content) {
    let channel_id = ctx["channel_id"];
    return send(channel_id, content);
}

# Embedメッセージを送信
# channel_id: チャンネルID
# title: タイトル
# description: 説明文
# color: 色（10進数）
fun send_embed(channel_id, title, description, color) {
    return discord_send_embed(channel_id, title, description, color);
}

# ============================================================================
# メッセージ操作
# ============================================================================

# メッセージを削除
# message_id: メッセージID
# channel_id: チャンネルID
fun delete_message(message_id, channel_id) {
    return discord_delete_message(channel_id, message_id);
}

# メッセージを編集
# message_id: メッセージID
# channel_id: チャンネルID
# new_content: 新しい内容
fun edit_message(message_id, channel_id, new_content) {
    return discord_edit_message(channel_id, message_id, new_content);
}

# メッセージにリアクションを追加
# message_id: メッセージID
# channel_id: チャンネルID
# emoji: 絵文字
fun add_reaction(message_id, channel_id, emoji) {
    return discord_add_reaction(channel_id, message_id, emoji);
}

# ============================================================================
# チャンネル操作
# ============================================================================

# テキストチャンネルを作成
# guild_id: サーバーID
# name: チャンネル名
fun create_text_channel(guild_id, name) {
    return discord_create_text_channel(guild_id, name);
}

# ボイスチャンネルを作成
# guild_id: サーバーID
# name: チャンネル名
fun create_voice_channel(guild_id, name) {
    return discord_create_voice_channel(guild_id, name);
}

# チャンネルを削除
# channel_id: チャンネルID
fun delete_channel(channel_id) {
    return discord_delete_channel(channel_id);
}

# チャンネルをリネーム
# channel_id: チャンネルID
# new_name: 新しい名前
fun rename_channel(channel_id, new_name) {
    return discord_rename_channel(channel_id, new_name);
}

# チャンネル情報を取得
# channel_id: チャンネルID
fun get_channel(channel_id) {
    return discord_get_channel(channel_id);
}

# ============================================================================
# ロール操作
# ============================================================================

# ロールを作成
# guild_id: サーバーID
# name: ロール名
# color: 色（10進数）
fun create_role(guild_id, name, color) {
    return discord_create_role(guild_id, name, color);
}

# メンバーにロールを付与
# guild_id: サーバーID
# user_id: ユーザーID
# role_id: ロールID
fun add_role(guild_id, user_id, role_id) {
    return discord_add_role_to_member(guild_id, user_id, role_id);
}

# メンバーからロールを削除
# guild_id: サーバーID
# user_id: ユーザーID
# role_id: ロールID
fun remove_role(guild_id, user_id, role_id) {
    return discord_remove_role_from_member(guild_id, user_id, role_id);
}

# ============================================================================
# メンバー操作
# ============================================================================

# メンバーをキック
# guild_id: サーバーID
# user_id: ユーザーID
# reason: 理由
fun kick(guild_id, user_id, reason) {
    return discord_kick_member(guild_id, user_id, reason);
}

# メンバーをBAN
# guild_id: サーバーID
# user_id: ユーザーID
# reason: 理由
fun ban(guild_id, user_id, reason) {
    return discord_ban_member(guild_id, user_id, reason);
}

# メンバーのニックネームを変更
# guild_id: サーバーID
# user_id: ユーザーID
# nickname: 新しいニックネーム
fun set_nickname(guild_id, user_id, nickname) {
    return discord_set_nickname(guild_id, user_id, nickname);
}

# ============================================================================
# Webhook
# ============================================================================

# Webhookを作成
# channel_id: チャンネルID
# name: Webhook名
fun create_webhook(channel_id, name) {
    return discord_create_webhook(channel_id, name);
}

# WebhookでメッセージをPOST
# webhook_url: Webhook URL
# content: メッセージ内容
fun webhook_send(webhook_url, content) {
    return discord_webhook_post(webhook_url, content);
}

# Webhook Embedメッセージを送信
# webhook_url: Webhook URL
# embed_data: Embedデータ（JSON文字列）
fun webhook_send_embed(webhook_url, embed_data) {
    return discord_webhook_post_embed(webhook_url, embed_data);
}

# ============================================================================
# ユーティリティ
# ============================================================================

# ユーザー情報を取得
# user_id: ユーザーID
fun get_user(user_id) {
    return discord_get_user(user_id);
}

# サーバー情報を取得
# guild_id: サーバーID
fun get_guild(guild_id) {
    return discord_get_guild(guild_id);
}

# メッセージ履歴を取得
# channel_id: チャンネルID
# limit: 取得数
fun get_messages(channel_id, limit) {
    return discord_get_message_history(channel_id, limit);
}

# ============================================================================
# HTTP ユーティリティ
# ============================================================================

# HTTP GETリクエスト
# url: URL
# headers: ヘッダー（dict、オプション）
fun http_get_req(url, headers) {
    return http_get(url, headers);
}

# HTTP POSTリクエスト（JSON）
# url: URL
# json_body: JSONボディ（文字列）
# headers: ヘッダー（dict、オプション）
fun http_post_req(url, json_body, headers) {
    return http_post_json(url, json_body, headers);
}

# JSON文字列をパース
# json_str: JSON文字列
fun parse_json(json_str) {
    return json_parse(json_str);
}

# オブジェクトをJSON文字列に変換
# obj: Pythonオブジェクト
fun to_json(obj) {
    return json_stringify(obj);
}

# ============================================================================
# カラーヘルパー
# ============================================================================

# RGB値から色を生成（10進数）
fun rgb_to_color(r, g, b) {
    return r * 65536 + g * 256 + b;
}

# カラー定数
let COLOR_RED = 16711680;        # 0xFF0000
let COLOR_GREEN = 65280;         # 0x00FF00
let COLOR_BLUE = 255;            # 0x0000FF
let COLOR_YELLOW = 16776960;     # 0xFFFF00
let COLOR_PURPLE = 8388736;      # 0x800080
let COLOR_ORANGE = 16753920;     # 0xFFA500
let COLOR_CYAN = 65535;          # 0x00FFFF
let COLOR_MAGENTA = 16711935;    # 0xFF00FF
let COLOR_BLACK = 0;             # 0x000000
let COLOR_WHITE = 16777215;      # 0xFFFFFF
let COLOR_GRAY = 8421504;        # 0x808080
let COLOR_GOLD = 16766720;       # 0xFFD700

# ============================================================================
# ポーリングループヘルパー
# ============================================================================

# メッセージポーリングループを開始（シンプル版）
# channel_id: 監視するチャンネルID
# interval: ポーリング間隔（秒）
fun start_polling(channel_id, interval) {
    print("🔄 Starting message polling...");
    print("   Channel: " + channel_id);
    print("   Interval: " + str(interval) + " seconds");
    print("");
    print("💡 Press Ctrl+C to stop");
    print("");

    while (True) {
        try {
            poll_messages(channel_id, 10);
            sleep(interval);
        } catch (e) {
            print("❌ Polling error: " + str(e));
            sleep(interval);
        }
    }
}

# ============================================================================
# モジュール情報
# ============================================================================

fun info() {
    print("=== Discord Bot Module (Rust-based) ===");
    print("Version: 2.0 (Python-compatible API)");
    print("Implementation: 100% Rust (no Python deps)");
    print("");
    print("Features:");
    print("  ✅ REST API client (reqwest)");
    print("  ✅ Command registration");
    print("  ✅ Event handlers (polling-based)");
    print("  ✅ Message operations");
    print("  ✅ Channel/Role/Member management");
    print("  ✅ Webhooks");
    print("  ✅ JSON utilities");
    print("");
    print("Usage:");
    print("  import \"d_rust.mu\" as d;");
    print("  d.create_bot(\"!\");");
    print("  d.command(\"ping\", lambda(ctx, args) { d.reply(ctx, \"Pong!\"); });");
    print("  d.on_ready(lambda() { print(\"Ready!\"); });");
    print("  d.run(env(\"DISCORD_TOKEN\"));");
    print("  d.start_polling(channel_id, 5);  # Poll every 5 seconds");
    print("");
    print("🚀 High-performance Rust implementation");
    print("=========================================");
}

# ============================================================================
# エクスポート
# ============================================================================

print("📦 Discord Rust Module (d_rust.mu) loaded!");
print("   100% Rust implementation - Python-compatible API");
print("   Use: import \"d_rust.mu\" as d;");
