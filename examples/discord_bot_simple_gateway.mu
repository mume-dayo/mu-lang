# シンプルなDiscord Bot (Gateway版)
# mm_discord.pyと同じAPIで100% Rust実装
# 使用例: mumei discord_bot_simple_gateway.mu

import "d_rust_full.mu" as d;

print("=== Simple Discord Bot (Gateway) ===");
print("");

# Bot作成
d.create_bot("!");

# イベントハンドラー
d.on_ready(lambda() {
    print("✅ Bot起動完了！");
});

d.on_message(lambda(msg) {
    # Bot自身のメッセージは無視
    if (has_key(msg["author"], "bot") and msg["author"]["bot"]) {
        return None;
    }

    print("[" + msg["author"]["username"] + "]: " + msg["content"]);
});

# テキストコマンド
d.command("ping", lambda(ctx, args) {
    d.reply(ctx, "Pong! 🏓");
});

d.command("hello", lambda(ctx, args) {
    d.reply(ctx, "Hello! 👋");
});

# スラッシュコマンド
d.set_application_id(env("DISCORD_APPLICATION_ID"));
d.slash_command("test", "テストコマンド", lambda(interaction) {
    d.respond(interaction, "スラッシュコマンド動作中！");
});

# Botを起動（mm_discord.pyのbot.run()と同じ動作）
# この関数は内部で無限ループを回し、プログラムをブロックする
let token = env("DISCORD_TOKEN");
if (token != None and token != "") {
    print("🚀 Starting bot...");
    d.run(token, 32767);  # ← ここでブロックされ、常時監視が始まる

    # ここは実行されない（run()がブロッキング）
} else {
    print("❌ DISCORD_TOKEN not set");
}
