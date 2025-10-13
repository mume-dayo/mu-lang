# Mumei言語 インストールガイド

## 必要要件

- Python 3.6以降

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd mumei-language
```

### 2. 実行権限の付与

```bash
chmod +x mumei
```

### 3. テスト実行

```bash
./mumei examples/hello.mu
```

## グローバルインストール（オプション）

どこからでも`mumei`コマンドを使用したい場合:

### macOS / Linux

#### 方法1: シンボリックリンク（推奨）

```bash
# /usr/local/binにシンボリックリンクを作成
sudo ln -s "$(pwd)/mumei" /usr/local/bin/mumei

# これで、どこからでもmumeiコマンドが使えます
mumei --version
```

#### 方法2: PATHに追加

```bash
# .bashrc, .zshrc, または .bash_profile に追加
echo 'export PATH="$PATH:/path/to/mumei-language"' >> ~/.zshrc

# 設定を再読み込み
source ~/.zshrc
```

### Windows

#### 方法1: PATHに追加

1. 「システムのプロパティ」→「環境変数」を開く
2. Path変数を編集し、mumei-languageディレクトリのパスを追加
3. コマンドプロンプトまたはPowerShellを再起動

#### 方法2: バッチファイルを作成

`mumei.bat`を作成し、PATHが通っているディレクトリに配置:

```batch
@echo off
python "C:\path\to\mumei-language\mumei" %*
```

## 動作確認

```bash
# バージョン確認
mumei --version

# ヘルプ表示
mumei --help

# サンプルプログラムの実行
mumei examples/hello.mu
mumei examples/fibonacci.mu
mumei examples/prime_numbers.mu

# REPL起動
mumei
```

## トラブルシューティング

### "Permission denied" エラー

実行権限がない場合:
```bash
chmod +x mumei
```

### "python3: command not found"

Pythonがインストールされていない場合:
- macOS: `brew install python3`
- Ubuntu/Debian: `sudo apt-get install python3`
- Windows: [python.org](https://www.python.org)からインストーラーをダウンロード

### "No module named 'mm_lexer'"

mumeiスクリプトと同じディレクトリに以下のファイルがあることを確認:
- `mm_lexer.py`
- `mm_parser.py`
- `mm_interpreter.py`

### REPLが起動しない

Python 3.6以降がインストールされているか確認:
```bash
python3 --version
```

## アンインストール

### シンボリックリンクを削除した場合

```bash
sudo rm /usr/local/bin/mumei
```

### リポジトリの削除

```bash
rm -rf /path/to/mumei-language
```

### PATHから削除

`.bashrc`や`.zshrc`からmumei-languageのPATH設定を削除し、再読み込み:
```bash
source ~/.zshrc
```
