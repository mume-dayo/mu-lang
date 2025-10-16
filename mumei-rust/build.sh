#!/bin/bash
# Mumei-Rust ビルドスクリプト

set -e

echo "🦀 Mumei-Rust ビルド開始"
echo ""

# Rustがインストールされているかチェック
if ! command -v cargo &> /dev/null; then
    echo "❌ Rustがインストールされていません"
    echo ""
    echo "以下のコマンドでインストールしてください:"
    echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

echo "✅ Rust バージョン: $(cargo --version)"

# maturinがインストールされているかチェック
if ! command -v maturin &> /dev/null; then
    echo "❌ maturinがインストールされていません"
    echo ""
    echo "以下のコマンドでインストールしてください:"
    echo "pip install maturin"
    exit 1
fi

echo "✅ maturin バージョン: $(maturin --version)"
echo ""

# ビルドタイプの選択
BUILD_TYPE=${1:-"dev"}

if [ "$BUILD_TYPE" = "release" ]; then
    echo "🚀 リリースビルド（最適化有効）"
    maturin develop --release
elif [ "$BUILD_TYPE" = "wheel" ]; then
    echo "📦 Wheelパッケージ作成"
    maturin build --release
else
    echo "🔧 開発ビルド（デバッグ情報有効）"
    maturin develop
fi

echo ""
echo "✅ ビルド完了!"
echo ""
echo "使い方:"
echo "  python3 -c 'import mumei_rust; print(mumei_rust.__version__)'"
echo ""
