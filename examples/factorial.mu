# 階乗を計算する関数
fun factorial(n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

# 階乗の計算
print("Factorial calculations:");
for (i in range(1, 11)) {
    let result = factorial(i);
    print(str(i) + "! =", result);
}
