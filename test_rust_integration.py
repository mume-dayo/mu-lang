#!/usr/bin/env python3
"""
Rust実装の統合テスト
mumei_rustモジュールが正しく動作するかをテストします
"""

import sys

def test_import():
    """Rustモジュールのインポートテスト"""
    print("=" * 60)
    print("1. Rustモジュールのインポートテスト")
    print("=" * 60)

    try:
        import mumei_rust
        print("✓ mumei_rustモジュールのインポート成功")
        print(f"  バージョン: {mumei_rust.__version__}")
        print(f"  作者: {mumei_rust.__author__}")
        return True
    except ImportError as e:
        print(f"✗ mumei_rustモジュールのインポート失敗: {e}")
        print("\nRustモジュールをビルドしてください：")
        print("  cd mumei-rust")
        print("  maturin develop --release")
        return False

def test_tokenize():
    """トークン化のテスト"""
    print("\n" + "=" * 60)
    print("2. トークン化テスト")
    print("=" * 60)

    try:
        import mumei_rust

        # 簡単なコード
        source = "let x = 42"
        tokens = mumei_rust.tokenize(source)

        print(f"ソースコード: {source}")
        print(f"トークン数: {len(tokens)}")
        print("トークン:")
        for token in tokens[:5]:  # 最初の5個だけ表示
            print(f"  {token}")

        # トークン数の検証
        if len(tokens) >= 4:
            print("✓ トークン化成功")
            return True
        else:
            print("✗ トークン数が不正")
            return False

    except Exception as e:
        print(f"✗ トークン化エラー: {e}")
        return False

def test_parse():
    """パースのテスト"""
    print("\n" + "=" * 60)
    print("3. パーステスト")
    print("=" * 60)

    try:
        import mumei_rust

        # 関数定義
        source = """
fun add(a, b) {
    return a + b
}
"""
        ast = mumei_rust.parse(source)

        print(f"ソースコード: {source.strip()}")
        print(f"AST長: {len(ast)}")
        print("✓ パース成功")
        return True

    except Exception as e:
        print(f"✗ パースエラー: {e}")
        return False

def test_parse_pretty():
    """整形されたパース出力のテスト"""
    print("\n" + "=" * 60)
    print("4. 整形パース出力テスト")
    print("=" * 60)

    try:
        import mumei_rust

        source = "let x = 10 + 20"
        ast_pretty = mumei_rust.parse_pretty(source)

        print(f"ソースコード: {source}")
        print("整形されたAST:")
        print(ast_pretty[:200])  # 最初の200文字だけ
        print("...")
        print("✓ 整形パース成功")
        return True

    except Exception as e:
        print(f"✗ 整形パースエラー: {e}")
        return False

def test_evaluate():
    """評価のテスト"""
    print("\n" + "=" * 60)
    print("5. 評価テスト")
    print("=" * 60)

    tests = [
        ("2 + 3", "5"),
        ("10 - 4", "6"),
        ("5 * 6", "30"),
        ("20 / 4", "5"),
        ("2 ** 8", "256"),
        ('"Hello, " + "World"', "Hello, World"),
        ("let x = 42\nx", "42"),
    ]

    try:
        import mumei_rust

        passed = 0
        failed = 0

        for source, expected in tests:
            try:
                result = mumei_rust.evaluate(source)

                # 数値の場合は浮動小数点を考慮
                if expected.replace('.', '').replace('-', '').isdigit():
                    expected_num = float(expected)
                    result_num = float(result)
                    if abs(expected_num - result_num) < 0.0001:
                        print(f"✓ {source:30} => {result}")
                        passed += 1
                    else:
                        print(f"✗ {source:30} => {result} (期待値: {expected})")
                        failed += 1
                else:
                    if result == expected:
                        print(f"✓ {source:30} => {result}")
                        passed += 1
                    else:
                        print(f"✗ {source:30} => {result} (期待値: {expected})")
                        failed += 1

            except Exception as e:
                print(f"✗ {source:30} => エラー: {e}")
                failed += 1

        print(f"\n合計: {passed}個成功, {failed}個失敗")
        return failed == 0

    except Exception as e:
        print(f"✗ 評価エラー: {e}")
        return False

def test_complex_code():
    """複雑なコードのテスト"""
    print("\n" + "=" * 60)
    print("6. 複雑なコードテスト")
    print("=" * 60)

    try:
        import mumei_rust

        # 関数定義と呼び出し
        source = """
fun add(a, b) {
    return a + b
}

let result = add(10, 20)
result
"""
        result = mumei_rust.evaluate(source)
        print(f"関数呼び出し: add(10, 20) => {result}")

        if result == "30" or result == "30.0":
            print("✓ 関数呼び出し成功")
        else:
            print(f"✗ 予期しない結果: {result}")
            return False

        # リスト
        source = "[1, 2, 3][1]"
        result = mumei_rust.evaluate(source)
        print(f"リストアクセス: [1, 2, 3][1] => {result}")

        # 条件分岐
        source = """
let x = 10
if (x > 5) {
    100
} else {
    200
}
"""
        result = mumei_rust.evaluate(source)
        print(f"条件分岐: if (x > 5) => {result}")

        print("✓ 複雑なコード実行成功")
        return True

    except Exception as e:
        print(f"✗ 複雑なコード実行エラー: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_error_handling():
    """エラーハンドリングのテスト"""
    print("\n" + "=" * 60)
    print("7. エラーハンドリングテスト")
    print("=" * 60)

    try:
        import mumei_rust

        # 構文エラー
        try:
            mumei_rust.parse("let x = ")
            print("✗ 構文エラーが検出されませんでした")
            return False
        except Exception as e:
            print(f"✓ 構文エラー検出: {type(e).__name__}")

        # 実行時エラー
        try:
            mumei_rust.evaluate("undefined_variable")
            print("✗ 未定義変数エラーが検出されませんでした")
            return False
        except Exception as e:
            print(f"✓ 実行時エラー検出: {type(e).__name__}")

        print("✓ エラーハンドリング正常")
        return True

    except Exception as e:
        print(f"✗ エラーハンドリングテストエラー: {e}")
        return False

def main():
    """メイン関数"""
    print("\n")
    print("╔" + "═" * 58 + "╗")
    print("║" + " " * 10 + "Mumei Rust実装 統合テスト" + " " * 22 + "║")
    print("╚" + "═" * 58 + "╝")
    print()

    results = []

    # テスト実行
    results.append(("インポート", test_import()))

    # インポートに失敗したら終了
    if not results[0][1]:
        print("\n" + "=" * 60)
        print("テスト中断: Rustモジュールがインポートできません")
        print("=" * 60)
        return False

    results.append(("トークン化", test_tokenize()))
    results.append(("パース", test_parse()))
    results.append(("整形パース", test_parse_pretty()))
    results.append(("評価", test_evaluate()))
    results.append(("複雑なコード", test_complex_code()))
    results.append(("エラーハンドリング", test_error_handling()))

    # サマリー
    print("\n" + "=" * 60)
    print("テスト結果サマリー")
    print("=" * 60)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for name, result in results:
        status = "✓" if result else "✗"
        print(f"{status} {name}")

    print("=" * 60)
    print(f"合計: {passed}/{total} テスト成功")
    print("=" * 60)

    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
