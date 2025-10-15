# 改善機能の簡易テスト

print("=== 1. プロパティのgetterテスト ===")

class Rectangle {
    fun __init__(self, width, height) {
        self._width = width
        self._height = height
    }

    @property
    fun width(self) {
        return self._width
    }

    @property
    fun area(self) {
        return self._width * self._height
    }
}

let rect = new Rectangle(10, 5)
print("Width:", rect.width)
print("Area:", rect.area)

print("")
print("=== 2. 型チェッカーテスト ===")

fun add(a: int, b: int) -> int {
    return a + b
}

print("10 + 20 =", add(10, 20))
print("Testing type mismatch:")
print("Result:", add("hello", "world"))

print("")
print("=== すべてのテスト完了 ===")
