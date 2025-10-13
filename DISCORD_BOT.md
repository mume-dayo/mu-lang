# Mumei言語でDiscord Botを作る

Mumei言語では、シンプルな構文でDiscord botを簡単に作成できます！

## 必要なもの

### 1. discord.pyのインストール

```bash
pip install discord.py
```

### 2. Discord Bot Tokenの取得

1. [Discord Developer Portal](https://discord.com/developers/applications)にアクセス
2. "New Application"をクリックして新しいアプリケーションを作成
3. "Bot"タブに移動
4. "Add Bot"をクリック
5. "TOKEN"セクションで"Copy"をクリックしてトークンをコピー

### 3. Bot権限の設定

1. "OAuth2" → "URL Generator"タブに移動
2. "SCOPES"で`bot`を選択
3. "BOT PERMISSIONS"で必要な権限を選択:
   - `Send Messages`
   - `Read Message History`
   - `Read Messages/View Channels`
4. 生成されたURLからBotをサーバーに招待

### 4. Message Content Intentの有効化

1. "Bot"タブに戻る
2. "Privileged Gateway Intents"セクションで以下を有効化:
   - `MESSAGE CONTENT INTENT` ✅
   - `SERVER MEMBERS INTENT` ✅（必要に応じて）

## 基本的なBot

### 最小構成のBot

```mu
# simple_bot.mu

# Botを作成（コマンドプレフィックスは "!"）
discord_create_bot("!");

# コマンドを定義
fun cmd_hello(ctx) {
    return "Hello from Mumei!";
}

# コマンドを登録
discord_command("hello", cmd_hello);

# Botを起動
let token = "YOUR_BOT_TOKEN_HERE";
discord_run(token);
```

実行:
```bash
mumei simple_bot.mu
```

Discordで使用:
```
!hello
```

## Discord API関数

### discord_create_bot(prefix)

Botインスタンスを作成します。

- **引数**: `prefix` - コマンドプレフィックス（デフォルト: `"!"`）
- **戻り値**: 成功メッセージ

```mu
discord_create_bot("!");     # プレフィックスは !
discord_create_bot("$");     # プレフィックスは $
```

### discord_command(name, callback)

コマンドを登録します。

- **引数**:
  - `name` - コマンド名（文字列）
  - `callback` - コマンド実行時に呼び出される関数
- **戻り値**: 登録成功メッセージ

```mu
fun my_command(ctx, arg1, arg2) {
    return "Response message";
}

discord_command("mycommand", my_command);
```

**コールバック関数の引数:**
- `ctx` - コマンドコンテキスト（Discord.py の Context オブジェクト）
- `arg1, arg2, ...` - コマンド引数

**戻り値:**
- 文字列を返すと、その内容がDiscordに送信されます
- `none`を返すと、何も送信されません

### discord_on_event(event_name, callback)

イベントハンドラを登録します。

- **引数**:
  - `event_name` - イベント名（`"ready"`, `"message"` など）
  - `callback` - イベント発生時に呼び出される関数
- **戻り値**: 登録成功メッセージ

```mu
fun on_ready(user) {
    print("Bot started as:", str(user));
}

fun on_message(message) {
    print("Message received");
}

discord_on_event("ready", on_ready);
discord_on_event("message", on_message);
```

**サポートされるイベント:**
- `"ready"` - Bot起動時
- `"message"` - メッセージ受信時

### discord_run(token)

Botを起動します（ブロッキング）。

- **引数**: `token` - Discord Bot トークン
- **戻り値**: なし（Botが停止するまでブロック）

```mu
let token = "YOUR_BOT_TOKEN_HERE";
discord_run(token);
```

**注意**: この関数は実行を停止します。Ctrl+Cで終了できます。

## 実用例

### 1. シンプルなコマンドBot

```mu
discord_create_bot("!");

fun cmd_ping(ctx) {
    return "Pong!";
}

fun cmd_hello(ctx, name) {
    return "Hello, " + str(name) + "!";
}

discord_command("ping", cmd_ping);
discord_command("hello", cmd_hello);

discord_run("YOUR_TOKEN");
```

使い方:
```
!ping           → Pong!
!hello Alice    → Hello, Alice!
```

### 2. 計算Bot

```mu
discord_create_bot("!");

fun cmd_add(ctx, a, b) {
    let num_a = int(a);
    let num_b = int(b);
    let result = num_a + num_b;
    return str(num_a) + " + " + str(num_b) + " = " + str(result);
}

fun cmd_multiply(ctx, a, b) {
    let num_a = int(a);
    let num_b = int(b);
    let result = num_a * num_b;
    return str(num_a) + " × " + str(num_b) + " = " + str(result);
}

discord_command("add", cmd_add);
discord_command("mul", cmd_multiply);

discord_run("YOUR_TOKEN");
```

使い方:
```
!add 5 3    → 5 + 3 = 8
!mul 4 7    → 4 × 7 = 28
```

### 3. イベント監視Bot

```mu
discord_create_bot("!");

let message_count = 0;

fun on_ready(user) {
    print("Bot is online!");
}

fun on_message(message) {
    message_count = message_count + 1;
}

fun cmd_stats(ctx) {
    return "Total messages seen: " + str(message_count);
}

discord_on_event("ready", on_ready);
discord_on_event("message", on_message);
discord_command("stats", cmd_stats);

discord_run("YOUR_TOKEN");
```

### 4. ヘルプ機能付きBot

```mu
discord_create_bot("!");

fun cmd_help(ctx) {
    let help_text = "Available Commands:\n";
    help_text = help_text + "!help - Show this message\n";
    help_text = help_text + "!ping - Check if bot is alive\n";
    help_text = help_text + "!echo <text> - Echo your message\n";
    return help_text;
}

fun cmd_ping(ctx) {
    return "Pong! Bot is alive!";
}

fun cmd_echo(ctx, text) {
    return "You said: " + str(text);
}

discord_command("help", cmd_help);
discord_command("ping", cmd_ping);
discord_command("echo", cmd_echo);

discord_run("YOUR_TOKEN");
```

## セキュリティのベストプラクティス

### 1. トークンを環境変数に保存

Botトークンをコードに直接書かないでください。

**環境変数を使用:**

```bash
# Linux/macOS
export DISCORD_BOT_TOKEN="your_token_here"
mumei bot.mu

# Windows (PowerShell)
$env:DISCORD_BOT_TOKEN="your_token_here"
mumei bot.mu
```

**Mumei側:**
```mu
# 注: 現在、Mumeiは環境変数の直接読み込みをサポートしていません
# 代わりに、別ファイルにトークンを保存し、.gitignoreに追加してください

# token.mu (gitignoreに追加)
let token = "YOUR_ACTUAL_TOKEN";

# bot.mu
# トークンは別途設定
discord_run(token);
```

### 2. .gitignoreに追加

```gitignore
# Discord Bot Token
token.mu
config.mu
.env
```

## トラブルシューティング

### "discord.py is not installed"

```bash
pip install discord.py
```

### "403 Forbidden"

- Bot TokenをDiscord Developer Portalで再確認
- Message Content Intentが有効になっているか確認

### "Privileged intent provided is not enabled"

Discord Developer Portalで以下を有効にしてください:
- MESSAGE CONTENT INTENT
- SERVER MEMBERS INTENT（必要な場合）

### Botがメッセージに反応しない

1. Botがサーバーに招待されているか確認
2. Botに適切な権限があるか確認
3. コマンドプレフィックスが正しいか確認（例: `!`）

### コマンドが実行されない

- コマンド名のスペルを確認
- `discord_command()`で正しく登録されているか確認
- Bot起動前にコマンドを登録しているか確認

## サンプルファイル

プロジェクトには以下のサンプルが含まれています:

- `examples/discord_bot_simple.mu` - シンプルなBot
- `examples/discord_bot_advanced.mu` - 高度な機能を持つBot

```bash
# シンプルなBotを実行
mumei examples/discord_bot_simple.mu

# 高度なBotを実行
mumei examples/discord_bot_advanced.mu
```

**注意**: トークンを設定してから実行してください！

## 次のステップ

- より複雑なコマンドロジックを実装
- データベース連携（将来の機能）
- Webhookの利用（将来の機能）
- カスタムEmbed（将来の機能）

Happy bot building with Mumei! 🤖
