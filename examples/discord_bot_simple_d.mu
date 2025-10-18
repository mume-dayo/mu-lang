# シンプルなDiscord Bot（d.muモジュール使用）
# 使い方:
# 1. DISCORD_TOKEN環境変数にBotトークンを設定
# 2. mumei discord_bot_simple_d.mu

import "d.mu" as d;

print("=== Discord Bot with d.mu Module ===");

# Botを作成（プレフィックス: !）
d.create_bot("!");

# Bot起動時のイベント
d.on_ready(lambda() {
    print("✅ Bot is ready!");
    print("   Bot has connected to Discord");
});

# メッセージ受信時のイベント
d.on_message(lambda(message) {
    let content = message["content"];
    let author = message["author"];

    # Bot自身のメッセージは無視
    if (author["bot"]) {
        return None;
    }

    print("📨 Message from " + author["name"] + ": " + content);

    # "hello"を含むメッセージに反応
    if (find(lower(content), "hello") >= 0) {
        let channel_id = message["channel_id"];
        d.send(channel_id, "Hello, " + author["name"] + "! 👋");
    }
});

# メンバー参加時のイベント
d.on_member_join(lambda(member) {
    let name = member["name"];
    print("👋 New member joined: " + name);
});

# !pingコマンド
d.command("ping", lambda(ctx, args) {
    d.reply(ctx, "🏓 Pong!");
});

# !helloコマンド
d.command("hello", lambda(ctx, args) {
    let author = ctx["author"];
    d.reply(ctx, "Hello, " + author["name"] + "! Welcome to Mumei Bot 🎉");
});

# !infoコマンド
d.command("info", lambda(ctx, args) {
    let embed_data = {
        "title": "Bot Information",
        "description": "This is a Discord Bot made with Mumei Language!",
        "color": 0x00FF00
    };

    let channel_id = ctx["channel_id"];
    d.send_embed(channel_id, "Bot Info", "Powered by Mumei + d.mu module", 3447003);
});

# !echo コマンド（引数をエコー）
d.command("echo", lambda(ctx, args) {
    if (len(args) == 0) {
        d.reply(ctx, "Usage: !echo <message>");
    } else {
        let message = join(" ", args);
        d.reply(ctx, "Echo: " + message);
    }
});

# /hello スラッシュコマンド
d.slash_command("hello", "Say hello to the bot", lambda(interaction) {
    let user = interaction["user"];
    d.respond(interaction, "Hello, " + user["name"] + "! 👋");
});

# /ping スラッシュコマンド
d.slash_command("ping", "Check bot latency", lambda(interaction) {
    d.respond(interaction, "🏓 Pong! Bot is responsive!");
});

print("");
print("🔧 Commands registered:");
print("  Text Commands: !ping, !hello, !info, !echo");
print("  Slash Commands: /hello, /ping");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == None or token == "") {
    print("❌ Error: DISCORD_TOKEN environment variable not set");
    print("   Set it with: export DISCORD_TOKEN='your-bot-token'");
} else {
    print("🔑 Token found, starting bot...");
    d.run(token);
}
