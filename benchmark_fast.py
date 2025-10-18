#!/usr/bin/env python3
"""
超高速f64直接返却API のベンチマーク
"""

import time
import mumei_rust

print("Mumei - 超高速f64直接返却API ベンチマーク")
print("="*60)

# コンパイル
test_code = "2 + 3 * 4"
bytecode_id = mumei_rust.compile_to_bytecode(test_code)

# Python eval
iterations = 100_000
start = time.perf_counter()
for _ in range(iterations):
    eval("2 + 3 * 4")
end = time.perf_counter()
python_time = (end - start) / iterations * 1_000_000

# execute_bytecode (String返却)
start = time.perf_counter()
for _ in range(iterations):
    mumei_rust.execute_bytecode(bytecode_id)
end = time.perf_counter()
string_time = (end - start) / iterations * 1_000_000

# execute_bytecode_fast (f64直接返却)
start = time.perf_counter()
for _ in range(iterations):
    mumei_rust.execute_bytecode_fast(bytecode_id)
end = time.perf_counter()
fast_time = (end - start) / iterations * 1_000_000

print(f"\nテストコード: {test_code}")
print(f"実行回数: {iterations:,}\n")

print("結果:")
print(f"Python eval():              {python_time:.3f}μs")
print(f"Rust VM (String返却):       {string_time:.3f}μs ({python_time/string_time:.2f}x)")
print(f"Rust VM (f64直接返却):      {fast_time:.3f}μs ({python_time/fast_time:.2f}x)")

improvement = string_time / fast_time
print(f"\nf64直接返却の改善: {improvement:.2f}x")

if python_time / fast_time >= 5.0:
    print(f"\n✅ 5倍達成！ ({python_time/fast_time:.1f}x)")
elif python_time / fast_time >= 4.0:
    print(f"\n🟡 もう少し！ ({python_time/fast_time:.1f}x)")
else:
    print(f"\n現在: {python_time/fast_time:.1f}x")
