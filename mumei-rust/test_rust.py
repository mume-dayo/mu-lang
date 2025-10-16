#!/usr/bin/env python3
"""
Mumei-Rust テストスクリプト
ビルド後にRust実装が正しく動作するかテストします
"""

def test_import():
    """モジュールのインポートテスト"""
    try:
        import mumei_rust
        print("✅ mumei_rustモジュールのインポート成功")
        print(f"   バージョン: {mumei_rust.__version__}")
        return True
    except ImportError as e:
        print(f"❌ インポート失敗: {e}")
        print("\n以下のコマンドでビルドしてください:")
        print("  ./build.sh")
        return False


def test_tokenize():
    """トークン化のテスト"""
    import mumei_rust

    test_cases = [
        ("let x = 42", ["Let", "Identifier", "Assign", "Number", "Eof"]),
        ("fun add(a, b) { return a + b }", None),  # 構造だけチェック
        ('"hello world"', ["String", "Eof"]),
        ("if x > 10 { print(x) }", None),
    ]

    all_passed = True

    for i, (source, expected) in enumerate(test_cases, 1):
        try:
            tokens = mumei_rust.tokenize(source)

            if expected:
                token_types = [t.token_type for t in tokens]
                if token_types == expected:
                    print(f"✅ テスト {i} 成功: {source[:30]}")
                else:
                    print(f"❌ テスト {i} 失敗: {source[:30]}")
                    print(f"   期待: {expected}")
                    print(f"   実際: {token_types}")
                    all_passed = False
            else:
                # トークン数だけチェック
                if len(tokens) > 0:
                    print(f"✅ テスト {i} 成功: {source[:30]} ({len(tokens)} tokens)")
                else:
                    print(f"❌ テスト {i} 失敗: トークンが生成されませんでした")
                    all_passed = False

        except Exception as e:
            print(f"❌ テスト {i} エラー: {e}")
            all_passed = False

    return all_passed


def test_error_handling():
    """エラーハンドリングのテスト"""
    import mumei_rust

    # 不正な構文でエラーが発生することを確認
    try:
        tokens = mumei_rust.tokenize("let x = !invalid")
        print("❌ エラーハンドリング失敗: 例外が発生すべきでした")
        return False
    except Exception:
        print("✅ エラーハンドリング成功: 不正な構文でエラーを検出")
        return True


def test_performance():
    """パフォーマンステスト（簡易版）"""
    import mumei_rust
    import time

    # テストコード
    source = """
fun fibonacci(n) {
    if n <= 1 {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

let result = fibonacci(10)
print(result)
""" * 100  # 100回繰り返し

    start = time.time()
    tokens = mumei_rust.tokenize(source)
    elapsed = time.time() - start

    print(f"✅ パフォーマンステスト完了")
    print(f"   ソースサイズ: {len(source)} 文字")
    print(f"   トークン数: {len(tokens)}")
    print(f"   処理時間: {elapsed:.4f}秒")
    print(f"   スループット: {len(source) / elapsed:.0f} 文字/秒")

    return True


def main():
    print("=" * 60)
    print("Mumei-Rust テストスイート")
    print("=" * 60)
    print()

    # インポートテスト
    if not test_import():
        return 1

    print()

    # トークン化テスト
    print("トークン化テスト:")
    print("-" * 60)
    test_tokenize()
    print()

    # エラーハンドリングテスト
    print("エラーハンドリングテスト:")
    print("-" * 60)
    test_error_handling()
    print()

    # パフォーマンステスト
    print("パフォーマンステスト:")
    print("-" * 60)
    test_performance()
    print()

    print("=" * 60)
    print("すべてのテスト完了")
    print("=" * 60)

    return 0


if __name__ == "__main__":
    exit(main())
