# Mumei言語のラムダ式の例
# 使い方: mumei lambda_example.mu

print("=== Mumei Lambda Expression Demo ===");
print("");

# 1. 基本的なラムダ式
print("1. Basic lambda expressions:");
let square = lambda(x) { x * x };
print("  square(5) = " + str(square(5)));

let add = lambda(a, b) { a + b };
print("  add(3, 7) = " + str(add(3, 7)));

let greet = lambda(name) { "Hello, " + name + "!" };
print("  greet('Mumei') = " + greet("Mumei"));
print("");

# 2. ラムダ式を変数に代入
print("2. Lambda as variables:");
let multiply = lambda(x, y) { x * y };
let result = multiply(4, 5);
print("  multiply(4, 5) = " + str(result));
print("");

# 3. ラムダ式をリストに格納
print("3. Lambda in lists:");
let operations = [
    lambda(x) { x + 10 },
    lambda(x) { x * 2 },
    lambda(x) { x - 5 }
];

let value = 5;
print("  Starting value: " + str(value));
for (op in operations) {
    value = op(value);
    print("  After operation: " + str(value));
}
print("");

# 4. ラムダ式を関数の引数として渡す
print("4. Lambda as function arguments:");
fun apply_twice(f, x) {
    return f(f(x));
}

let double = lambda(n) { n * 2 };
let result2 = apply_twice(double, 3);
print("  apply_twice(double, 3) = " + str(result2) + " (3 * 2 * 2)");
print("");

# 5. ラムダ式を返す関数
print("5. Functions returning lambdas:");
fun make_multiplier(factor) {
    return lambda(x) { x * factor };
}

let times3 = make_multiplier(3);
let times5 = make_multiplier(5);
print("  times3(10) = " + str(times3(10)));
print("  times5(10) = " + str(times5(10)));
print("");

# 6. 即座に実行するラムダ式（IIFE - Immediately Invoked Function Expression）
print("6. Immediately invoked lambda:");
let iife_result = lambda(x, y) { x + y }(10, 20);
print("  lambda(x, y) { x + y }(10, 20) = " + str(iife_result));
print("");

# 7. 三項演算子とラムダ式の組み合わせ
print("7. Lambda with ternary operator:");
let get_comparator = lambda(ascending) {
    lambda(a, b) { a < b } if ascending else lambda(a, b) { a > b }
};

let asc = get_comparator(true);
print("  asc(5, 10) = " + str(asc(5, 10)) + " (5 < 10)");

let desc = get_comparator(false);
print("  desc(5, 10) = " + str(desc(5, 10)) + " (5 > 10)");
print("");

# 8. ラムダ式で簡単なフィルター実装
print("8. Simple filter with lambda:");
fun filter_list(lst, predicate) {
    let result = [];
    for (item in lst) {
        if (predicate(item)) {
            append(result, item);
        }
    }
    return result;
}

let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let is_even = lambda(n) { n % 2 == 0 };
let evens = filter_list(numbers, is_even);
print("  Even numbers: " + str(evens));

let is_greater_than_5 = lambda(n) { n > 5 };
let greater = filter_list(numbers, is_greater_than_5);
print("  Numbers > 5: " + str(greater));
print("");

# 9. ラムダ式でmap実装
print("9. Simple map with lambda:");
fun map_list(lst, transform) {
    let result = [];
    for (item in lst) {
        append(result, transform(item));
    }
    return result;
}

let squares = map_list(numbers, lambda(n) { n * n });
print("  Squares: " + str(squares));

let doubled = map_list(numbers, lambda(n) { n * 2 });
print("  Doubled: " + str(doubled));
print("");

# 10. ラムダ式でreduce実装
print("10. Simple reduce with lambda:");
fun reduce_list(lst, reducer, initial) {
    let accumulator = initial;
    for (item in lst) {
        accumulator = reducer(accumulator, item);
    }
    return accumulator;
}

let sum = reduce_list(numbers, lambda(acc, n) { acc + n }, 0);
print("  Sum of numbers: " + str(sum));

let product = reduce_list(numbers, lambda(acc, n) { acc * n }, 1);
print("  Product of numbers: " + str(product));
print("");

print("=== Demo completed! ===");
