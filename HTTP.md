# HTTP Request機能

Mumei言語でHTTPリクエストを送信し、外部APIと連携する方法を説明します。

## 概要

Mumeiには以下のHTTP関連の組み込み関数が用意されています：

- `http_get(url)` - GETリクエストを送信
- `http_post(url, data, headers)` - POSTリクエストを送信
- `http_request(method, url, data, headers)` - カスタムHTTPリクエスト
- `json_parse(string)` - JSON文字列をパース
- `json_stringify(object)` - オブジェクトをJSON文字列に変換

## インストール

HTTP機能は標準ライブラリの `urllib` を使用しているため、追加のインストールは不要です。

## 基本的な使い方

### 1. GETリクエスト

```mu
# シンプルなGETリクエスト
let response = http_get("https://api.example.com/data");
print(response);
```

### 2. JSONのパース

```mu
# APIレスポンスをパース
let response = http_get("https://dog.ceo/api/breeds/image/random");
let data = json_parse(response);
print("Image URL:", data["message"]);
```

### 3. POSTリクエスト

```mu
# POSTリクエストでデータを送信
# Note: 辞書リテラルは将来のバージョンで実装予定
let response = http_post("https://api.example.com/submit", "key=value");
```

## 実用例

### 天気情報を取得

```mu
let api_key = env("OPENWEATHER_API_KEY");
let city = "Tokyo";
let url = "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + api_key + "&units=metric";

let response = http_get(url);
let data = json_parse(response);

print("Temperature:", data["main"]["temp"], "°C");
print("Weather:", data["weather"][0]["description"]);
```

### ランダムな猫の画像を取得

```mu
let response = http_get("https://api.thecatapi.com/v1/images/search");
let data = json_parse(response);
print("Cat image:", data[0]["url"]);
```

### 仮想通貨の価格を取得

```mu
let response = http_get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
let data = json_parse(response);
print("Bitcoin price: $", data["bitcoin"]["usd"]);
```

## Discord Botでの使用例

HTTPリクエストとDiscord Botを組み合わせて、API連携Botを作成できます。

```mu
# Botを作成
discord_create_bot("!");

# 猫の画像を返すコマンド
fun cmd_cat(ctx) {
    let response = http_get("https://api.thecatapi.com/v1/images/search");
    let data = json_parse(response);
    return "🐱 " + str(data[0]["url"]);
}

discord_command("cat", cmd_cat);

# Botを起動
let token = env("DISCORD_BOT_TOKEN");
discord_run(token);
```

完全な例は `examples/discord_bot_api.mu` を参照してください。

## APIリファレンス

### http_get(url)

GETリクエストを送信します。

**パラメータ:**
- `url` (string) - リクエスト先のURL

**戻り値:**
- レスポンスボディ（文字列）

**例:**
```mu
let response = http_get("https://api.example.com/data");
```

### http_post(url, data, headers)

POSTリクエストを送信します。

**パラメータ:**
- `url` (string) - リクエスト先のURL
- `data` (string or dict, optional) - 送信するデータ
- `headers` (dict, optional) - カスタムHTTPヘッダー

**戻り値:**
- レスポンスボディ（文字列）

**例:**
```mu
let response = http_post("https://api.example.com/submit", "data=hello");
```

### http_request(method, url, data, headers)

カスタムHTTPメソッドでリクエストを送信します。

**パラメータ:**
- `method` (string) - HTTPメソッド（GET, POST, PUT, DELETE, etc.）
- `url` (string) - リクエスト先のURL
- `data` (string or dict, optional) - 送信するデータ
- `headers` (dict, optional) - カスタムHTTPヘッダー

**戻り値:**
- レスポンスボディ（文字列）

**例:**
```mu
let response = http_request("PUT", "https://api.example.com/update", "data=value");
```

### json_parse(string)

JSON文字列をパースしてオブジェクトに変換します。

**パラメータ:**
- `string` (string) - JSON文字列

**戻り値:**
- パースされたオブジェクト（dict, list, etc.）

**例:**
```mu
let json_str = '{"name": "Mumei", "version": 1}';
let obj = json_parse(json_str);
print(obj["name"]);  # "Mumei"
```

### json_stringify(object)

オブジェクトをJSON文字列に変換します。

**パラメータ:**
- `object` (any) - JSON化するオブジェクト

**戻り値:**
- JSON文字列

**例:**
```mu
# Note: 辞書リテラルは将来のバージョンで実装予定
let json_str = json_stringify(some_object);
print(json_str);
```

## よく使うAPI

### 無料で使えるパブリックAPI

1. **Dog CEO's Dog API**
   - URL: `https://dog.ceo/api/breeds/image/random`
   - 説明: ランダムな犬の画像
   - 認証: 不要

2. **The Cat API**
   - URL: `https://api.thecatapi.com/v1/images/search`
   - 説明: ランダムな猫の画像
   - 認証: 不要

3. **Official Joke API**
   - URL: `https://official-joke-api.appspot.com/random_joke`
   - 説明: プログラミングジョーク
   - 認証: 不要

4. **CoinGecko API**
   - URL: `https://api.coingecko.com/api/v3/simple/price`
   - 説明: 仮想通貨の価格
   - 認証: 不要

5. **Quotable API**
   - URL: `https://api.quotable.io/random`
   - 説明: ランダムな名言
   - 認証: 不要

6. **OpenWeatherMap API**
   - URL: `https://api.openweathermap.org/data/2.5/weather`
   - 説明: 天気情報
   - 認証: APIキー必要（無料プランあり）
   - サイト: https://openweathermap.org/api

## エラーハンドリング

HTTPリクエストが失敗した場合、エラーが発生します。

```mu
# Note: try-catchは将来のバージョンで実装予定
let response = http_get("https://api.example.com/data");
```

## 制限事項

- 現在、基本的なHTTPリクエストのみサポート
- カスタムヘッダーは部分的なサポート
- タイムアウトは自動設定
- HTTPS接続を推奨

## サンプルコード

完全なサンプルコード：

- `examples/http_demo.mu` - HTTP機能の基本的な使い方
- `examples/discord_bot_api.mu` - API連携Discord Bot

## 次のステップ

- [Discord Bot機能](DISCORD_BOT.md) - Discord Botの作成方法
- [非同期処理](ASYNC.md) - 非同期処理の使い方
- [クイックスタート](QUICKSTART.md) - Mumei言語の基本

## トラブルシューティング

### SSL証明書エラー

HTTPSで接続できない場合、証明書の問題が原因の可能性があります。

### JSONパースエラー

レスポンスがJSON形式でない場合、`json_parse`は失敗します。
まずレスポンスを確認してください：

```mu
let response = http_get("https://api.example.com/data");
print("Response:", response);  # デバッグ用
let data = json_parse(response);
```

### APIキーの管理

APIキーは環境変数で管理することを推奨します：

```bash
export API_KEY="your_key_here"
```

```mu
let api_key = env("API_KEY");
```

## 関連ドキュメント

- [Mumei言語リファレンス](README.md)
- [拡張機能](EXTENSIONS.md)
- [インストール](INSTALL.md)
