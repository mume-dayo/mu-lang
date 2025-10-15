# Mumei言語の数学モジュール
# このファイルは他のファイルからimportされます

# 定数
let PI = 3.14159265359;
let E = 2.71828182846;

# 関数
fun add(a, b) {
    return a + b;
}

fun subtract(a, b) {
    return a - b;
}

fun multiply(a, b) {
    return a * b;
}

fun divide(a, b) {
    if (b == 0) {
        throw "Division by zero";
    }
    return a / b;
}

fun power(base, exp) {
    let result = 1;
    let i = 0;
    while (i < exp) {
        result = result * base;
        i = i + 1;
    }
    return result;
}

fun factorial(n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

fun abs(n) {
    if (n < 0) {
        return -n;
    }
    return n;
}

fun max(a, b) {
    if (a > b) {
        return a;
    }
    return b;
}

fun min(a, b) {
    if (a < b) {
        return a;
    }
    return b;
}

print("math_module loaded");
