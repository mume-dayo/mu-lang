# 例外処理 (Exception Handling)

Mumei言語の例外処理機能について説明します。

## 概要

Mumeiでは、`try-catch-finally`構文と`throw`文を使用して例外処理を行います。
これにより、エラーが発生しても安全にプログラムを実行できます。

## 基本構文

### try-catch

```mu
try {
    # エラーが発生する可能性のあるコード
    let result = 10 / 0;
} catch (error) {
    # エラーが発生した時の処理
    print("Error:", error);
}
```

### try-finally

```mu
try {
    # コード
    print("Processing...");
} finally {
    # 必ず実行されるコード
    print("Cleanup");
}
```

### try-catch-finally

```mu
try {
    # エラーが発生する可能性のあるコード
    let data = fetch_data();
} catch (error) {
    # エラー処理
    print("Error:", error);
} finally {
    # 必ず実行されるクリーンアップ
    print("Done");
}
```

### throw文

独自のエラーをスローできます：

```mu
fun divide(a, b) {
    if (b == 0) {
        throw "Cannot divide by zero!";
    }
    return a / b;
}

try {
    let result = divide(10, 0);
} catch (error) {
    print("Caught:", error);  # "Caught: Cannot divide by zero!"
}
```

## 使用例

### 1. 基本的な例外処理

```mu
try {
    let numbers = [1, 2, 3];
    print(numbers[10]);  # インデックスエラー
} catch (e) {
    print("Error:", e);
}
```

### 2. HTTPリクエストのエラーハンドリング

```mu
try {
    let response = http_get("https://api.example.com/data");
    let data = json_parse(response);
    print("Success:", data);
} catch (error) {
    print("Failed to fetch data:", error);
}
```

### 3. 入力検証

```mu
fun validate_age(age) {
    if (type(age) != "int") {
        throw "Age must be an integer";
    }
    if (age < 0) {
        throw "Age cannot be negative";
    }
    if (age > 150) {
        throw "Age is unrealistic";
    }
    return true;
}

try {
    validate_age(-5);
} catch (error) {
    print("Validation error:", error);
}
```

### 4. リソース管理

```mu
let file = none;
try {
    file = open_file("data.txt");
    # ファイル処理
    process_file(file);
} catch (error) {
    print("Error processing file:", error);
} finally {
    # ファイルを必ずクローズ
    if (file != none) {
        close_file(file);
    }
}
```

### 5. ネストされた例外処理

```mu
try {
    print("Outer try");
    try {
        print("Inner try");
        throw "Inner error";
    } catch (e) {
        print("Inner catch:", e);
        throw "Outer error";
    }
} catch (e) {
    print("Outer catch:", e);
}
```

## Discord Botでの例外処理

安全なAPI連携Botの例：

```mu
discord_create_bot("!");

fun cmd_weather(ctx, city) {
    try {
        # 入力検証
        if (city == none) {
            throw "都市名を指定してください";
        }

        # API呼び出し
        let api_key = env("WEATHER_API_KEY");
        if (api_key == none) {
            throw "APIキーが設定されていません";
        }

        let response = http_get("https://api.weather.com/..." + city);
        let data = json_parse(response);

        return "天気: " + str(data["weather"]);
    } catch (error) {
        # エラーをユーザーに返す
        return "❌ エラー: " + str(error);
    }
}

discord_command("weather", cmd_weather);
discord_run(env("DISCORD_BOT_TOKEN"));
```

## エラーハンドリングのベストプラクティス

### 1. 具体的なエラーメッセージ

```mu
# ❌ 良くない
throw "Error";

# ✅ 良い
throw "Cannot divide by zero: denominator is 0";
```

### 2. 適切なスコープでキャッチ

```mu
# 必要な部分だけをtryブロックに入れる
let data = prepare_data();  # エラーが起きないコード

try {
    # エラーが起きる可能性のあるコードのみ
    let result = risky_operation(data);
} catch (error) {
    handle_error(error);
}
```

### 3. finallyでクリーンアップ

```mu
let resource = acquire_resource();
try {
    use_resource(resource);
} catch (error) {
    print("Error:", error);
} finally {
    # 必ずリソースを解放
    release_resource(resource);
}
```

### 4. エラーの再スロー

必要に応じてエラーを再スローできます：

```mu
try {
    # 処理
} catch (error) {
    print("Logging error:", error);
    throw error;  # 上位層に伝播
}
```

## よくあるエラーと対処法

### ゼロ除算

```mu
try {
    let result = 10 / 0;
} catch (error) {
    print("Division error:", error);
}
```

### インデックスエラー

```mu
let list = [1, 2, 3];
try {
    let value = list[10];
} catch (error) {
    print("Index error:", error);
}
```

### 型エラー

```mu
try {
    let result = "text" + 123;  # 型の不一致
} catch (error) {
    print("Type error:", error);
}
```

### HTTPエラー

```mu
try {
    let response = http_get("https://invalid-url.com");
} catch (error) {
    print("Network error:", error);
}
```

## 制限事項

現在のバージョンでの制限：

- カスタム例外クラスは未サポート
- 例外の種類による分岐（catch (TypeError) など）は未サポート
- すべての例外は文字列として扱われる

## サンプルコード

完全なサンプルコード：

- [examples/exception_demo.mu](examples/exception_demo.mu) - 例外処理の基本例
- [examples/discord_bot_safe_api.mu](examples/discord_bot_safe_api.mu) - 安全なAPI連携Bot

## 関連ドキュメント

- [HTTP機能](HTTP.md) - HTTPリクエストとエラーハンドリング
- [Discord Bot](DISCORD_BOT.md) - Discord Botでの例外処理
- [クイックスタート](QUICKSTART.md) - Mumei言語の基本

## まとめ

Mumeiの例外処理を使うことで：

- ✅ エラーに強いプログラムが書ける
- ✅ リソースを安全に管理できる
- ✅ ユーザーフレンドリーなエラーメッセージが提供できる
- ✅ API連携が安全になる

try-catch-finallyを活用して、堅牢なプログラムを作成しましょう！
