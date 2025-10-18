# mu programming Language

Pythonをベースにした新しいプログラミング言語「Mumei」のインタプリタ実装です。
ファイル拡張子は `.mu` を使用します。

## 🚀 高性能Rust実装

**メインブランチはRust実装になりました！**

- **超高速**: Python版の5-10倍のパフォーマンス
- **Rustコア**: レキサー、パーサー、インタプリタをRustで実装
- **バイトコードVM**: コンパイル+実行の分離で最大効率
- **Python互換**: 既存のPython実装とシームレスに統合

### ブランチ構成

- **`main`** (Rust版) - メインブランチ、Rust実装 + Python統合
- **`mulang-py`** (Python版) - Python実装のみ（レガシー）
- **`mulang-dev`** - 開発ブランチ
- **`vscode-extension`** - VSCode拡張機能
- **`discord-extension`** - Discord Bot拡張

詳細は [RUST_QUICKSTART.md](RUST_QUICKSTART.md) と [SETUP_GUIDE.md](SETUP_GUIDE.md) を参照してください。

## 特徴

- **シンプルな構文**: Pythonの影響を受けたクリーンで読みやすい構文
- **動的型付け**: 変数の型宣言が不要
- **関数型プログラミング**: 一級関数とクロージャをサポート
- **組み込み関数**: `print`, `input`, `len`, `type`, `str`, `int`, `float`, `range` など
- **データ構造**: 数値、文字列、真偽値、リスト、**辞書（dict）**、None
- **オブジェクト指向**: クラス、継承、インスタンス化をサポート
- **制御構造**: if/else、while、for ループ
- **HTTPリクエスト**: 外部APIとの連携が可能（`http_get`, `http_post`, `json_parse`）
- **例外処理**: `try-catch-finally`と`throw`でエラーハンドリング
- **ファイルI/O**: ファイルの読み書き、ディレクトリ操作
- **標準ライブラリ**: 数学、ランダム、文字列、日時、正規表現など
- **デバッガー**: デバッグ出力、ブレークポイント、タイマーなど
- **Discord Bot**: 簡単にDiscord Botを作成可能（オプション）
- **非同期処理**: `sleep`, `get_time`などの時間制御機能
- **独自コマンド**: `mumei`コマンドで`.mu`ファイルを実行

## インストール

Python 3.6以降が必要です。

```bash
git clone <repository-url>
cd mumei-language
chmod +x mumei  # 実行権限を付与
```

### システムパスに追加（オプション）

どこからでも`mumei`コマンドを使えるようにするには:

```bash
# シンボリックリンクを作成
sudo ln -s "$(pwd)/mumei" /usr/local/bin/mumei

# または環境変数PATHに追加
export PATH="$PATH:$(pwd)"
```

### VSCode拡張機能（シンタックスハイライト）

`.mu`ファイルに色をつけるVSCode拡張機能をインストール:

```bash
cd vscode-mumei
./install.sh  # macOS/Linux
# または
install.bat   # Windows
```

VSCodeを再起動すると、`.mu`ファイルが自動的にハイライトされます！

詳細は [vscode-mumei/INSTALL.md](vscode-mumei/INSTALL.md) を参照。

## 使い方

### REPLモード

```bash
./mumei
# または、パスに追加している場合
mumei
```

インタラクティブなREPL(Read-Eval-Print Loop)が起動します:

```
mumei> let x = 10;
mumei> let y = 20;
mumei> print(x + y);
30
```

### ファイル実行

```bash
./mumei examples/hello.mu
# または
mumei examples/hello.mu
```

### ヘルプ表示

```bash
mumei --help
```

### バージョン表示

```bash
mumei --version
```

## 言語仕様

### 変数宣言

変数宣言には `let` キーワードを使用します:

```mu
let x = 10;
let name = "Mumei Language";
let is_active = true;
let numbers = [1, 2, 3, 4, 5];
```

### データ型

- **数値**: 整数と浮動小数点数
  ```mu
  let age = 25;
  let pi = 3.14159;
  ```

- **文字列**: シングルクォートまたはダブルクォート
  ```mu
  let message = "Hello, World!";
  let char = 'A';
  ```

- **真偽値**: `true` と `false`
  ```mu
  let is_valid = true;
  let is_empty = false;
  ```

- **リスト**: 複数の要素を持つコレクション
  ```mu
  let fruits = ["apple", "banana", "cherry"];
  let mixed = [1, "two", true, [3, 4]];
  ```

- **None**: 値がないことを表す
  ```mu
  let empty = none;
  ```

### 演算子

#### 算術演算子
```mu
let a = 10 + 5;   # 加算
let b = 10 - 5;   # 減算
let c = 10 * 5;   # 乗算
let d = 10 / 5;   # 除算
let e = 10 % 3;   # 剰余
```

#### 比較演算子
```mu
let result1 = 10 == 10;  # 等しい
let result2 = 10 != 5;   # 等しくない
let result3 = 10 > 5;    # より大きい
let result4 = 10 < 20;   # より小さい
let result5 = 10 >= 10;  # 以上
let result6 = 10 <= 20;  # 以下
```

#### 論理演算子
```mu
let result1 = true and false;  # AND
let result2 = true or false;   # OR
let result3 = not true;        # NOT
```

### 関数定義

関数は `fun` キーワードで定義します:

```mu
fun add(a, b) {
    return a + b;
}

let result = add(10, 20);
print(result);  # 30
```

再帰関数もサポートされています:

```mu
fun factorial(n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

print(factorial(5));  # 120
```

### 制御構造

#### if/else文

```mu
let age = 20;

if (age >= 18) {
    print("成人です");
} else {
    print("未成年です");
}
```

#### whileループ

```mu
let i = 0;
while (i < 5) {
    print(i);
    i = i + 1;
}
```

#### forループ

```mu
# リストのイテレーション
let fruits = ["apple", "banana", "cherry"];
for (fruit in fruits) {
    print(fruit);
}

# 範囲のイテレーション
for (i in range(5)) {
    print(i);  # 0, 1, 2, 3, 4
}
```

### リスト操作

```mu
let numbers = [1, 2, 3];

# 要素へのアクセス
let first = numbers[0];

# 要素の追加
append(numbers, 4);

# 要素の削除
let last = pop(numbers);

# リストの長さ
let size = len(numbers);

# イテレーション
for (num in numbers) {
    print(num);
}
```

### 組み込み関数

#### 基本関数
- `print(...)`: 値を出力
- `input(prompt)`: ユーザー入力を取得
- `len(obj)`: リストまたは文字列の長さを取得
- `type(obj)`: オブジェクトの型を取得
- `str(obj)`: 文字列に変換
- `int(obj)`: 整数に変換
- `float(obj)`: 浮動小数点数に変換
- `range(start, stop)`: 範囲を生成
- `append(list, item)`: リストに要素を追加
- `pop(list, index)`: リストから要素を削除

#### 環境変数
- `env(key, default)`: 環境変数を取得（デフォルト値指定可）
- `env_set(key, value)`: 環境変数を設定
- `env_has(key)`: 環境変数の存在チェック
- `env_list()`: すべての環境変数名を取得

#### HTTPリクエスト
- `http_get(url)`: GETリクエストを送信
- `http_post(url, data, headers)`: POSTリクエストを送信
- `http_request(method, url, data, headers)`: カスタムHTTPリクエスト
- `json_parse(string)`: JSON文字列をパース
- `json_stringify(object)`: オブジェクトをJSON文字列に変換

### 環境変数の使用

```mu
# 環境変数を取得
let user = env("USER");
let home = env("HOME");

# デフォルト値を指定
let api_key = env("API_KEY", "default_key");

# 環境変数の存在チェック
if (env_has("DEBUG")) {
    print("Debug mode enabled");
}

# 環境変数を設定
env_set("MY_VAR", "Hello");
```

**Discord Bot Tokenの安全な使用例:**
```mu
# 環境変数からトークンを取得
let token = env("DISCORD_BOT_TOKEN");

if (token == none) {
    print("Error: DISCORD_BOT_TOKEN not set!");
} else {
    discord_run(token);
}
```

### HTTPリクエストの使用

```mu
# GETリクエストを送信
let response = http_get("https://dog.ceo/api/breeds/image/random");
let data = json_parse(response);
print("Dog image:", data["message"]);

# 仮想通貨の価格を取得
let crypto_response = http_get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
let crypto_data = json_parse(crypto_response);
print("Bitcoin: $", crypto_data["bitcoin"]["usd"]);

# 天気情報（APIキー必要）
let api_key = env("OPENWEATHER_API_KEY");
let url = "https://api.openweathermap.org/data/2.5/weather?q=Tokyo&appid=" + api_key;
let weather_response = http_get(url);
let weather_data = json_parse(weather_response);
print("Temperature:", weather_data["main"]["temp"], "°C");
```

詳細は [HTTP.md](HTTP.md) を参照してください。

### 例外処理の使用

```mu
# try-catch-finallyでエラーハンドリング
try {
    let result = 10 / 0;  # ゼロ除算
    print(result);
} catch (error) {
    print("Error caught:", error);
} finally {
    print("Cleanup");
}

# throwで例外をスロー
fun divide(a, b) {
    if (b == 0) {
        throw "Cannot divide by zero!";
    }
    return a / b;
}

# HTTPリクエストの安全な実行
try {
    let response = http_get("https://api.example.com/data");
    let data = json_parse(response);
    print("Success:", data);
} catch (error) {
    print("API error:", error);
}
```

詳細は [EXCEPTION.md](EXCEPTION.md) を参照してください。

### コメント

```mu
# これは単一行コメントです
// これも単一行コメントです

let x = 10;  # 行末のコメント
```

## サンプルプログラム

### Hello World

```mu
print("Hello, World!");
```

### FizzBuzz

```mu
for (i in range(1, 31)) {
    if (i % 15 == 0) {
        print("FizzBuzz");
    } else {
        if (i % 3 == 0) {
            print("Fizz");
        } else {
            if (i % 5 == 0) {
                print("Buzz");
            } else {
                print(i);
            }
        }
    }
}
```

### フィボナッチ数列

```mu
fun fibonacci(n) {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

for (i in range(10)) {
    print("F(" + str(i) + ") =", fibonacci(i));
}
```

詳細なサンプルは `examples/` ディレクトリを参照してください。

## Discord Bot機能 🤖

Mumei言語では、シンプルにDiscord botを作成できます！

### 🆕 d.muモジュール（推奨）

新しい`d.mu`モジュールを使えば、さらに簡単にDiscord Botを作成できます！

```mu
import "d.mu" as d;

# Botを作成
d.create_bot("!");

# Bot起動時
d.on_ready(lambda() {
    print("Bot is ready!");
});

# コマンドを登録
d.command("ping", lambda(ctx, args) {
    d.reply(ctx, "Pong! 🏓");
});

# Botを起動
d.run(env("DISCORD_TOKEN"));
```

**特徴:**
- ✅ シンプルで直感的なAPI
- ✅ ボタン・セレクトメニュー対応
- ✅ スラッシュコマンド対応
- ✅ モデレーション機能（kick、ban、role）
- ✅ Webhook対応
- ✅ 完全なドキュメント

詳細は [DISCORD_MODULE.md](DISCORD_MODULE.md) を参照してください。

### セットアップ

```bash
pip install discord.py
```

### 従来のAPI（レガシー）

```mu
# Botを作成
discord_create_bot("!");

# コマンドを定義
fun cmd_hello(ctx) {
    return "Hello from Mumei!";
}

# コマンドを登録
discord_command("hello", cmd_hello);

# Botを起動
discord_run("YOUR_BOT_TOKEN");
```

### 利用可能な関数

**基本機能:**
- `discord_create_bot(prefix)` - Botインスタンスを作成
- `discord_command(name, callback)` - コマンドを登録
- `discord_on_event(event, callback)` - イベントハンドラを登録
- `discord_run(token)` - Botを起動

**Embed（リッチメッセージ）:**
- `discord_create_embed(title, description, color)` - Embedを作成
- `discord_embed_add_field(embed, name, value, inline)` - フィールドを追加
- `discord_embed_set_footer(embed, text, icon_url)` - フッターを設定
- `discord_embed_set_author(embed, name, icon_url)` - 作者情報を設定

**インタラクション（ボタン・セレクトメニュー）:**
- `discord_create_button(label, custom_id, style, emoji, disabled)` - ボタンを作成
- `discord_create_select(custom_id, options, placeholder, min_values, max_values)` - セレクトメニューを作成
- `discord_create_view(components)` - Viewを作成（ボタンやセレクトメニューを含む）
- `discord_on_interaction(custom_id, callback)` - インタラクションのコールバックを登録
- `discord_command_with_view(name, callback)` - Viewを返すコマンドを登録

### サンプル

- `examples/discord_bot_simple.mu` - シンプルなBot
- `examples/discord_bot_advanced.mu` - 高度な機能を持つBot
- `examples/discord_bot_advanced_features.mu` - Embed、データ永続化、モデレーション機能
- `examples/discord_bot_interactions.mu` - ボタン、セレクトメニュー、インタラクション機能
- `examples/discord_bot_api.mu` - HTTPリクエストを使ったAPI連携Bot

詳細は [DISCORD_BOT.md](DISCORD_BOT.md) を参照してください。

## プロジェクト構造

```
mumei-language/
├── mumei                      # メイン実行ファイル
├── mm_lexer.py                # レキサー(トークナイザー)
├── mm_parser.py               # パーサー(AST生成)
├── mm_interpreter.py          # インタプリタ(評価器)
├── mm_discord.py              # Discord bot サポート
├── README.md                  # このファイル
├── DISCORD_BOT.md             # Discord bot ドキュメント
├── INSTALL.md                 # インストールガイド
├── QUICKSTART.md              # クイックスタート
├── vscode-mumei/              # VSCode拡張機能
│   ├── package.json
│   ├── language-configuration.json
│   ├── syntaxes/
│   │   └── mumei.tmLanguage.json
│   ├── README.md
│   ├── INSTALL.md
│   ├── install.sh             # インストールスクリプト(macOS/Linux)
│   └── install.bat            # インストールスクリプト(Windows)
└── examples/                  # サンプルプログラム
    ├── hello.mu
    ├── fibonacci.mu
    ├── fizzbuzz.mu
    ├── factorial.mu
    ├── list_operations.mu
    ├── prime_numbers.mu
    ├── env_demo.mu
    ├── http_demo.mu                      # HTTP機能デモ
    ├── exception_demo.mu                 # 例外処理デモ
    ├── dict_demo.mu                      # 辞書型デモ
    ├── class_demo.mu                     # クラス/OOPデモ
    ├── file_io_demo.mu                   # ファイルI/Oデモ
    ├── stdlib_demo.mu                    # 標準ライブラリデモ
    ├── lambda_example.mu                 # ラムダ式デモ
    ├── list_comprehension_example.mu     # リスト内包表記デモ
    ├── slice_example.mu                  # スライス記法デモ
    ├── multiple_assignment_example.mu    # 複数代入デモ
    ├── variadic_args_example.mu          # 可変長引数デモ
    ├── dict_comprehension_example.mu     # 辞書内包表記デモ
    ├── async_await_example.mu            # 非同期処理デモ
    ├── discord_bot_simple.mu             # シンプルなBot
    ├── discord_bot_advanced.mu           # 高度な機能Bot
    ├── discord_bot_advanced_features.mu  # Embed・永続化・モデレーション
    ├── discord_bot_interactions.mu       # ボタン・セレクトメニュー
    ├── discord_bot_api.mu                # API連携Bot
    └── discord_bot_safe_api.mu           # 例外処理付きBot
```

## アーキテクチャ

Mumei言語インタプリタは3つの主要なコンポーネントで構成されています:

1. **レキサー(Lexer)**: ソースコードをトークンに分割
2. **パーサー(Parser)**: トークンから抽象構文木(AST)を生成
3. **インタプリタ(Interpreter)**: ASTを評価して実行

```
ソースコード → レキサー → トークン → パーサー → AST → インタプリタ → 実行
```

## 今後の拡張案

- [x] 辞書(dict)型のサポート ✅ 実装済み
- [x] クラスとオブジェクト指向プログラミング ✅ 実装済み
- [x] 例外処理(try/catch) ✅ 実装済み
- [ ] モジュールシステム(import)
- [x] ファイルI/O関数 ✅ 実装済み
- [x] より多くの組み込み関数 ✅ 実装済み
- [x] 標準ライブラリ ✅ 実装済み
- [x] デバッガーのサポート ✅ 実装済み
- [ ] パッケージマネージャー
- [ ] マルチスレッド/マルチプロセス

## ドキュメント

- [インストールガイド](INSTALL.md) - セットアップ手順
- [クイックスタート](QUICKSTART.md) - 5分で始めるMumei
- [HTTP機能](HTTP.md) - HTTPリクエストとAPI連携
- [例外処理](EXCEPTION.md) - try-catch-finallyでエラーハンドリング
- [Discord Bot](DISCORD_BOT.md) - Discord Bot作成ガイド
- [非同期処理](ASYNC.md) - 時間制御と非同期機能
- [拡張機能](EXTENSIONS.md) - 拡張機能の概要

## Repository Branches

このリポジトリは機能ごとに以下のブランチに分かれています:

- **main** - コア言語実装（このブランチ）
- **vscode-extension** - VSCode拡張機能（シンタックスハイライト）
- **discord-extension** - Discord Bot拡張機能

## ライセンス

MIT License

## 作者

Created as a learning project for building programming language interpreters.
