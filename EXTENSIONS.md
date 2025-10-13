# Mumei言語 拡張機能

Mumei言語のコア機能を拡張するモジュールのガイドです。

## Discord Bot拡張

Discord Bot機能は別モジュールとして提供されています。

### ファイル

`discord-extension/` ディレクトリに以下が含まれています:

```
discord-extension/
├── README.md                     # Discord拡張のREADME
├── DISCORD_BOT.md                # 完全なドキュメント
├── DISCORD_QUICKSTART.md         # クイックスタート
├── mm_discord.py                 # Discord拡張モジュール
├── discord_bot_simple.mu         # シンプルなBotサンプル
└── discord_bot_advanced.mu       # 高度なBotサンプル
```

### インストール方法

1. **discord.pyをインストール:**
   ```bash
   pip install discord.py
   ```

2. **mm_discord.pyをコピー:**
   ```bash
   cp discord-extension/mm_discord.py .
   ```

3. **使用開始:**
   Mumeiインタプリタが自動的にDiscord機能を読み込みます。

### 使用例

```mu
# Discord Botを作成
discord_create_bot("!");

fun cmd_hello(ctx) {
    return "Hello from Mumei!";
}

discord_command("hello", cmd_hello);

let token = env("DISCORD_BOT_TOKEN");
discord_run(token);
```

### サンプルの実行

```bash
# トークンを設定
export DISCORD_BOT_TOKEN="your_token_here"

# Botを実行
mumei discord-extension/discord_bot_simple.mu
```

## VSCode拡張機能

シンタックスハイライトはコアに含まれています。

```bash
cd vscode-mumei
./install.sh
```

詳細は [vscode-mumei/INSTALL.md](vscode-mumei/INSTALL.md) を参照。

## 独自の拡張機能を作成

Mumei言語は拡張可能です。新しい組み込み関数を追加できます。

### 例: カスタム拡張の作成

1. **拡張モジュールを作成** (`mm_custom.py`):

```python
def setup_custom_builtins(env):
    """カスタム関数を追加"""

    def my_function(arg):
        return f"Custom: {arg}"

    env.define('my_function', my_function)
```

2. **インタプリタに統合** (`mm_interpreter.py`):

```python
# カスタム拡張をインポート
try:
    from mm_custom import setup_custom_builtins
    CUSTOM_AVAILABLE = True
except ImportError:
    CUSTOM_AVAILABLE = False

# setup_builtins()内で:
if CUSTOM_AVAILABLE:
    setup_custom_builtins(self.global_env)
```

3. **Mumeiコードで使用**:

```mu
let result = my_function("Hello");
print(result);  # "Custom: Hello"
```

## 今後の拡張予定

- [ ] HTTP/REST API クライアント
- [ ] データベース連携 (SQLite, PostgreSQL)
- [ ] ファイルI/O拡張
- [ ] JSON/YAML パーサー
- [ ] 正規表現サポート
- [ ] 日時処理
- [ ] 数学関数ライブラリ

## コントリビューション

拡張機能の作成やアイデアの共有を歓迎します！

GitHubで Issue や Pull Request を作成してください:
https://github.com/mume-dayo/mu-lang

## ライセンス

MIT License
