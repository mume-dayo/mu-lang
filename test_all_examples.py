#!/usr/bin/env python3
"""
全exampleファイルのテスト実行
"""

import os
import glob
import sys

# Mumeiインタプリタをインポート
sys.path.insert(0, os.path.dirname(__file__))
from mumei import run_file

def test_examples():
    """全exampleファイルをテスト"""

    examples_dir = "examples"
    example_files = sorted(glob.glob(f"{examples_dir}/*.mu"))

    print("="*70)
    print(f"Mumei Language - 全機能テスト ({len(example_files)} ファイル)")
    print("="*70)

    results = {
        "success": [],
        "failed": [],
        "skipped": []
    }

    # 実行をスキップするファイル（外部依存あり）
    skip_patterns = [
        "discord_",  # Discord API必要
        "http_",     # HTTP接続必要
        "file_io_",  # ファイルI/O（既に実装済みなら削除）
        "async_",    # async/await未実装
        "import_",   # import未実装
        "with_",     # with文未実装
        "generator_" # generator未実装
    ]

    for example_file in example_files:
        filename = os.path.basename(example_file)

        # スキップ判定
        should_skip = any(pattern in filename for pattern in skip_patterns)

        print(f"\n{'='*70}")
        print(f"テスト: {filename}")
        print(f"{'='*70}")

        if should_skip:
            print(f"⏭️  スキップ (外部依存または未実装機能)")
            results["skipped"].append(filename)
            continue

        try:
            print(f"実行中...")
            run_file(example_file)
            print(f"✅ 成功")
            results["success"].append(filename)
        except Exception as e:
            print(f"❌ エラー: {e}")
            results["failed"].append((filename, str(e)))

    # サマリー
    print("\n" + "="*70)
    print("テスト結果サマリー")
    print("="*70)
    print(f"✅ 成功: {len(results['success'])}")
    print(f"❌ 失敗: {len(results['failed'])}")
    print(f"⏭️  スキップ: {len(results['skipped'])}")

    if results["success"]:
        print(f"\n成功したテスト:")
        for name in results["success"]:
            print(f"  ✅ {name}")

    if results["failed"]:
        print(f"\n失敗したテスト:")
        for name, error in results["failed"]:
            print(f"  ❌ {name}")
            print(f"     エラー: {error[:100]}...")

    if results["skipped"]:
        print(f"\nスキップしたテスト:")
        for name in results["skipped"]:
            print(f"  ⏭️  {name}")

    print("\n" + "="*70)

    return len(results["failed"]) == 0

if __name__ == "__main__":
    success = test_examples()
    sys.exit(0 if success else 1)
