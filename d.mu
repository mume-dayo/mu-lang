# Discord Bot Module for Mumei Language
# シンプルで使いやすいDiscord Bot作成モジュール
# 使用例: import "d.mu" as d;

# ============================================================================
# Bot管理
# ============================================================================

# Botインスタンスを作成
# prefix: コマンドのプレフィックス（例: "!", "/"）
fun create_bot(prefix) {
    discord_create_bot(prefix);
    print("✅ Discord Bot created with prefix: " + prefix);
}

# Botを起動
# token: Discord Bot Token
fun run(token) {
    print("🚀 Starting Discord Bot...");
    discord_run(token);
}

# ============================================================================
# イベントハンドラー
# ============================================================================

# Bot起動時のイベント
# callback: fun() { ... }
fun on_ready(callback) {
    discord_on_ready(callback);
}

# メッセージ受信時のイベント
# callback: fun(message) { ... }
fun on_message(callback) {
    discord_on_message(callback);
}

# メンバー参加時のイベント
# callback: fun(member) { ... }
fun on_member_join(callback) {
    discord_on_member_join(callback);
}

# メンバー退出時のイベント
# callback: fun(member) { ... }
fun on_member_remove(callback) {
    discord_on_member_remove(callback);
}

# リアクション追加時のイベント
# callback: fun(reaction, user) { ... }
fun on_reaction_add(callback) {
    discord_on_reaction_add(callback);
}

# ============================================================================
# コマンド登録
# ============================================================================

# テキストコマンドを登録
# name: コマンド名
# callback: fun(ctx, args) { ... }
fun command(name, callback) {
    discord_command(name, callback);
    print("📝 Registered command: " + name);
}

# スラッシュコマンドを登録
# name: コマンド名
# description: コマンドの説明
# callback: fun(interaction) { ... }
fun slash_command(name, description, callback) {
    discord_slash_command(name, description, callback);
    print("⚡ Registered slash command: /" + name);
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
    return discord_send(ctx, content);
}

# Embedメッセージを送信
# channel_id: チャンネルID
# title: タイトル
# description: 説明文
# color: 色（16進数）
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
    return discord_delete_message(message_id, channel_id);
}

# メッセージを編集
# message_id: メッセージID
# channel_id: チャンネルID
# new_content: 新しい内容
fun edit_message(message_id, channel_id, new_content) {
    return discord_edit_message(message_id, channel_id, new_content);
}

# メッセージにリアクションを追加
# message_id: メッセージID
# channel_id: チャンネルID
# emoji: 絵文字
fun add_reaction(message_id, channel_id, emoji) {
    return discord_add_reaction(message_id, channel_id, emoji);
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

# ============================================================================
# ロール操作
# ============================================================================

# ロールを作成
# guild_id: サーバーID
# name: ロール名
# color: 色（16進数）
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
# インタラクション（ボタン・セレクトメニュー）
# ============================================================================

# ボタン付きメッセージを送信
# channel_id: チャンネルID
# content: メッセージ内容
# button_label: ボタンのラベル
# button_id: ボタンのID
# callback: fun(interaction) { ... }
fun send_button(channel_id, content, button_label, button_id, callback) {
    discord_send_button(channel_id, content, button_label, button_id, callback);
}

# セレクトメニュー付きメッセージを送信
# channel_id: チャンネルID
# content: メッセージ内容
# options: オプションのリスト [{"label": "...", "value": "..."}]
# callback: fun(interaction, selected) { ... }
fun send_select(channel_id, content, options, callback) {
    discord_send_select(channel_id, content, options, callback);
}

# Modalダイアログを送信
# interaction: インタラクション
# title: モーダルのタイトル
# fields: フィールドのリスト [{"label": "...", "id": "..."}]
# callback: fun(interaction, values) { ... }
fun send_modal(interaction, title, fields, callback) {
    discord_send_modal(interaction, title, fields, callback);
}

# インタラクションに返信
# interaction: インタラクション
# content: メッセージ内容
fun respond(interaction, content) {
    return discord_interaction_respond(interaction, content);
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
# embed_data: Embedデータ
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

# チャンネル情報を取得
# channel_id: チャンネルID
fun get_channel(channel_id) {
    return discord_get_channel(channel_id);
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

# Bot情報を出力
fun info() {
    print("=== Discord Bot Module (d.mu) ===");
    print("Version: 1.0");
    print("Features:");
    print("  - Event Handlers (on_ready, on_message, etc.)");
    print("  - Commands (command, slash_command)");
    print("  - Messages (send, reply, send_embed)");
    print("  - Channels (create, delete, rename)");
    print("  - Roles (create, add, remove)");
    print("  - Members (kick, ban, set_nickname)");
    print("  - Interactions (buttons, select menus, modals)");
    print("  - Webhooks (create, send)");
    print("==================================");
}

# ============================================================================
# エクスポート: このモジュールをインポートした時に表示
# ============================================================================
print("📦 Discord Module (d.mu) loaded successfully!");
print("   Use: import \"d.mu\" as d;");
