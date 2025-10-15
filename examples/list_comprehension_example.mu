# Mumei言語のリスト内包表記の例
# 使い方: mumei list_comprehension_example.mu

print("=== Mumei List Comprehension Demo ===");
print("");

# 1. 基本的なリスト内包表記
print("1. Basic list comprehension:");
let squares = [x * x for (x in range(1, 11))];
print("  Squares of 1-10: " + str(squares));

let doubled = [n * 2 for (n in [1, 2, 3, 4, 5])];
print("  Doubled: " + str(doubled));
print("");

# 2. 条件付きリスト内包表記
print("2. List comprehension with condition:");
let evens = [x for (x in range(1, 21)) if (x % 2 == 0)];
print("  Even numbers 1-20: " + str(evens));

let odds = [x for (x in range(1, 21)) if (x % 2 != 0)];
print("  Odd numbers 1-20: " + str(odds));
print("");

# 3. 複雑な式を使った内包表記
print("3. Complex expressions:");
let transformed = [x * 2 + 1 for (x in range(1, 6))];
print("  x * 2 + 1 for x in 1-5: " + str(transformed));

let strings = ["Number: " + str(n) for (n in range(1, 6))];
print("  String formatting: " + str(strings));
print("");

# 4. 条件付きの複雑な内包表記
print("4. Complex comprehension with conditions:");
let multiples_of_3 = [x for (x in range(1, 31)) if (x % 3 == 0)];
print("  Multiples of 3 (1-30): " + str(multiples_of_3));

let squares_of_evens = [x * x for (x in range(1, 11)) if (x % 2 == 0)];
print("  Squares of even numbers: " + str(squares_of_evens));
print("");

# 5. 文字列からのリスト内包表記
print("5. List comprehension from string:");
let text = "Hello";
let chars = [c for (c in text)];
print("  Characters in 'Hello': " + str(chars));

let upper_chars = [c + "!" for (c in "ABC")];
print("  Modified characters: " + str(upper_chars));
print("");

# 6. 既存のリストを変換
print("6. Transforming existing lists:");
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let cubes = [n * n * n for (n in numbers)];
print("  Cubes: " + str(cubes));

let negatives = [n * (0 - 1) for (n in numbers)];
print("  Negatives: " + str(negatives));
print("");

# 7. 範囲指定とフィルタリング
print("7. Range with filtering:");
let large_squares = [x * x for (x in range(1, 21)) if (x * x > 50)];
print("  Squares > 50: " + str(large_squares));

let divisible_by_5 = [x for (x in range(1, 101)) if (x % 5 == 0)];
print("  Numbers divisible by 5 (1-100): " + str(divisible_by_5));
print("");

# 8. ラムダ式と組み合わせ
print("8. Combining with lambda:");
let apply_func = lambda(lst, f) { [f(x) for (x in lst)] };
let nums = [1, 2, 3, 4, 5];
let doubled2 = apply_func(nums, lambda(x) { x * 2 });
print("  Doubled with lambda: " + str(doubled2));
print("");

# 9. FizzBuzz問題をリスト内包表記で
print("9. FizzBuzz with list comprehension:");
fun fizzbuzz_value(n) {
    if (n % 15 == 0) {
        return "FizzBuzz";
    } elif (n % 3 == 0) {
        return "Fizz";
    } elif (n % 5 == 0) {
        return "Buzz";
    } else {
        return str(n);
    }
}

let fizzbuzz = [fizzbuzz_value(n) for (n in range(1, 21))];
print("  FizzBuzz 1-20: " + str(fizzbuzz));
print("");

# 10. 三項演算子と組み合わせ
print("10. With ternary operator:");
let classified = ["even" if n % 2 == 0 else "odd" for (n in range(1, 11))];
print("  Classify 1-10: " + str(classified));

let signs = ["positive" if n > 0 else "negative" if n < 0 else "zero" for (n in [5, 0, (0 - 3), 10, (0 - 1)])];
print("  Signs: " + str(signs));
print("");

# 11. 実用的な例: データ処理
print("11. Practical example - data processing:");
let temperatures_celsius = [0, 10, 20, 30, 40];
let temperatures_fahrenheit = [c * 9 / 5 + 32 for (c in temperatures_celsius)];
print("  Celsius to Fahrenheit: " + str(temperatures_fahrenheit));

let prices = [100, 200, 150, 300, 250];
let discounted = [p * 0.8 for (p in prices)];
print("  20% discount: " + str(discounted));
print("");

# 12. 条件に基づく複雑なフィルタリング
print("12. Complex filtering:");
let numbers2 = range(1, 51);
let special = [n for (n in numbers2) if (n % 3 == 0 and n % 5 != 0)];
print("  Divisible by 3 but not by 5: " + str(special));

let prime_candidates = [n for (n in range(2, 21)) if (n % 2 != 0 or n == 2)];
print("  Prime candidates: " + str(prime_candidates));
print("");

print("=== Demo completed! ===");
