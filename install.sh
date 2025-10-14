#!/bin/bash
# Mumei VSCode拡張機能 インストールスクリプト

set -e

EXTENSION_NAME="mumei-language-1.0.0"
VSCODE_EXTENSIONS_DIR="$HOME/.vscode/extensions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "Mumei VSCode Extension Installer"
echo "========================================"
echo ""

# VSCodeがインストールされているかチェック
if ! command -v code &> /dev/null; then
    echo "⚠️  Warning: 'code' command not found."
    echo "   VSCode might not be installed or not in PATH."
    echo "   Continuing anyway..."
    echo ""
fi

# 拡張機能ディレクトリを作成
if [ ! -d "$VSCODE_EXTENSIONS_DIR" ]; then
    echo "📁 Creating extensions directory..."
    mkdir -p "$VSCODE_EXTENSIONS_DIR"
fi

# 既存の拡張機能を削除
if [ -d "$VSCODE_EXTENSIONS_DIR/$EXTENSION_NAME" ]; then
    echo "🗑️  Removing existing extension..."
    rm -rf "$VSCODE_EXTENSIONS_DIR/$EXTENSION_NAME"
fi

# 拡張機能をコピー
echo "📦 Installing extension..."
cp -r "$SCRIPT_DIR" "$VSCODE_EXTENSIONS_DIR/$EXTENSION_NAME"

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart VSCode"
echo "  2. Open a .mu file"
echo "  3. Enjoy syntax highlighting!"
echo ""
echo "Test with:"
echo "  code ../examples/hello.mu"
echo ""
echo "========================================"
