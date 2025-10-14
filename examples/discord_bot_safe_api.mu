# Mumei言語で作る安全なAPI連携Discord Bot
# 例外処理を使用してエラーハンドリングを行う

print("=== Safe API Discord Bot with Exception Handling ===");
print("Setting up Discord bot with error handling...");

# Botを作成
discord_create_bot("!");

# !catコマンド - 例外処理付き
fun cmd_cat(ctx) {
    try {
        print("Fetching cat image...");
        let response = http_get("https://api.thecatapi.com/v1/images/search");
        let data = json_parse(response);
        return "🐱 " + str(data[0]["url"]);
    } catch (error) {
        print("Error fetching cat:", error);
        return "❌ 猫の画像を取得できませんでした: " + str(error);
    }
}

# !dogコマンド - 例外処理付き
fun cmd_dog(ctx) {
    try {
        print("Fetching dog image...");
        let response = http_get("https://dog.ceo/api/breeds/image/random");
        let data = json_parse(response);
        return "🐶 " + str(data["message"]);
    } catch (error) {
        print("Error fetching dog:", error);
        return "❌ 犬の画像を取得できませんでした: " + str(error);
    }
}

# !cryptoコマンド - 例外処理とバリデーション付き
fun cmd_crypto(ctx, coin) {
    try {
        # 入力検証
        if (coin == none) {
            throw "コイン名を指定してください。例: !crypto bitcoin";
        }

        print("Fetching crypto price for:", coin);
        let coin_id = str(coin);
        let url = "https://api.coingecko.com/api/v3/simple/price?ids=" + coin_id + "&vs_currencies=usd,jpy";

        let response = http_get(url);
        let data = json_parse(response);

        # データの存在確認
        if (data[coin_id] == none) {
            throw "コイン '" + coin_id + "' が見つかりません。bitcoin, ethereum などを試してください。";
        }

        let usd = data[coin_id]["usd"];
        let jpy = data[coin_id]["jpy"];

        return "💰 " + coin_id + ": $" + str(usd) + " USD / ¥" + str(jpy) + " JPY";
    } catch (error) {
        print("Error in crypto command:", error);
        return "❌ エラー: " + str(error);
    }
}

# !weatherコマンド - 複雑な例外処理
fun cmd_weather(ctx, city) {
    let api_key = none;

    try {
        # 入力検証
        if (city == none) {
            throw "都市名を指定してください。例: !weather Tokyo";
        }

        # APIキー取得
        api_key = env("OPENWEATHER_API_KEY");
        if (api_key == none) {
            throw "天気APIキーが設定されていません。";
        }

        print("Fetching weather for:", city);
        let url = "https://api.openweathermap.org/data/2.5/weather?q=" + str(city) + "&appid=" + str(api_key) + "&units=metric&lang=ja";

        let response = http_get(url);
        let data = json_parse(response);

        # レスポンス検証
        if (data["name"] == none) {
            throw "都市 '" + str(city) + "' が見つかりません。";
        }

        let city_name = data["name"];
        let temp = data["main"]["temp"];
        let description = data["weather"][0]["description"];

        return "🌤️ " + str(city_name) + "の天気: " + str(description) + ", 気温: " + str(temp) + "°C";
    } catch (error) {
        print("Error in weather command:", error);

        # エラーメッセージをユーザーフレンドリーに
        let error_msg = str(error);
        if (api_key == none) {
            return "❌ 天気機能を使用するには、OPENWEATHER_API_KEY 環境変数を設定してください。";
        }
        return "❌ 天気情報の取得に失敗しました: " + error_msg;
    }
}

# !divideコマンド - 計算の例外処理
fun cmd_divide(ctx, a, b) {
    try {
        # 入力検証
        if (a == none) {
            throw "割られる数を指定してください";
        }
        if (b == none) {
            throw "割る数を指定してください";
        }

        let num_a = int(a);
        let num_b = int(b);

        # ゼロ除算チェック
        if (num_b == 0) {
            throw "ゼロで割ることはできません！";
        }

        let result = num_a / num_b;
        return "📊 " + str(num_a) + " ÷ " + str(num_b) + " = " + str(result);
    } catch (error) {
        print("Error in divide command:", error);
        return "❌ 計算エラー: " + str(error);
    }
}

# !safeコマンド - try-catch-finallyの例
fun cmd_safe(ctx, action) {
    let start_time = get_time();

    try {
        print("Executing safe command with action:", action);

        if (action == "error") {
            throw "意図的なエラー";
        }
        if (action == "success") {
            return "✅ 成功しました！";
        }

        return "ℹ️ アクション '" + str(action) + "' を実行しました";
    } catch (error) {
        print("Error in safe command:", error);
        return "❌ エラーが発生しました: " + str(error);
    } finally {
        let end_time = get_time();
        let duration = end_time - start_time;
        print("Command completed in", duration, "seconds");
    }
}

# コマンドを登録
discord_command("cat", cmd_cat);
discord_command("dog", cmd_dog);
discord_command("crypto", cmd_crypto);
discord_command("weather", cmd_weather);
discord_command("divide", cmd_divide);
discord_command("safe", cmd_safe);

print("");
print("Commands registered:");
print("  !cat - Get random cat image (safe)");
print("  !dog - Get random dog image (safe)");
print("  !crypto <coin> - Get cryptocurrency price (with validation)");
print("  !weather <city> - Get weather information (requires API key)");
print("  !divide <a> <b> - Divide numbers safely");
print("  !safe <action> - Test exception handling");
print("");

# BOT TOKENを環境変数から取得
let token = none;

try {
    token = env("DISCORD_BOT_TOKEN");

    if (token == none) {
        throw "DISCORD_BOT_TOKEN environment variable not set!";
    }

    print("Bot token loaded successfully!");
    print("Starting bot with error handling...");
    print("");

    # Botを起動
    discord_run(token);
} catch (error) {
    print("");
    print("❌ Error:", error);
    print("");
    print("Please set your Discord bot token:");
    print("  export DISCORD_BOT_TOKEN='your_token_here'");
    print("");
    print("Optional: Set OpenWeatherMap API key for weather command:");
    print("  export OPENWEATHER_API_KEY='your_api_key_here'");
    print("  Get it from: https://openweathermap.org/api");
}
