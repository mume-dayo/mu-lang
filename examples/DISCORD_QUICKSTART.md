# Discord Bot クイックスタート

5分でDiscord Botを作成！

## ステップ1: discord.pyをインストール

```bash
pip install discord.py
```

## ステップ2: Discord Botを作成

1. [Discord Developer Portal](https://discord.com/developers/applications)にアクセス
2. "New Application"をクリック
3. アプリ名を入力して作成
4. 左メニューの"Bot"をクリック
5. "Add Bot"をクリック
6. "Reset Token"をクリックしてトークンをコピー（メモ帳に保存）

## ステップ3: Bot権限を設定

1. 左メニューの"Bot"で以下を有効化:
   - ✅ MESSAGE CONTENT INTENT
   - ✅ SERVER MEMBERS INTENT

2. 左メニューの"OAuth2" → "URL Generator"で:
   - SCOPES: ✅ `bot`
   - BOT PERMISSIONS:
     - ✅ Send Messages
     - ✅ Read Messages/View Channels
     - ✅ Read Message History

3. 生成されたURLをコピーしてブラウザで開き、Botをサーバーに招待

## ステップ4: Botプログラムを作成

`mybot.mu`を作成:

```mu
# Discord Botを作成
discord_create_bot("!");

# !pingコマンド
fun cmd_ping(ctx) {
    return "Pong!";
}

# !helloコマンド
fun cmd_hello(ctx, name) {
    return "Hello, " + str(name) + "!";
}

# コマンドを登録
discord_command("ping", cmd_ping);
discord_command("hello", cmd_hello);

# Botを起動（トークンをここに貼り付け）
discord_run("YOUR_BOT_TOKEN_HERE");
```

## ステップ5: Botを起動

```bash
mumei mybot.mu
```

"Bot logged in as YourBotName#1234" が表示されれば成功！

## ステップ6: Discordで試す

Botを招待したサーバーで:

```
!ping
→ Pong!

!hello World
→ Hello, World!
```

## 🎉 完成！

より多くのコマンドを追加したい場合は、`examples/discord_bot_advanced.mu`を参考にしてください！

## トラブルシューティング

### "discord.py is not installed"
```bash
pip install discord.py
```

### "Improper token has been passed"
- トークンを確認
- Developer Portalで"Reset Token"して新しいトークンを取得

### Botがメッセージに反応しない
- MESSAGE CONTENT INTENTが有効か確認
- Botがサーバーに参加しているか確認
- 正しいプレフィックス（`!`）を使っているか確認
