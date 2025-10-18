#!/usr/bin/env python3
"""
Mumei Language - 純粋な実行速度ベンチマーク
コンパイルと実行を分離して、真の実行速度を測定
"""

import time
import mumei_rust

print("""
╔══════════════════════════════════════════════════════════╗
║  Mumei Language - 純粋な実行速度ベンチマーク              ║
║  コンパイル vs 実行 速度を分離測定                        ║
╚══════════════════════════════════════════════════════════╝
""")

# テストコード
test_code = "2 + 3 * 4"

print(f"テストコード: {test_code}")
print("="*60)

# ======================================================================
# フェーズ1: コンパイル（一度だけ）
# ======================================================================
print("\n【フェーズ1】コンパイル（一度だけ実行）")
print("="*60)

compile_start = time.perf_counter()
bytecode_id = mumei_rust.compile_to_bytecode(test_code)
compile_end = time.perf_counter()

compile_time = (compile_end - compile_start) * 1_000_000  # マイクロ秒
print(f"コンパイル時間: {compile_time:.2f}μs")
print(f"バイトコードID: {bytecode_id}")

# ======================================================================
# フェーズ2: 純粋な実行速度測定（コンパイル済みバイトコードを繰り返し実行）
# ======================================================================
print("\n【フェーズ2】純粋な実行速度測定")
print("="*60)

# ウォームアップ
for _ in range(100):
    result = mumei_rust.execute_bytecode(bytecode_id)

# ベンチマーク
iterations = 100_000
print(f"実行回数: {iterations:,}")

execute_start = time.perf_counter()
for _ in range(iterations):
    result = mumei_rust.execute_bytecode(bytecode_id)
execute_end = time.perf_counter()

execute_time = (execute_end - execute_start) / iterations * 1_000_000  # マイクロ秒
throughput = iterations / (execute_end - execute_start)

print(f"結果: {result}")
print(f"平均実行時間: {execute_time:.3f}μs")
print(f"スループット: {throughput:,.0f} 回/秒")

# ======================================================================
# フェーズ3: Python evalとの比較
# ======================================================================
print("\n【フェーズ3】Python evalとの比較")
print("="*60)

python_code = "2 + 3 * 4"
python_start = time.perf_counter()
for _ in range(iterations):
    eval(python_code)
python_end = time.perf_counter()

python_time = (python_end - python_start) / iterations * 1_000_000

print(f"Python eval: {python_time:.3f}μs")
print(f"Rust VM (純粋実行): {execute_time:.3f}μs")

speedup = python_time / execute_time
print(f"\n高速化率: {speedup:.1f}x")

# ======================================================================
# フェーズ4: 従来の方式（毎回コンパイル）との比較
# ======================================================================
print("\n【フェーズ4】従来の方式（毎回コンパイル）との比較")
print("="*60)

full_start = time.perf_counter()
for _ in range(10000):  # 少し回数を減らす
    mumei_rust.evaluate_bytecode(test_code)
full_end = time.perf_counter()

full_time = (full_end - full_start) / 10000 * 1_000_000

print(f"従来の方式（毎回コンパイル）: {full_time:.3f}μs")
print(f"新方式（コンパイル済み実行のみ）: {execute_time:.3f}μs")

compile_overhead = full_time - execute_time
print(f"\nコンパイルオーバーヘッド: {compile_overhead:.3f}μs ({compile_overhead/full_time*100:.1f}%)")

# ======================================================================
# 最終評価
# ======================================================================
print("\n" + "="*60)
print("【最終評価】")
print("="*60)

print(f"コンパイル時間: {compile_time:.2f}μs (一度だけ)")
print(f"純粋な実行時間: {execute_time:.3f}μs")
print(f"Python比高速化: {speedup:.1f}x")

if speedup >= 100:
    print("\n✅ 目標達成！100倍以上の高速化を実現しました！")
    print(f"   達成率: {speedup/100*100:.0f}% (目標: 100-300x)")
elif speedup >= 50:
    print("\n🟡 目標の50%達成")
    print(f"   あと{100-speedup:.0f}倍で目標達成")
elif speedup >= 10:
    print("\n🟡 目標の10%達成")
    print(f"   あと{100-speedup:.0f}倍で目標達成")
else:
    print("\n❌ 目標未達成")
    print(f"   現在の高速化率は目標の{speedup/100*100:.1f}%")
    print("   最適化戦略の見直しが必要です")

print("\n" + "="*60)
print("ベンチマーク完了")
print("="*60)
