#!/usr/bin/env python3
"""
Mumei Language - 最適化レイヤーのベンチマーク
AST、バイトコード、JITの性能比較
"""

import time
import mumei_rust

# テストコード（簡単な算術演算）
test_code_simple = "2 + 3 * 4"
test_code_complex = """
let x = 10
let y = 20
let z = x + y * 2
z
"""

# フィボナッチ数列（計算量が大きい）
test_code_fib = """
fun fib(n) {
    if (n <= 1) {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}
fib(10)
"""

def benchmark(name, func, code, iterations=10000):
    """ベンチマーク実行"""
    print(f"\n{'='*60}")
    print(f"テスト: {name}")
    print(f"{'='*60}")
    print(f"コード: {code[:50]}..." if len(code) > 50 else f"コード: {code}")

    # ウォームアップ
    try:
        result = func(code)
        print(f"結果: {result}")
    except Exception as e:
        print(f"エラー: {e}")
        return None

    # ベンチマーク
    start = time.perf_counter()
    for _ in range(iterations):
        try:
            func(code)
        except Exception:
            pass
    end = time.perf_counter()

    total_time = end - start
    avg_time = total_time / iterations * 1_000_000  # マイクロ秒
    throughput = iterations / total_time

    print(f"実行回数: {iterations:,}")
    print(f"総実行時間: {total_time:.3f}秒")
    print(f"平均実行時間: {avg_time:.2f}μs")
    print(f"スループット: {throughput:,.0f} 回/秒")

    return avg_time

def main():
    print("""
    ╔══════════════════════════════════════════════════════════╗
    ║  Mumei Language - 最適化パフォーマンスベンチマーク        ║
    ║  目標: Python比 100-300倍高速化                          ║
    ╚══════════════════════════════════════════════════════════╝
    """)

    # Python eval ベースライン（参考用）
    print("\n" + "="*60)
    print("【ベースライン】Python eval()")
    print("="*60)
    python_code = "2 + 3 * 4"
    start = time.perf_counter()
    for _ in range(10000):
        eval(python_code)
    end = time.perf_counter()
    python_time = (end - start) / 10000 * 1_000_000
    print(f"平均実行時間: {python_time:.2f}μs")

    # 簡単な算術演算のベンチマーク
    print("\n" + "="*60)
    print("【テスト1】簡単な算術演算: 2 + 3 * 4")
    print("="*60)

    results = {}

    # AST評価
    ast_time = benchmark(
        "AST評価 (evaluate)",
        mumei_rust.evaluate,
        test_code_simple,
        10000
    )
    if ast_time:
        results['AST'] = ast_time

    # バイトコード評価
    bytecode_time = benchmark(
        "バイトコード評価 (evaluate_bytecode)",
        mumei_rust.evaluate_bytecode,
        test_code_simple,
        10000
    )
    if bytecode_time:
        results['Bytecode'] = bytecode_time

    # JIT評価
    jit_time = benchmark(
        "JIT評価 (evaluate_jit)",
        mumei_rust.evaluate_jit,
        test_code_simple,
        10000
    )
    if jit_time:
        results['JIT'] = jit_time

    # 結果サマリー
    print("\n" + "="*60)
    print("【結果サマリー】")
    print("="*60)
    print(f"Python eval:       {python_time:.2f}μs (ベースライン)")

    for name, time_val in results.items():
        speedup = python_time / time_val
        print(f"{name:15s}: {time_val:.2f}μs ({speedup:.2f}x faster than Python)")

    # 複雑なコードのベンチマーク
    print("\n" + "="*60)
    print("【テスト2】変数と演算")
    print("="*60)

    benchmark("AST評価", mumei_rust.evaluate, test_code_complex, 5000)
    benchmark("バイトコード評価", mumei_rust.evaluate_bytecode, test_code_complex, 5000)

    # まとめ
    print("\n" + "="*60)
    print("【最終評価】")
    print("="*60)

    if results:
        best_name = min(results, key=results.get)
        best_time = results[best_name]
        best_speedup = python_time / best_time

        print(f"最速の実装: {best_name}")
        print(f"実行時間: {best_time:.2f}μs")
        print(f"Python比高速化: {best_speedup:.2f}x")
        print(f"目標達成率: {best_speedup / 100 * 100:.1f}% (目標: 100-300x)")

        if best_speedup >= 100:
            print("\n✅ 目標達成！100倍以上の高速化を実現しました！")
        elif best_speedup >= 50:
            print("\n⚠️  目標の50%達成。さらなる最適化が必要です。")
        elif best_speedup >= 10:
            print("\n⚠️  目標の10%達成。大幅な最適化が必要です。")
        else:
            print("\n❌ 目標未達成。最適化戦略の見直しが必要です。")

    print("\n" + "="*60)
    print("ベンチマーク完了")
    print("="*60)

if __name__ == "__main__":
    main()
