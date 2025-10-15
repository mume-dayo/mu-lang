# 改善機能のテスト

print("=== 1. プロパティのgetter/setterテスト ===")

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

fun divide(a: int, b: int) -> float {
    return a / b
}

print("10 / 3 =", divide(10, 3))

# 型エラー（警告のみ）
print("Testing type error (warning only):")
let result = divide("hello", "world")  # これは型警告を出すはず

print("")
print("=== 3. デコレーター引数テスト ===")

fun repeat(times) {
    fun decorator(func) {
        fun wrapper(*args) {
            let i = 0
            while (i < times) {
                func(*args)
                i = i + 1
            }
        }
        return wrapper
    }
    return decorator
}

@repeat(3)
fun greet(name) {
    print("Hello,", name, "!")
}

greet("Alice")

print("")
print("=== すべてのテスト完了 ===")
