# 型チェッカーのみテスト

print("=== 型チェッカーテスト ===")

fun add(a: int, b: int) -> int {
    return a + b
}

print("10 + 20 =", add(10, 20))

print("")
print("Testing type mismatch:")
let result = add("hello", "world")
print("Result:", result)

print("")
print("Done")
