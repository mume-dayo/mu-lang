#!/bin/bash

# Rust実装のビルドスクリプト

echo "==================================="
echo "Mumei Rust Implementation Build"
echo "==================================="
echo ""

# Rustがインストールされているかチェック
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed!"
    echo ""
    echo "Please install Rust from: https://rustup.rs/"
    echo ""
    echo "Run this command:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo ""
    exit 1
fi

echo "✓ Rust is installed"
cargo --version
echo ""

# ビルドディレクトリへ移動
cd "mumei-rust" || exit 1

echo "Building Rust implementation..."
echo ""

# リリースビルド
cargo build --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "The compiled library is at:"
    echo "  mumei-rust/target/release/libmumei_rust.dylib (or .so on Linux)"
    echo ""
    echo "To install for Python, run:"
    echo "  maturin develop --release"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    exit 1
fi
