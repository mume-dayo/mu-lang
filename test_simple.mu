# 簡易テスト

print("=== デコレーターテスト ===")

fun my_decorator(func) {
    print("Decorating:", func)
    return func
}

@my_decorator
fun greet(name) {
    return "Hello, " + name
}

print(greet("World"))

print("")
print("=== 型アノテーションテスト ===")

fun add(a: int, b: int) -> int {
    return a + b
}

print("add(10, 20) =", add(10, 20))

print("")
print("=== アサーションテスト ===")

assert 1 == 1
print("Assertion passed")

print("")
print("=== Enumテスト ===")

enum Color {
    RED,
    GREEN,
    BLUE
}

print("Color.RED =", Color.RED)
print("Color.GREEN =", Color.GREEN)

print("")
print("=== 完了 ===")
