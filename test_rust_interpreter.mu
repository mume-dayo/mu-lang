// Rust実装インタプリタのテスト
// 基本機能が正しく動作するかを確認

print("=== Rust Interpreter Test ===");
print("");

// 1. 算術演算
print("1. 算術演算テスト");
print("2 + 3 = ");
print(2 + 3);
print("10 - 4 = ");
print(10 - 4);
print("5 * 6 = ");
print(5 * 6);
print("20 / 4 = ");
print(20 / 4);
print("10 % 3 = ");
print(10 % 3);
print("2 ** 8 = ");
print(2 ** 8);
print("");

// 2. 変数
print("2. 変数テスト");
let x = 42;
print("x = ");
print(x);
x = x + 8;
print("x + 8 = ");
print(x);
print("");

// 3. 文字列
print("3. 文字列テスト");
let greeting = "Hello, ";
let name = "World";
print(greeting + name + "!");
print("upper(name) = ");
print(upper(name));
print("");

// 4. リスト
print("4. リストテスト");
let numbers = [1, 2, 3, 4, 5];
print("numbers = ");
print(numbers);
print("numbers[2] = ");
print(numbers[2]);
print("len(numbers) = ");
print(len(numbers));
print("");

// 5. 辞書
print("5. 辞書テスト");
let person = {"name": "Alice", "age": 30};
print("person = ");
print(person);
print("person.name = ");
print(person.name);
print("");

// 6. 条件分岐
print("6. 条件分岐テスト");
let score = 85;
if (score >= 90) {
    print("Grade: A");
} elif (score >= 80) {
    print("Grade: B");
} else {
    print("Grade: C");
}
print("");

// 7. ループ
print("7. ループテスト");
print("for loop:");
for (let i in [1, 2, 3, 4, 5]) {
    print(i);
}
print("");

// 8. 関数
print("8. 関数テスト");
fun add(a, b) {
    return a + b;
}
let result = add(10, 20);
print("add(10, 20) = ");
print(result);
print("");

// 9. 型チェック
print("9. 型チェックテスト");
print("type(42) = ");
print(type(42));
print("type('hello') = ");
print(type("hello"));
print("type([1,2,3]) = ");
print(type([1, 2, 3]));
print("");

// 10. 数学関数
print("10. 数学関数テスト");
print("abs(-5) = ");
print(abs(-5));
print("sqrt(16) = ");
print(sqrt(16));
print("min(3, 7) = ");
print(min(3, 7));
print("max(3, 7) = ");
print(max(3, 7));
print("");

print("=== All Tests Complete ===");
