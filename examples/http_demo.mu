# Mumei言語 HTTP Request デモ
# HTTPリクエストとJSON処理の基本的な使い方

print("=== Mumei HTTP Request Demo ===");
print("");

# 1. 基本的なGETリクエスト
print("1. Basic GET Request");
print("Fetching random dog image...");
let response = http_get("https://dog.ceo/api/breeds/image/random");
print("Response:", response);
print("");

# 2. JSONのパース
print("2. JSON Parse");
let data = json_parse(response);
print("Parsed data:", data);
print("Image URL:", data["message"]);
print("");

# 3. 別のAPIを試す - 猫の画像
print("3. Cat API Example");
let cat_response = http_get("https://api.thecatapi.com/v1/images/search");
let cat_data = json_parse(cat_response);
print("Cat image URL:", cat_data[0]["url"]);
print("");

# 4. 複雑なAPIレスポンス - プログラミングジョーク
print("4. Joke API Example");
let joke_response = http_get("https://official-joke-api.appspot.com/random_joke");
let joke_data = json_parse(joke_response);
print("Setup:", joke_data["setup"]);
print("Punchline:", joke_data["punchline"]);
print("");

# 5. 仮想通貨の価格取得
print("5. Cryptocurrency Price Example");
let crypto_response = http_get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd,jpy");
let crypto_data = json_parse(crypto_response);
print("Bitcoin: $", crypto_data["bitcoin"]["usd"], "USD");
print("Ethereum: $", crypto_data["ethereum"]["usd"], "USD");
print("");

# 6. 名言API
print("6. Quote API Example");
let quote_response = http_get("https://api.quotable.io/random");
let quote_data = json_parse(quote_response);
print("Quote:", quote_data["content"]);
print("Author:", quote_data["author"]);
print("");

# 7. JSONの作成とstringify
print("7. JSON Stringify Example");
let my_data = {
    "name": "Mumei",
    "version": "1.0",
    "features": ["interpreter", "discord", "http"]
};
# Note: Mumeiでは辞書リテラルはまだサポートされていないため、
# この例はコンセプトを示すものです

print("");
print("=== Demo Complete! ===");
print("Available HTTP functions:");
print("  - http_get(url) - Send GET request");
print("  - http_post(url, data) - Send POST request");
print("  - http_request(method, url, data) - Send custom request");
print("  - json_parse(string) - Parse JSON string");
print("  - json_stringify(object) - Convert to JSON string");
