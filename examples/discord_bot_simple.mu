# Mumei言語で作るシンプルなDiscord Bot
# 使い方: mumei discord_bot_simple.mu

print("=== Mumei Discord Bot ===");
print("Setting up Discord bot...");

# Botを作成（コマンドプレフィックスは "!"）
discord_create_bot("!");

# !helloコマンド - 挨拶を返す
fun cmd_hello(ctx) {
    return "Hello! I'm a bot written in Mumei!";
}

# !pingコマンド - Pong!を返す
fun cmd_ping(ctx) {
    return "Pong!";
}

# !addコマンド - 2つの数を足す
fun cmd_add(ctx, a, b) {
    let num_a = int(a);
    let num_b = int(b);
    let result = num_a + num_b;
    return str(num_a) + " + " + str(num_b) + " = " + str(result);
}

# !echoコマンド - メッセージをそのまま返す
fun cmd_echo(ctx, message) {
    return "Echo: " + str(message);
}

# コマンドを登録
discord_command("hello", cmd_hello);
discord_command("ping", cmd_ping);
discord_command("add", cmd_add);
discord_command("echo", cmd_echo);

print("Commands registered:");
print("  !hello - Say hello");
print("  !ping - Pong!");
print("  !add <a> <b> - Add two numbers");
print("  !echo <message> - Echo a message");
print("");

# BOT TOKENを環境変数から取得
let token = env("DISCORD_BOT_TOKEN");

if (token == none) {
    print("Error: DISCORD_BOT_TOKEN environment variable not set!");
    print("");
    print("Please set your Discord bot token:");
    print("  Linux/macOS:");
    print("    export DISCORD_BOT_TOKEN='your_token_here'");
    print("    mumei discord_bot_simple.mu");
    print("");
    print("  Windows (PowerShell):");
    print("    $env:DISCORD_BOT_TOKEN='your_token_here'");
    print("    mumei discord_bot_simple.mu");
    print("");
    print("Get your bot token from: https://discord.com/developers/applications");
} else {
    print("Bot token loaded from environment variable!");
    print("Starting bot...");

    # Botを起動（このコマンドはブロッキング）
    discord_run(token);
}
