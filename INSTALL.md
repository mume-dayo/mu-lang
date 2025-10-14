# VSCode拡張機能のインストール方法

Mumei言語のシンタックスハイライトをVSCodeに追加する方法です。

## 方法1: 手動インストール（簡単・推奨）

### macOS / Linux

```bash
# vscode-mumeiディレクトリをVSCodeの拡張機能フォルダにコピー
cp -r vscode-mumei ~/.vscode/extensions/mumei-language-1.0.0

# VSCodeを再起動
```

### Windows (PowerShell)

```powershell
# vscode-mumeiディレクトリをVSCodeの拡張機能フォルダにコピー
Copy-Item -Recurse vscode-mumei "$env:USERPROFILE\.vscode\extensions\mumei-language-1.0.0"

# VSCodeを再起動
```

### Windows (コマンドプロンプト)

```cmd
# vscode-mumeiディレクトリをVSCodeの拡張機能フォルダにコピー
xcopy /E /I vscode-mumei "%USERPROFILE%\.vscode\extensions\mumei-language-1.0.0"

# VSCodeを再起動
```

## 方法2: VSIXファイルから（パッケージ化する場合）

### VSIXファイルの作成

```bash
# vsce (Visual Studio Code Extension) ツールをインストール
npm install -g vsce

# VSIXファイルを作成
cd vscode-mumei
vsce package

# mumei-language-1.0.0.vsix が作成されます
```

### VSIXファイルのインストール

1. VSCodeを開く
2. `Cmd+Shift+P` (Mac) または `Ctrl+Shift+P` (Windows/Linux) を押す
3. "Install from VSIX" と入力して選択
4. 作成した `.vsix` ファイルを選択
5. VSCodeを再起動

## インストール確認

1. `.mu` ファイルを開く（例: `examples/hello.mu`）
2. コードに色が付いていれば成功！

### テスト用のファイル

`test.mu` を作成してテスト:

```mu
# コメントは緑色
let x = 10;  # letはキーワード（紫色）

fun hello(name) {  # funもキーワード
    return "Hello, " + name;
}

# 組み込み関数は青色
print(hello("World"));

# Discord関数も青色
discord_create_bot("!");

# 文字列は赤/オレンジ色
let message = "This is a string";

# 数値は緑/青色
let number = 42;
let pi = 3.14;

# 真偽値と定数は青色
let is_true = true;
let is_false = false;
let nothing = none;
```

## トラブルシューティング

### 色が付かない場合

1. **拡張機能が有効か確認**
   - VSCodeの左サイドバーで拡張機能アイコンをクリック
   - "Mumei Language Support" を検索
   - 有効になっているか確認

2. **ファイル拡張子を確認**
   - ファイルが `.mu` で終わっているか確認
   - VSCodeの右下を見て "Mumei" と表示されているか確認

3. **手動で言語モードを設定**
   - VSCodeの右下の言語表示をクリック
   - "Mumei" を選択

4. **VSCodeを再起動**
   - VSCodeを完全に終了して再起動

5. **拡張機能フォルダのパスを確認**
   - macOS/Linux: `~/.vscode/extensions/`
   - Windows: `%USERPROFILE%\.vscode\extensions\`
   - フォルダ名は `mumei-language-1.0.0` である必要があります

### エラーが出る場合

拡張機能のログを確認:
1. `Cmd+Shift+P` (Mac) または `Ctrl+Shift+P` (Windows/Linux)
2. "Developer: Show Logs" と入力
3. "Extension Host" を選択

## アンインストール

### 方法1: VSCode UIから

1. VSCodeの拡張機能ビューを開く
2. "Mumei Language Support" を検索
3. アンインストールボタンをクリック

### 方法2: 手動削除

```bash
# macOS/Linux
rm -rf ~/.vscode/extensions/mumei-language-1.0.0

# Windows (PowerShell)
Remove-Item -Recurse "$env:USERPROFILE\.vscode\extensions\mumei-language-1.0.0"
```

## カスタマイズ

### 色をカスタマイズしたい場合

VSCodeの `settings.json` に追加:

```json
{
  "editor.tokenColorCustomizations": {
    "textMateRules": [
      {
        "scope": "keyword.control.mumei",
        "settings": {
          "foreground": "#C586C0",
          "fontStyle": "bold"
        }
      },
      {
        "scope": "support.function.builtin.mumei",
        "settings": {
          "foreground": "#4EC9B0",
          "fontStyle": "italic"
        }
      }
    ]
  }
}
```

## 次のステップ

- [README.md](README.md) - 拡張機能の詳細
- [../README.md](../README.md) - Mumei言語のドキュメント
- [../examples/](../examples/) - サンプルコード

Happy coding with Mumei! 🚀
