# Discord Bot Module for Mumei Language (Rust-based, Python-free)
# 100% Rust実装 - Python依存なし
# 使用例: import "d_rust.mu" as d;

# ============================================================================
# 初期化
# ============================================================================

# Discord Botトークンを設定
# token: Discord Bot Token
fun set_token(token) {
    discord_set_token(token);
    print("🔑 Discord token set");
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

# Embedメッセージを送信
# channel_id: チャンネルID
# title: タイトル
# description: 説明文
# color: 色（10進数、例: 0xFF0000 = 16711680）
fun send_embed(channel_id, title, description, color) {
    return discord_send_embed(channel_id, title, description, color);
}

# ============================================================================
# メッセージ操作
# ============================================================================

# メッセージを削除
# channel_id: チャンネルID
# message_id: メッセージID
fun delete_message(channel_id, message_id) {
    return discord_delete_message(channel_id, message_id);
}

# メッセージを編集
# channel_id: チャンネルID
# message_id: メッセージID
# new_content: 新しい内容
fun edit_message(channel_id, message_id, new_content) {
    return discord_edit_message(channel_id, message_id, new_content);
}

# メッセージにリアクションを追加
# channel_id: チャンネルID
# message_id: メッセージID
# emoji: 絵文字（Unicode emoji または :emoji_name:）
fun add_reaction(channel_id, message_id, emoji) {
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
# reason: 理由（オプション）
fun kick(guild_id, user_id, reason) {
    return discord_kick_member(guild_id, user_id, reason);
}

# メンバーをBAN
# guild_id: サーバーID
# user_id: ユーザーID
# reason: 理由（オプション）
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
# embed_json: Embedデータ（JSON文字列）
fun webhook_send_embed(webhook_url, embed_json) {
    return discord_webhook_post_embed(webhook_url, embed_json);
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
# limit: 取得数（最大100）
fun get_messages(channel_id, limit) {
    return discord_get_message_history(channel_id, limit);
}

# ============================================================================
# HTTP ユーティリティ（汎用）
# ============================================================================

# HTTP GETリクエスト
# url: URL
# headers: ヘッダー（dict、オプション）
fun http_get(url, headers) {
    return http_get(url, headers);
}

# HTTP POSTリクエスト（JSON）
# url: URL
# json_body: JSONボディ（文字列）
# headers: ヘッダー（dict、オプション）
fun http_post(url, json_body, headers) {
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
# モジュール情報
# ============================================================================

fun info() {
    print("=== Discord Bot Module (Rust-based) ===");
    print("Version: 2.0 (Pure Rust implementation)");
    print("No Python dependencies!");
    print("");
    print("Features:");
    print("  - HTTP/REST API client (reqwest)");
    print("  - Discord REST API wrapper");
    print("  - Message operations");
    print("  - Channel management");
    print("  - Role management");
    print("  - Member moderation");
    print("  - Webhooks");
    print("  - JSON utilities");
    print("");
    print("🚀 High-performance Rust implementation");
    print("=========================================");
}

# ============================================================================
# カラーヘルパー（16進数→10進数変換）
# ============================================================================

fun rgb_to_color(r, g, b) {
    return r * 65536 + g * 256 + b;
}

fun hex_to_color(hex_str) {
    # 0xFFFFFF → 16777215
    # TODO: implement hex string parsing
    return 0;
}

# よく使う色の定数
let COLOR_RED = 16711680;        # 0xFF0000
let COLOR_GREEN = 65280;         # 0x00FF00
let COLOR_BLUE = 255;            # 0x0000FF
let COLOR_YELLOW = 16776960;     # 0xFFFF00
let COLOR_PURPLE = 8388736;      # 0x800080
let COLOR_ORANGE = 16753920;     # 0xFFA500
let COLOR_BLACK = 0;             # 0x000000
let COLOR_WHITE = 16777215;      # 0xFFFFFF

# ============================================================================
# エクスポート
# ============================================================================

print("📦 Discord Rust Module (d_rust.mu) loaded!");
print("   100% Rust implementation - No Python dependencies");
print("   Use: import \"d_rust.mu\" as d;");
