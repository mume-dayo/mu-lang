# Discord Module (d.mu) - ドキュメント

Mumei言語用のDiscord Bot開発モジュール。シンプルで直感的なAPIでDiscord Botを簡単に作成できます。

## 📦 インストール

```bash
# discord.pyをインストール
pip install discord.py
```

## 🚀 クイックスタート

```mumei
import "d.mu" as d;

# Botを作成
d.create_bot("!");

# Bot起動時のイベント
d.on_ready(lambda() {
    print("Bot is ready!");
});

# コマンドを登録
d.command("ping", lambda(ctx, args) {
    d.reply(ctx, "Pong!");
});

# Botを起動
let token = env("DISCORD_TOKEN");
d.run(token);
```

## 📚 API リファレンス

### Bot管理

#### `create_bot(prefix)`
Botインスタンスを作成します。

- **prefix** (string): コマンドのプレフィックス（例: "!", "?"）

```mumei
d.create_bot("!");
```

#### `run(token)`
Botを起動します。

- **token** (string): Discord Bot Token

```mumei
d.run("YOUR_BOT_TOKEN");
```

---

### イベントハンドラー

#### `on_ready(callback)`
Bot起動時に呼ばれるイベント。

```mumei
d.on_ready(lambda() {
    print("✅ Bot started!");
});
```

#### `on_message(callback)`
メッセージ受信時に呼ばれるイベント。

- **callback**: `fun(message) { ... }`

```mumei
d.on_message(lambda(message) {
    let content = message["content"];
    let author = message["author"]["name"];
    print(author + " said: " + content);
});
```

#### `on_member_join(callback)`
メンバーがサーバーに参加した時のイベント。

```mumei
d.on_member_join(lambda(member) {
    print("Welcome " + member["name"] + "!");
});
```

#### `on_member_remove(callback)`
メンバーがサーバーから退出した時のイベント。

```mumei
d.on_member_remove(lambda(member) {
    print(member["name"] + " left the server");
});
```

#### `on_reaction_add(callback)`
リアクションが追加された時のイベント。

```mumei
d.on_reaction_add(lambda(reaction, user) {
    print(user["name"] + " reacted with " + reaction["emoji"]);
});
```

---

### コマンド

#### `command(name, callback)`
テキストコマンドを登録します。

- **name** (string): コマンド名
- **callback**: `fun(ctx, args) { ... }`

```mumei
d.command("hello", lambda(ctx, args) {
    d.reply(ctx, "Hello!");
});

# 引数付きコマンド
d.command("echo", lambda(ctx, args) {
    let message = join(" ", args);
    d.reply(ctx, message);
});
```

#### `slash_command(name, description, callback)`
スラッシュコマンド（/コマンド）を登録します。

- **name** (string): コマンド名
- **description** (string): コマンドの説明
- **callback**: `fun(interaction) { ... }`

```mumei
d.slash_command("ping", "Check bot status", lambda(interaction) {
    d.respond(interaction, "Pong!");
});
```

---

### メッセージ送信

#### `send(channel_id, content)`
チャンネルにメッセージを送信します。

```mumei
d.send("123456789", "Hello from bot!");
```

#### `reply(ctx, content)`
コマンドに対して返信します。

```mumei
d.command("greet", lambda(ctx, args) {
    d.reply(ctx, "Hello there!");
});
```

#### `send_embed(channel_id, title, description, color)`
Embedメッセージを送信します。

- **color**: 16進数の色コード（例: 0xFF0000は赤）

```mumei
d.send_embed(
    channel_id,
    "Announcement",
    "This is an important message!",
    0x00FF00  # 緑色
);
```

---

### メッセージ操作

#### `delete_message(message_id, channel_id)`
メッセージを削除します。

```mumei
d.delete_message("987654321", "123456789");
```

#### `edit_message(message_id, channel_id, new_content)`
メッセージを編集します。

```mumei
d.edit_message("987654321", "123456789", "Edited message");
```

#### `add_reaction(message_id, channel_id, emoji)`
メッセージにリアクションを追加します。

```mumei
d.add_reaction("987654321", "123456789", "👍");
```

---

### チャンネル操作

#### `create_text_channel(guild_id, name)`
テキストチャンネルを作成します。

```mumei
d.create_text_channel("111222333", "general");
```

#### `create_voice_channel(guild_id, name)`
ボイスチャンネルを作成します。

```mumei
d.create_voice_channel("111222333", "Voice Chat");
```

#### `delete_channel(channel_id)`
チャンネルを削除します。

```mumei
d.delete_channel("123456789");
```

#### `rename_channel(channel_id, new_name)`
チャンネルをリネームします。

```mumei
d.rename_channel("123456789", "new-name");
```

---

### ロール操作

#### `create_role(guild_id, name, color)`
ロールを作成します。

```mumei
d.create_role("111222333", "VIP", 0xFF0000);
```

#### `add_role(guild_id, user_id, role_id)`
メンバーにロールを付与します。

```mumei
d.add_role("111222333", "555666777", "888999000");
```

#### `remove_role(guild_id, user_id, role_id)`
メンバーからロールを削除します。

```mumei
d.remove_role("111222333", "555666777", "888999000");
```

---

### メンバー操作

#### `kick(guild_id, user_id, reason)`
メンバーをキックします。

```mumei
d.kick("111222333", "555666777", "Violated rules");
```

#### `ban(guild_id, user_id, reason)`
メンバーをBANします。

```mumei
d.ban("111222333", "555666777", "Spam");
```

#### `set_nickname(guild_id, user_id, nickname)`
メンバーのニックネームを変更します。

```mumei
d.set_nickname("111222333", "555666777", "NewNick");
```

---

### インタラクション

#### `send_button(channel_id, content, button_label, button_id, callback)`
ボタン付きメッセージを送信します。

```mumei
let callback = lambda(interaction) {
    d.respond(interaction, "Button clicked!");
};

d.send_button(
    "123456789",
    "Click the button!",
    "Click Me",
    "button_1",
    callback
);
```

#### `send_select(channel_id, content, options, callback)`
セレクトメニュー付きメッセージを送信します。

```mumei
let options = [
    {"label": "Option 1", "value": "opt1"},
    {"label": "Option 2", "value": "opt2"}
];

let callback = lambda(interaction, selected) {
    d.respond(interaction, "You selected: " + selected);
};

d.send_select("123456789", "Choose one:", options, callback);
```

#### `send_modal(interaction, title, fields, callback)`
Modalダイアログを送信します。

```mumei
let fields = [
    {"label": "Your Name", "id": "name"},
    {"label": "Your Age", "id": "age"}
];

let callback = lambda(modal_interaction, values) {
    let name = values["name"];
    let age = values["age"];
    d.respond(modal_interaction, "Hello " + name + ", age " + age);
};

d.send_modal(interaction, "User Info", fields, callback);
```

#### `respond(interaction, content)`
インタラクションに返信します。

```mumei
d.respond(interaction, "Response message");
```

---

### Webhook

#### `create_webhook(channel_id, name)`
Webhookを作成します。

```mumei
let webhook = d.create_webhook("123456789", "My Webhook");
```

#### `webhook_send(webhook_url, content)`
WebhookでメッセージをPOSTします。

```mumei
d.webhook_send(
    "https://discord.com/api/webhooks/...",
    "Message from webhook"
);
```

#### `webhook_send_embed(webhook_url, embed_data)`
Webhook経由でEmbedメッセージを送信します。

```mumei
let embed = {
    "title": "Announcement",
    "description": "Important info",
    "color": 0x00FF00
};

d.webhook_send_embed("https://discord.com/api/webhooks/...", embed);
```

---

### ユーティリティ

#### `get_user(user_id)`
ユーザー情報を取得します。

```mumei
let user = d.get_user("123456789");
print(user["name"]);
```

#### `get_channel(channel_id)`
チャンネル情報を取得します。

```mumei
let channel = d.get_channel("123456789");
print(channel["name"]);
```

#### `get_guild(guild_id)`
サーバー情報を取得します。

```mumei
let guild = d.get_guild("123456789");
print(guild["name"]);
```

#### `get_messages(channel_id, limit)`
メッセージ履歴を取得します。

```mumei
let messages = d.get_messages("123456789", 10);
for (msg in messages) {
    print(msg["content"]);
}
```

#### `info()`
モジュール情報を表示します。

```mumei
d.info();
```

---

## 🎯 サンプルコード

### シンプルなBot

```mumei
import "d.mu" as d;

d.create_bot("!");

d.on_ready(lambda() {
    print("Bot is online!");
});

d.command("ping", lambda(ctx, args) {
    d.reply(ctx, "Pong! 🏓");
});

d.run(env("DISCORD_TOKEN"));
```

### モデレーションBot

```mumei
import "d.mu" as d;

d.create_bot("!");

d.command("kick", lambda(ctx, args) {
    if (len(args) < 2) {
        d.reply(ctx, "Usage: !kick <user_id> <reason>");
        return None;
    }

    let guild_id = ctx["guild_id"];
    let user_id = args[0];
    let reason = join(" ", args[1:]);

    d.kick(guild_id, user_id, reason);
    d.reply(ctx, "✅ User kicked");
});

d.run(env("DISCORD_TOKEN"));
```

### インタラクティブBot

```mumei
import "d.mu" as d;

d.create_bot("!");

d.command("vote", lambda(ctx, args) {
    let channel_id = ctx["channel_id"];

    let yes_callback = lambda(interaction) {
        d.respond(interaction, "You voted Yes! ✅");
    };

    let no_callback = lambda(interaction) {
        d.respond(interaction, "You voted No! ❌");
    };

    d.send_button(channel_id, "Vote: Yes or No?", "Yes", "yes_btn", yes_callback);
    d.send_button(channel_id, "", "No", "no_btn", no_callback);
});

d.run(env("DISCORD_TOKEN"));
```

---

## 📝 ベストプラクティス

1. **環境変数でトークン管理**
   ```bash
   export DISCORD_TOKEN='your-bot-token'
   ```

2. **エラーハンドリング**
   ```mumei
   try {
       d.kick(guild_id, user_id, reason);
   } catch (e) {
       d.reply(ctx, "Error: " + e);
   }
   ```

3. **ロギング**
   ```mumei
   d.on_message(lambda(message) {
       print("[LOG] " + message["author"]["name"] + ": " + message["content"]);
   });
   ```

4. **権限チェック**
   ```mumei
   d.command("admin", lambda(ctx, args) {
       let author = ctx["author"];
       if (!has_key(author, "admin")) {
           d.reply(ctx, "❌ Admin only!");
           return None;
       }
       # Admin command logic
   });
   ```

---

## 🔗 関連リンク

- [Discord Developer Portal](https://discord.com/developers/applications)
- [discord.py Documentation](https://discordpy.readthedocs.io/)
- [Mumei Language README](README.md)

---

## 📄 ライセンス

このモジュールはMumei言語の一部として提供されています。
