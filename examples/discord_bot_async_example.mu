# Mumei言語でのAsync Discord Botの例
# 使い方: mumei discord_bot_async_example.mu
# 注意: Discord bot tokenを環境変数DISCORD_TOKENに設定してください

print("=== Mumei Discord Bot with Async/Await ===");
print("");

# Botトークンを環境変数から取得
let token = env("DISCORD_TOKEN");

if (token == none) {
    print("エラー: DISCORD_TOKENが設定されていません");
    print("使い方: export DISCORD_TOKEN='your-bot-token-here'");
    throw "Missing DISCORD_TOKEN environment variable";
}

# Botを作成
print("Discord Botを作成中...");
discord_create_bot("!");

# 非同期でデータを取得する関数
async fun fetch_weather(city) {
    print("  天気情報を取得中: " + city);
    sleep(2);  # APIリクエストをシミュレート
    return city + "の天気: 晴れ 25°C";
}

async fun fetch_news() {
    print("  ニュースを取得中...");
    sleep(3);  # APIリクエストをシミュレート
    return "最新ニュース: Mumei言語がリリースされました！";
}

async fun calculate_stats(data) {
    print("  統計情報を計算中...");
    sleep(1);
    let sum = 0;
    for (n in data) {
        sum = sum + n;
    }
    let avg = sum / len(data);
    return "合計: " + str(sum) + ", 平均: " + str(avg);
}

# !helloコマンド - シンプルな挨拶
discord_command("hello", lambda(ctx, *args) {
    "こんにちは！Mumei Botです 👋"
});

# !pingコマンド - レスポンスタイム測定
discord_command("ping", lambda(ctx, *args) {
    let start = get_time();
    let result = "Pong! 🏓";
    let end = get_time();
    let latency = int((end - start) * 1000);
    result + " (レスポンスタイム: " + str(latency) + "ms)"
});

# !weatherコマンド - 非同期で天気情報を取得
discord_command("weather", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !weather <都市名>";
    }
    let city = args[0];
    let task = fetch_weather(city);
    let weather_info = await task;
    weather_info
});

# !newsコマンド - 非同期でニュース取得
discord_command("news", lambda(ctx, *args) {
    let task = fetch_news();
    let news = await task;
    news
});

# !infoコマンド - 複数の情報を並行取得
discord_command("info", lambda(ctx, *args) {
    let weather_task = fetch_weather("東京");
    let news_task = fetch_news();

    # 並行実行で両方取得
    let weather = await weather_task;
    let news = await news_task;

    "📊 情報まとめ:\n" + weather + "\n" + news
});

# !statsコマンド - 統計情報を計算
discord_command("stats", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !stats <数値1> <数値2> ...";
    }

    # 引数を数値に変換
    let numbers = [];
    for (arg in args) {
        try {
            append(numbers, int(arg));
        } catch (e) {
            return "エラー: 数値のみを入力してください";
        }
    }

    let task = calculate_stats(numbers);
    let result = await task;
    "📈 統計結果: " + result
});

# !helpコマンド - コマンド一覧
discord_command("help", lambda(ctx, *args) {
    let help_text = "📖 利用可能なコマンド:\n";
    help_text = help_text + "!hello - 挨拶\n";
    help_text = help_text + "!ping - レスポンスタイム測定\n";
    help_text = help_text + "!weather <都市> - 天気情報取得\n";
    help_text = help_text + "!news - 最新ニュース\n";
    help_text = help_text + "!info - 複数情報を並行取得\n";
    help_text = help_text + "!stats <数値...> - 統計計算\n";
    help_text = help_text + "!calc <式> - 計算\n";
    help_text = help_text + "!help - このヘルプ";
    help_text
});

# !calcコマンド - 簡易計算機
discord_command("calc", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !calc <数値1> <演算子> <数値2>\n例: !calc 10 + 5";
    }

    if (len(args) != 3) {
        return "エラー: 引数は3つ必要です（数値 演算子 数値）";
    }

    try {
        let a = int(args[0]);
        let op = args[1];
        let b = int(args[2]);

        let result = 0;
        if (op == "+") {
            result = a + b;
        } elif (op == "-") {
            result = a - b;
        } elif (op == "*") {
            result = a * b;
        } elif (op == "/") {
            if (b == 0) {
                return "エラー: ゼロ除算はできません";
            }
            result = a / b;
        } else {
            return "エラー: サポートされていない演算子です (+, -, *, / のみ)";
        }

        "🔢 計算結果: " + str(a) + " " + op + " " + str(b) + " = " + str(result)
    } catch (e) {
        "エラー: 数値を入力してください"
    }
});

# Readyイベント - Bot起動時
discord_on_event("ready", lambda() {
    print("✅ Discord Bot が起動しました！");
    print("コマンド例:");
    print("  !hello - 挨拶");
    print("  !weather 東京 - 天気情報");
    print("  !news - ニュース");
    print("  !help - ヘルプ");
});

# Botを起動
print("Botを起動します...");
print("Ctrl+C で終了");
discord_run(token);
