# Mumei言語でのジェネレーターとyield
# 使い方: mumei generator_example.mu

print("=== ジェネレーターとyieldの例 ===");
print("");

# 例1: シンプルなジェネレーター
print("1. シンプルなジェネレーター");
fun count_up_to(n) {
    let i = 0;
    while (i < n) {
        yield i;
        i = i + 1;
    }
}

let gen = count_up_to(5);
for (val in gen) {
    print("  値:", val);
}
print("");

# 例2: フィボナッチ数列ジェネレーター
print("2. フィボナッチ数列ジェネレーター");
fun fibonacci(n) {
    let a = 0;
    let b = 1;
    let count = 0;

    while (count < n) {
        yield a;
        let temp = a + b;
        a = b;
        b = temp;
        count = count + 1;
    }
}

for (num in fibonacci(10)) {
    print("  フィボナッチ:", num);
}
print("");

# 例3: 大きな範囲のカウンター
print("3. 大きな範囲のカウンター（最初の5個だけ取得）");
fun large_counter(max) {
    let i = 0;
    while (i < max) {
        yield i;
        i = i + 1;
    }
}

let counter = large_counter(1000);
let count = 0;
for (val in counter) {
    print("  カウント:", val);
    count = count + 1;
    if (count >= 5) {
        break;
    }
}
print("");

# 例4: 範囲ジェネレーター
print("4. 範囲ジェネレーター（カスタムrange）");
fun my_range(start, end, step) {
    let current = start;
    if (step > 0) {
        while (current < end) {
            yield current;
            current = current + step;
        }
    } else {
        while (current > end) {
            yield current;
            current = current + step;
        }
    }
}

print("  0から10まで2ずつ:");
for (val in my_range(0, 10, 2)) {
    print("    ", val);
}

print("  10から0まで-1ずつ:");
for (val in my_range(10, 0, -1)) {
    print("    ", val);
}
print("");

# 例5: リストの要素を1つずつ返すジェネレーター
print("5. リストイテレータージェネレーター");
fun iterate_list(lst) {
    for (item in lst) {
        yield item;
    }
}

let fruits = ["りんご", "バナナ", "オレンジ", "ぶどう"];
for (fruit in iterate_list(fruits)) {
    print("  果物:", fruit);
}
print("");

# 例6: フィルタリングジェネレーター
print("6. 偶数だけを返すジェネレーター");
fun even_numbers(n) {
    let i = 0;
    while (i <= n) {
        if (i % 2 == 0) {
            yield i;
        }
        i = i + 1;
    }
}

for (num in even_numbers(10)) {
    print("  偶数:", num);
}
print("");

# 例7: 素数ジェネレーター
print("7. 素数ジェネレーター");
fun is_prime(n) {
    if (n < 2) {
        return false;
    }
    let i = 2;
    while (i * i <= n) {
        if (n % i == 0) {
            return false;
        }
        i = i + 1;
    }
    return true;
}

fun prime_numbers(max) {
    let n = 2;
    while (n <= max) {
        if (is_prime(n)) {
            yield n;
        }
        n = n + 1;
    }
}

print("  30以下の素数:");
for (prime in prime_numbers(30)) {
    print("    ", prime);
}
print("");

# 例8: 文字列を1文字ずつ返すジェネレーター
print("8. 文字列イテレーター");
fun char_iterator(text) {
    for (char in text) {
        yield char;
    }
}

for (char in char_iterator("Hello")) {
    print("  文字:", char);
}
print("");

# 例9: ペアジェネレーター
print("9. ペアジェネレーター");
fun pairs(n) {
    let i = 0;
    while (i < n) {
        yield [i, i * i];
        i = i + 1;
    }
}

for (pair in pairs(5)) {
    print("  ペア:", pair[0], "->", pair[1]);
}
print("");

# 例10: ジェネレーターを使った累積和
print("10. 累積和ジェネレーター");
fun cumulative_sum(numbers) {
    let total = 0;
    for (num in numbers) {
        total = total + num;
        yield total;
    }
}

let nums = [1, 2, 3, 4, 5];
print("  元のリスト:", nums);
print("  累積和:");
for (sum in cumulative_sum(nums)) {
    print("    ", sum);
}
print("");

# 例11: 繰り返しジェネレーター
print("11. 要素を繰り返すジェネレーター");
fun repeat(value, times) {
    let count = 0;
    while (count < times) {
        yield value;
        count = count + 1;
    }
}

for (val in repeat("*", 5)) {
    print("  ", val);
}
print("");

# 例12: ジェネレーターチェーン
print("12. 2つのジェネレーターを繋げる");
fun chain(gen1, gen2) {
    for (val in gen1) {
        yield val;
    }
    for (val in gen2) {
        yield val;
    }
}

let gen1 = count_up_to(3);
let gen2 = count_up_to(3);
for (val in chain(gen1, gen2)) {
    print("  値:", val);
}
print("");

print("=== ジェネレーターのメリット ===");
print("1. 簡潔な記述: 複雑なイテレーターを簡単に実装");
print("2. 状態の保持: 関数内の変数が自動的に保存される");
print("3. 大きなデータ処理: メモリ効率の良いデータ処理");
print("4. パイプライン処理: データ変換を段階的に適用");
