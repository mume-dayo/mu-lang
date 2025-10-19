fun fibonacci(n) {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

print("Fibonacci sequence:");
for (i in range(10)) {
    print("F(" + str(i) + ") =", fibonacci(i));
}
