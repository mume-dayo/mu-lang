# 素数判定プログラム

fun is_prime(n) {
    if (n <= 1) {
        return false;
    }
    if (n <= 3) {
        return true;
    }
    if (n % 2 == 0 or n % 3 == 0) {
        return false;
    }

    let i = 5;
    while (i * i <= n) {
        if (n % i == 0 or n % (i + 2) == 0) {
            return false;
        }
        i = i + 6;
    }
    return true;
}

# 最初の20個の素数を表示
print("First 20 prime numbers:");
let count = 0;
let num = 2;

while (count < 20) {
    if (is_prime(num)) {
        print(num);
        count = count + 1;
    }
    num = num + 1;
}
