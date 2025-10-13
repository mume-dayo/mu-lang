# Mumei言語で作る高度なDiscord Bot
# イベントハンドラやより複雑なコマンドの例

print("=== Advanced Mumei Discord Bot ===");

# Botを作成
discord_create_bot("!");

# カウンター変数（メッセージ数をカウント）
let message_count = 0;
let command_count = 0;

# ready イベント - Bot起動時
fun on_ready(user) {
    print("Bot is ready!");
    print("Logged in as:", str(user));
}

# message イベント - メッセージ受信時
fun on_message(message) {
    message_count = message_count + 1;
    # メッセージ内容をコンソールに表示（デバッグ用）
    # print("Message received:", str(message));
}

# !statsコマンド - 統計情報を表示
fun cmd_stats(ctx) {
    command_count = command_count + 1;
    return "Stats:\nMessages seen: " + str(message_count) + "\nCommands executed: " + str(command_count);
}

# !rollコマンド - サイコロを振る
fun cmd_roll(ctx, sides) {
    command_count = command_count + 1;
    let num_sides = int(sides);

    # 簡易的な乱数生成（実際にはPythonのrandomを使う方が良い）
    # ここでは 1 から sides までの範囲でランダムな数を返す想定
    let result = (message_count % num_sides) + 1;

    return "Rolling a " + str(num_sides) + "-sided die... You got: " + str(result);
}

# !reverseコマンド - 文字列を逆順にする
fun cmd_reverse(ctx, text) {
    command_count = command_count + 1;
    # Mumeiには文字列の逆順機能がないので、メッセージで説明
    return "Reverse of '" + str(text) + "' would be here (string reversal not yet implemented in Mumei)";
}

# !calcコマンド - 簡単な計算
fun cmd_calc(ctx, operation, a, b) {
    command_count = command_count + 1;
    let num_a = int(a);
    let num_b = int(b);
    let result = 0;
    let op_str = str(operation);

    if (op_str == "add" or op_str == "+") {
        result = num_a + num_b;
        return str(num_a) + " + " + str(num_b) + " = " + str(result);
    } else {
        if (op_str == "sub" or op_str == "-") {
            result = num_a - num_b;
            return str(num_a) + " - " + str(num_b) + " = " + str(result);
        } else {
            if (op_str == "mul" or op_str == "*") {
                result = num_a * num_b;
                return str(num_a) + " * " + str(num_b) + " = " + str(result);
            } else {
                if (op_str == "div" or op_str == "/") {
                    if (num_b == 0) {
                        return "Error: Division by zero!";
                    }
                    result = num_a / num_b;
                    return str(num_a) + " / " + str(num_b) + " = " + str(result);
                } else {
                    return "Unknown operation: " + op_str + "\nSupported: add, sub, mul, div";
                }
            }
        }
    }
}

# !helpコマンド - ヘルプを表示
fun cmd_help(ctx) {
    command_count = command_count + 1;
    let help_text = "Available Commands:\n";
    help_text = help_text + "!help - Show this help message\n";
    help_text = help_text + "!stats - Show bot statistics\n";
    help_text = help_text + "!roll <sides> - Roll a die with specified sides\n";
    help_text = help_text + "!calc <op> <a> <b> - Calculate (add/sub/mul/div)\n";
    help_text = help_text + "!reverse <text> - Reverse text (WIP)\n";
    help_text = help_text + "\nBot created with Mumei Language!";
    return help_text;
}

# イベントハンドラを登録
discord_on_event("ready", on_ready);
discord_on_event("message", on_message);

# コマンドを登録
discord_command("stats", cmd_stats);
discord_command("roll", cmd_roll);
discord_command("reverse", cmd_reverse);
discord_command("calc", cmd_calc);
discord_command("help", cmd_help);

print("Advanced bot setup complete!");
print("");
print("Available commands:");
print("  !help - Show help");
print("  !stats - Show statistics");
print("  !roll <sides> - Roll a die");
print("  !calc <op> <a> <b> - Calculate");
print("  !reverse <text> - Reverse text");
print("");

# BOT TOKENを環境変数から取得
let token = env("DISCORD_BOT_TOKEN");

if (token == none) {
    print("Error: DISCORD_BOT_TOKEN environment variable not set!");
    print("");
    print("To start the bot:");
    print("1. Get your bot token from Discord Developer Portal");
    print("2. Set the environment variable:");
    print("   export DISCORD_BOT_TOKEN='your_token_here'");
    print("3. Run this script again");
    print("");
    print("Setup complete (token not set)");
} else {
    print("Bot token loaded successfully!");
    print("Starting Discord bot...");
    print("");

    # Botを起動
    discord_run(token);
}
