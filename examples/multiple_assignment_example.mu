# Mumei言語の複数代入とアンパックの例
# 使い方: mumei multiple_assignment_example.mu

print("=== Mumei Multiple Assignment Demo ===");
print("");

# 1. 基本的な複数代入
print("1. Basic multiple assignment:");
let a, b, c = [1, 2, 3];
print("  a = " + str(a));
print("  b = " + str(b));
print("  c = " + str(c));
print("");

# 2. 値の交換
print("2. Swapping values:");
let x, y = [10, 20];
print("  Before swap: x = " + str(x) + ", y = " + str(y));
x, y = [y, x];
print("  After swap: x = " + str(x) + ", y = " + str(y));
print("");

# 3. 関数の戻り値をアンパック
print("3. Unpacking function return values:");
fun get_coordinates() {
    return [100, 200];
}

let x_pos, y_pos = get_coordinates();
print("  x_pos = " + str(x_pos));
print("  y_pos = " + str(y_pos));
print("");

# 4. 文字列のアンパック
print("4. Unpacking strings:");
let char1, char2, char3 = "ABC";
print("  char1 = " + char1);
print("  char2 = " + char2);
print("  char3 = " + char3);
print("");

# 5. 複数の値を一度に定義
print("5. Defining multiple variables at once:");
let name, age, city = ["Alice", 25, "Tokyo"];
print("  Name: " + name);
print("  Age: " + str(age));
print("  City: " + city);
print("");

# 6. 座標のアンパック
print("6. Coordinate unpacking:");
fun get_point() {
    return [5, 10];
}

let px, py = get_point();
print("  Point: (" + str(px) + ", " + str(py) + ")");
print("");

# 7. RGB値のアンパック
print("7. RGB color unpacking:");
let colors = [255, 128, 64];
let red, green, blue = colors;
print("  RGB: (" + str(red) + ", " + str(green) + ", " + str(blue) + ")");
print("");

# 8. 複数の計算結果を受け取る
print("8. Receiving multiple calculation results:");
fun calculate_stats(numbers) {
    let total = 0;
    let count = len(numbers);
    for (n in numbers) {
        total = total + n;
    }
    let average = total / count;
    return [total, average, count];
}

let data = [10, 20, 30, 40, 50];
let sum, avg, cnt = calculate_stats(data);
print("  Sum: " + str(sum));
print("  Average: " + str(avg));
print("  Count: " + str(cnt));
print("");

# 9. リスト内包表記で生成したリストのアンパック
print("9. Unpacking list comprehension results:");
let squares = [x * x for (x in range(1, 4))];
let sq1, sq2, sq3 = squares;
print("  Squares: " + str(sq1) + ", " + str(sq2) + ", " + str(sq3));
print("");

# 10. 実用的な例: ユーザー情報の処理
print("10. Practical example - user data:");
fun get_user_info() {
    return ["John Doe", "john@example.com", 30];
}

let username, email, user_age = get_user_info();
print("  Username: " + username);
print("  Email: " + email);
print("  Age: " + str(user_age));
print("");

# 11. スライスと組み合わせ
print("11. Combining with slicing:");
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let first_three = numbers[:3];
let n1, n2, n3 = first_three;
print("  First three numbers: " + str(n1) + ", " + str(n2) + ", " + str(n3));
print("");

# 12. ネストしたリストの処理
print("12. Processing nested structures:");
fun get_rectangle_info() {
    return [10, 20];  # width, height
}

let width, height = get_rectangle_info();
let area = width * height;
let perimeter = 2 * (width + height);
print("  Width: " + str(width));
print("  Height: " + str(height));
print("  Area: " + str(area));
print("  Perimeter: " + str(perimeter));
print("");

print("=== Demo completed! ===");
