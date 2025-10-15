# ジェネレーターの詳細テスト

print("=== 1. 基本的なfor内のyield ===")
fun test_basic_for() {
    for (i in range(1, 4)) {
        yield i * 2
    }
}

let gen1 = test_basic_for()
for (val in gen1) {
    print("Value:", val)
}

print("")
print("=== 2. while内のyield ===")
fun test_while() {
    let i = 0
    while (i < 3) {
        yield i * i
        i = i + 1
    }
}

let gen2 = test_while()
for (val in gen2) {
    print("Value:", val)
}

print("")
print("=== 3. if文とyield ===")
fun test_if() {
    for (i in range(1, 6)) {
        if (i % 2 == 0) {
            yield i
        }
    }
}

let gen3 = test_if()
for (val in gen3) {
    print("Even:", val)
}

print("")
print("=== 4. ネストしたループ ===")
fun test_nested() {
    for (i in range(1, 3)) {
        for (j in range(1, 3)) {
            yield i * 10 + j
        }
    }
}

let gen4 = test_nested()
for (val in gen4) {
    print("Nested:", val)
}

print("")
print("=== すべてのテスト完了 ===")
