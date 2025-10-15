# テスト: 新機能のテスト

print("=== 1. ジェネレーターのループテスト ===")

fun test_generator_for() {
    for (i in range(1, 4)) {
        yield i * 2
    }
}

let gen1 = test_generator_for()
for (val in gen1) {
    print("Generator (for):", val)
}

fun test_generator_while() {
    let i = 0
    while (i < 3) {
        yield i
        i = i + 1
    }
}

let gen2 = test_generator_while()
for (val in gen2) {
    print("Generator (while):", val)
}

print("")
print("=== 2. デコレーターテスト ===")

fun my_decorator(func) {
    print("Decorating function:", func)
    return func
}

@my_decorator
fun greet(name) {
    print("Hello,", name)
}

greet("World")

print("")
print("=== 3. 型アノテーションテスト ===")

fun add(a: int, b: int) -> int {
    return a + b
}

let result = add(10, 20)
print("add(10, 20) =", result)

print("")
print("=== 4. アサーションテスト ===")

assert 1 == 1
print("Assertion 1 passed")

assert 2 + 2 == 4, "Math is broken!"
print("Assertion 2 passed")

try {
    assert false, "This should fail"
} catch (e) {
    print("Caught assertion error:", e)
}

print("")
print("=== 5. Enumテスト ===")

enum Color {
    RED,
    GREEN,
    BLUE
}

print("Color.RED =", Color.RED)
print("Color.GREEN =", Color.GREEN)
print("Color.BLUE =", Color.BLUE)

print("")
print("=== 6. プロパティテスト ===")

class Person {
    fun __init__(self, name) {
        self.name = name
    }

    @property
    fun get_name(self) {
        return self.name
    }
}

let person = new Person("Alice")
print("Person name:", person.name)

print("")
print("=== すべてのテスト完了 ===")
