#!/usr/bin/env python3
"""
Python実装 vs Rust実装のパフォーマンスベンチマーク
"""

import time
import sys
from typing import Callable, List, Tuple

# ベンチマークテストケース
BENCHMARK_CASES = {
    "算術演算": "2 + 3 * 4 - 5 / 2",

    "変数代入": """
let x = 10
let y = 20
let z = x + y
z
""",

    "関数定義と呼び出し": """
fun add(a, b) {
    return a + b
}

fun multiply(a, b) {
    return a * b
}

let result = add(10, multiply(5, 3))
result
""",

    "ループ処理": """
let sum = 0
for (let i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
    sum = sum + i
}
sum
""",

    "リスト操作": """
let numbers = [1, 2, 3, 4, 5]
numbers[0] + numbers[1] + numbers[2] + numbers[3] + numbers[4]
""",

    "条件分岐": """
fun fib(n) {
    if (n <= 1) {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}
fib(10)
""",

    "複雑な式": """
let a = 10
let b = 20
let c = 30
(a + b) * c - (a * b) + (c / 2)
""",
}


def benchmark_function(func: Callable, iterations: int = 100) -> Tuple[float, float, float]:
    """
    関数のベンチマークを実行

    Returns:
        (平均時間, 最小時間, 最大時間) のタプル
    """
    times = []

    for _ in range(iterations):
        start = time.perf_counter()
        func()
        end = time.perf_counter()
        times.append(end - start)

    avg_time = sum(times) / len(times)
    min_time = min(times)
    max_time = max(times)

    return avg_time, min_time, max_time


def format_time(seconds: float) -> str:
    """時間を読みやすい形式にフォーマット"""
    if seconds < 0.000001:  # 1μs未満
        return f"{seconds * 1_000_000_000:.2f}ns"
    elif seconds < 0.001:  # 1ms未満
        return f"{seconds * 1_000_000:.2f}μs"
    elif seconds < 1:  # 1秒未満
        return f"{seconds * 1000:.2f}ms"
    else:
        return f"{seconds:.2f}s"


def benchmark_rust():
    """Rust実装のベンチマーク"""
    print("=" * 80)
    print("Rust実装のベンチマーク")
    print("=" * 80)

    try:
        import mumei_rust
    except ImportError:
        print("✗ mumei_rustモジュールがインポートできません")
        print("  maturin develop --release を実行してください")
        return None

    results = {}

    for name, code in BENCHMARK_CASES.items():
        print(f"\n{name}...", end=" ", flush=True)

        try:
            # ウォームアップ
            for _ in range(10):
                mumei_rust.evaluate(code)

            # 実際のベンチマーク
            avg, min_t, max_t = benchmark_function(lambda: mumei_rust.evaluate(code), iterations=100)

            results[name] = {
                "avg": avg,
                "min": min_t,
                "max": max_t,
            }

            print(f"平均: {format_time(avg)}, 最小: {format_time(min_t)}, 最大: {format_time(max_t)}")

        except Exception as e:
            print(f"エラー: {e}")
            results[name] = None

    return results


def benchmark_python():
    """Python実装のベンチマーク"""
    print("\n" + "=" * 80)
    print("Python実装のベンチマーク")
    print("=" * 80)

    try:
        # Python実装のインポートを試みる
        # 実際のインタプリタのインポートパスに応じて調整
        from mm_interpreter import Interpreter
        has_python_impl = True
    except ImportError:
        print("✗ Python実装が見つかりません")
        print("  Python実装のベンチマークはスキップします")
        return None

    results = {}

    for name, code in BENCHMARK_CASES.items():
        print(f"\n{name}...", end=" ", flush=True)

        try:
            # インタプリタのセットアップ
            def run_python():
                interpreter = Interpreter()
                interpreter.run(code)

            # ウォームアップ
            for _ in range(10):
                run_python()

            # 実際のベンチマーク
            avg, min_t, max_t = benchmark_function(run_python, iterations=100)

            results[name] = {
                "avg": avg,
                "min": min_t,
                "max": max_t,
            }

            print(f"平均: {format_time(avg)}, 最小: {format_time(min_t)}, 最大: {format_time(max_t)}")

        except Exception as e:
            print(f"エラー: {e}")
            results[name] = None

    return results


def print_comparison(rust_results, python_results):
    """結果の比較表を表示"""
    print("\n" + "=" * 80)
    print("パフォーマンス比較")
    print("=" * 80)

    if not rust_results:
        print("Rust実装の結果がありません")
        return

    if not python_results:
        print("\nPython実装の結果がないため、Rust実装の結果のみ表示します")
        print()
        print(f"{'テストケース':<25} {'平均時間':>15}")
        print("-" * 80)

        for name, result in rust_results.items():
            if result:
                print(f"{name:<25} {format_time(result['avg']):>15}")

        return

    # 比較表
    print()
    print(f"{'テストケース':<25} {'Python':>15} {'Rust':>15} {'高速化':>15}")
    print("-" * 80)

    speedups = []

    for name in rust_results.keys():
        rust_result = rust_results.get(name)
        python_result = python_results.get(name)

        if rust_result and python_result:
            rust_time = rust_result['avg']
            python_time = python_result['avg']
            speedup = python_time / rust_time
            speedups.append(speedup)

            print(f"{name:<25} {format_time(python_time):>15} {format_time(rust_time):>15} {speedup:>14.2f}x")
        elif rust_result:
            print(f"{name:<25} {'N/A':>15} {format_time(rust_result['avg']):>15} {'N/A':>15}")
        elif python_result:
            print(f"{name:<25} {format_time(python_result['avg']):>15} {'N/A':>15} {'N/A':>15}")

    if speedups:
        avg_speedup = sum(speedups) / len(speedups)
        print("-" * 80)
        print(f"{'平均高速化':<25} {'':<15} {'':<15} {avg_speedup:>14.2f}x")

        print("\n" + "=" * 80)
        print(f"結論: Rust実装はPython実装の平均 {avg_speedup:.2f}倍 高速です！")
        print("=" * 80)


def main():
    """メイン関数"""
    print()
    print("╔" + "═" * 78 + "╗")
    print("║" + " " * 20 + "Mumei言語パフォーマンスベンチマーク" + " " * 22 + "║")
    print("╚" + "═" * 78 + "╝")
    print()

    # Rust実装のベンチマーク
    rust_results = benchmark_rust()

    # Python実装のベンチマーク
    python_results = benchmark_python()

    # 比較表示
    print_comparison(rust_results, python_results)

    print("\n" + "=" * 80)
    print("ベンチマーク完了")
    print("=" * 80)


if __name__ == "__main__":
    main()
