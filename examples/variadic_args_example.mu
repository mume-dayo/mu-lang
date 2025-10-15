# Mumei言語の可変長引数の例
# 使い方: mumei variadic_args_example.mu

print("=== Mumei Variadic Arguments Demo ===");
print("");

# 1. 基本的な可変長引数
print("1. Basic variadic arguments:");
fun sum_all(*numbers) {
    let total = 0;
    for (n in numbers) {
        total = total + n;
    }
    return total;
}

print("  sum_all(1, 2, 3) = " + str(sum_all(1, 2, 3)));
print("  sum_all(10, 20, 30, 40, 50) = " + str(sum_all(10, 20, 30, 40, 50)));
print("  sum_all(5) = " + str(sum_all(5)));
print("");

# 2. 固定引数と可変長引数の組み合わせ
print("2. Fixed + variadic arguments:");
fun greet_all(greeting, *names) {
    for (name in names) {
        print("  " + greeting + ", " + name + "!");
    }
}

greet_all("Hello", "Alice", "Bob", "Charlie");
print("");

# 3. 平均値の計算
print("3. Calculate average:");
fun average(*values) {
    if (len(values) == 0) {
        return 0;
    }
    let sum = 0;
    for (v in values) {
        sum = sum + v;
    }
    return sum / len(values);
}

print("  average(10, 20, 30, 40, 50) = " + str(average(10, 20, 30, 40, 50)));
print("  average(100, 200) = " + str(average(100, 200)));
print("");

# 4. 最大値を求める
print("4. Find maximum:");
fun find_max(*numbers) {
    if (len(numbers) == 0) {
        return none;
    }
    let max_val = numbers[0];
    for (n in numbers) {
        if (n > max_val) {
            max_val = n;
        }
    }
    return max_val;
}

print("  find_max(5, 2, 9, 1, 7) = " + str(find_max(5, 2, 9, 1, 7)));
print("  find_max(100, 50, 200, 75) = " + str(find_max(100, 50, 200, 75)));
print("");

# 5. 文字列の連結
print("5. Join strings:");
fun join_strings(separator, *strings) {
    if (len(strings) == 0) {
        return "";
    }
    let result = strings[0];
    for (s in strings[1:]) {
        result = result + separator + s;
    }
    return result;
}

print("  join_strings(', ', 'apple', 'banana', 'cherry') = " + join_strings(", ", "apple", "banana", "cherry"));
print("  join_strings(' - ', 'one', 'two', 'three', 'four') = " + join_strings(" - ", "one", "two", "three", "four"));
print("");

# 6. 数値のリストを返す
print("6. Create list from arguments:");
fun make_list(*items) {
    return items;
}

let numbers = make_list(1, 2, 3, 4, 5);
print("  make_list(1, 2, 3, 4, 5) = " + str(numbers));
print("");

# 7. 引数の個数を表示
print("7. Count arguments:");
fun count_args(*args) {
    return len(args);
}

print("  count_args(1, 2, 3) = " + str(count_args(1, 2, 3)));
print("  count_args('a', 'b', 'c', 'd', 'e') = " + str(count_args("a", "b", "c", "d", "e")));
print("");

# 8. フィルタリング関数
print("8. Filter positive numbers:");
fun sum_positives(*numbers) {
    let total = 0;
    for (n in numbers) {
        if (n > 0) {
            total = total + n;
        }
    }
    return total;
}

print("  sum_positives(1, -2, 3, -4, 5) = " + str(sum_positives(1, (0-2), 3, (0-4), 5)));
print("");

# 9. ログ関数
print("9. Log function:");
fun log_message(level, *messages) {
    let full_message = "[" + level + "] ";
    for (msg in messages) {
        full_message = full_message + str(msg) + " ";
    }
    print("  " + full_message);
}

log_message("INFO", "Server", "started", "on", "port", 8080);
log_message("ERROR", "Connection", "failed");
print("");

# 10. 積を計算
print("10. Calculate product:");
fun multiply_all(*factors) {
    if (len(factors) == 0) {
        return 1;
    }
    let product = 1;
    for (f in factors) {
        product = product * f;
    }
    return product;
}

print("  multiply_all(2, 3, 4) = " + str(multiply_all(2, 3, 4)));
print("  multiply_all(5, 10) = " + str(multiply_all(5, 10)));
print("");

print("=== Demo completed! ===");
