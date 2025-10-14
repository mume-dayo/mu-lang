# Mumei言語で作るAPI連携Discord Bot
# HTTPリクエストを使って外部APIからデータを取得

print("=== Mumei Discord Bot with HTTP Requests ===");
print("Setting up Discord bot with API integration...");

# Botを作成
discord_create_bot("!");

# !weatherコマンド - 天気情報を取得（例：OpenWeatherMap API）
fun cmd_weather(ctx, city) {
    print("Fetching weather for: " + str(city));

    # 実際のAPIキーを使う場合は環境変数から取得
    let api_key = env("OPENWEATHER_API_KEY");

    if (api_key == none) {
        return "天気APIキーが設定されていません。OpenWeatherMapのAPIキーを OPENWEATHER_API_KEY 環境変数に設定してください。";
    }

    # APIリクエストを送信
    let url = "https://api.openweathermap.org/data/2.5/weather?q=" + str(city) + "&appid=" + str(api_key) + "&units=metric&lang=ja";

    let response = http_get(url);
    let data = json_parse(response);

    # データを整形して返す
    let city_name = data["name"];
    let temp = data["main"]["temp"];
    let description = data["weather"][0]["description"];

    return "🌤️ " + str(city_name) + "の天気: " + str(description) + ", 気温: " + str(temp) + "°C";
}

# !catコマンド - ランダムな猫の画像を取得
fun cmd_cat(ctx) {
    print("Fetching random cat image...");

    # The Cat APIから画像を取得
    let response = http_get("https://api.thecatapi.com/v1/images/search");
    let data = json_parse(response);

    # 画像URLを返す
    return "🐱 " + str(data[0]["url"]);
}

# !dogコマンド - ランダムな犬の画像を取得
fun cmd_dog(ctx) {
    print("Fetching random dog image...");

    let response = http_get("https://dog.ceo/api/breeds/image/random");
    let data = json_parse(response);

    return "🐶 " + str(data["message"]);
}

# !jokeコマンド - プログラミングジョークを取得
fun cmd_joke(ctx) {
    print("Fetching programming joke...");

    let response = http_get("https://official-joke-api.appspot.com/random_joke");
    let data = json_parse(response);

    let setup = data["setup"];
    let punchline = data["punchline"];

    return "😄 " + str(setup) + "\n" + str(punchline);
}

# !cryptoコマンド - 仮想通貨の価格を取得
fun cmd_crypto(ctx, coin) {
    print("Fetching crypto price for: " + str(coin));

    # CoinGecko APIから価格を取得（無料、APIキー不要）
    let coin_id = str(coin);  # bitcoin, ethereum, etc.
    let url = "https://api.coingecko.com/api/v3/simple/price?ids=" + coin_id + "&vs_currencies=usd,jpy";

    let response = http_get(url);
    let data = json_parse(response);

    if (data[coin_id] == none) {
        return "コイン '" + coin_id + "' が見つかりません。bitcoin, ethereum などを試してください。";
    }

    let usd = data[coin_id]["usd"];
    let jpy = data[coin_id]["jpy"];

    return "💰 " + coin_id + ": $" + str(usd) + " USD / ¥" + str(jpy) + " JPY";
}

# !quoteコマンド - ランダムな名言を取得
fun cmd_quote(ctx) {
    print("Fetching random quote...");

    let response = http_get("https://api.quotable.io/random");
    let data = json_parse(response);

    let content = data["content"];
    let author = data["author"];

    return "📜 \"" + str(content) + "\"\n- " + str(author);
}

# コマンドを登録
discord_command("weather", cmd_weather);
discord_command("cat", cmd_cat);
discord_command("dog", cmd_dog);
discord_command("joke", cmd_joke);
discord_command("crypto", cmd_crypto);
discord_command("quote", cmd_quote);

print("");
print("Commands registered:");
print("  !weather <city> - Get weather information");
print("  !cat - Get random cat image");
print("  !dog - Get random dog image");
print("  !joke - Get programming joke");
print("  !crypto <coin> - Get cryptocurrency price (e.g., bitcoin, ethereum)");
print("  !quote - Get random inspirational quote");
print("");

# BOT TOKENを環境変数から取得
let token = env("DISCORD_BOT_TOKEN");

if (token == none) {
    print("Error: DISCORD_BOT_TOKEN environment variable not set!");
    print("");
    print("Please set your Discord bot token:");
    print("  export DISCORD_BOT_TOKEN='your_token_here'");
    print("");
    print("Optional: Set OpenWeatherMap API key for weather command:");
    print("  export OPENWEATHER_API_KEY='your_api_key_here'");
    print("  Get it from: https://openweathermap.org/api");
} else {
    print("Bot token loaded!");
    print("Starting bot with API integration...");

    # Botを起動
    discord_run(token);
}
