# Discord Webhook Example
# Webhookを使用してDiscordにメッセージを送信する例

# === 基本的なWebhookメッセージ送信 ===
fun send_simple_webhook(webhook_url, message) {
    discord_send_webhook(webhook_url, message, none, none, none)
    print("Webhook送信完了:", message)
}

# === カスタム名前とアバターでWebhook送信 ===
fun send_custom_webhook(webhook_url, message, username, avatar_url) {
    discord_send_webhook(webhook_url, message, username, avatar_url, none)
    print("Webhookをカスタム設定で送信:", username)
}

# === EmbedつきWebhook送信 ===
fun send_webhook_with_embed(webhook_url) {
    let embed = discord_create_embed(
        "Webhook通知",
        "これはWebhookから送信されたEmbedメッセージです",
        0x3498db
    )

    discord_embed_add_field(embed, "機能", "Mumei言語から直接Webhook送信", false)
    discord_embed_add_field(embed, "利点", "ボットなしでメッセージ送信可能", false)
    discord_embed_set_footer(embed, "Powered by Mumei", none)

    discord_send_webhook(webhook_url, none, "Mumei Bot", none, embed)
    print("Embed付きWebhook送信完了")
}

# === 実行例 ===
# let webhook_url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"

# 基本的な送信
# send_simple_webhook(webhook_url, "Hello from Mumei!")

# カスタム名前とアバター
# send_custom_webhook(
#     webhook_url,
#     "カスタマイズされたメッセージ",
#     "Mumei Bot",
#     "https://example.com/avatar.png"
# )

# Embed付き送信
# send_webhook_with_embed(webhook_url)

print("Webhook example loaded")
print("使い方:")
print("1. webhook_url変数にWebhook URLを設定")
print("2. send_simple_webhook()などの関数を呼び出し")
