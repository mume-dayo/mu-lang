# FizzBuzz プログラム
print("FizzBuzz (1-30):");

for (i in range(1, 31)) {
    if (i % 15 == 0) {
        print("FizzBuzz");
    } else {
        if (i % 3 == 0) {
            print("Fizz");
        } else {
            if (i % 5 == 0) {
                print("Buzz");
            } else {
                print(i);
            }
        }
    }
}
