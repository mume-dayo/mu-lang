#!/usr/bin/env python3
import time
import mumei_rust

test_code = "2 + 3 * 4 - 5 / 2"
iterations = 10000

# Python組み込みeval
start = time.perf_counter()
for _ in range(iterations):
    eval(test_code)
end = time.perf_counter()
python_time = (end - start) / iterations

# Rust AST版
start = time.perf_counter()
for _ in range(iterations):
    mumei_rust.evaluate(test_code)
end = time.perf_counter()
rust_ast_time = (end - start) / iterations

# Rust バイトコード版（超高速）
start = time.perf_counter()
for _ in range(iterations):
    mumei_rust.evaluate_bytecode(test_code)
end = time.perf_counter()
rust_bytecode_time = (end - start) / iterations

print("=" * 60)
print("パフォーマンス比較")
print("=" * 60)
print(f"Python eval:          {python_time * 1_000_000:>8.2f}μs  (1.00x)")
print(f"Rust AST版:          {rust_ast_time * 1_000_000:>8.2f}μs  ({python_time/rust_ast_time:>4.2f}x)")
print(f"Rust バイトコード版: {rust_bytecode_time * 1_000_000:>8.2f}μs  ({python_time/rust_bytecode_time:>4.2f}x)")
print("=" * 60)
print(f"\n🚀 バイトコード版は Pythonより {python_time/rust_bytecode_time:.1f}倍 高速！")
print(f"🔥 バイトコード版は AST版より  {rust_ast_time/rust_bytecode_time:.1f}倍 高速！")
