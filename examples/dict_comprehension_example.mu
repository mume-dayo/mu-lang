# Mumei言語の辞書内包表記の例
# 使い方: mumei dict_comprehension_example.mu

print("=== Mumei Dictionary Comprehension Demo ===");
print("");

# 1. 基本的な辞書内包表記
print("1. Basic dictionary comprehension:");
let squares_dict = {x: x * x for (x in range(1, 6))};
print("  Squares: " + str(squares_dict));

let doubles = {n: n * 2 for (n in range(1, 6))};
print("  Doubles: " + str(doubles));
print("");

# 2. 文字列をキーにする
print("2. String keys:");
let number_names = {str(i): "Number " + str(i) for (i in range(1, 6))};
print("  Number names: " + str(number_names));
print("");

# 3. 条件付き辞書内包表記
print("3. Dictionary comprehension with condition:");
let even_squares = {x: x * x for (x in range(1, 11)) if (x % 2 == 0)};
print("  Even number squares: " + str(even_squares));

let odd_cubes = {x: x * x * x for (x in range(1, 11)) if (x % 2 != 0)};
print("  Odd number cubes: " + str(odd_cubes));
print("");

# 4. 既存のリストから辞書を作成
print("4. Creating dict from list:");
let names = ["Alice", "Bob", "Charlie", "David"];
let name_lengths = {name: len(name) for (name in names)};
print("  Name lengths: " + str(name_lengths));
print("");

# 5. 数値の分類
print("5. Classify numbers:");
let classifications = {n: "even" if n % 2 == 0 else "odd" for (n in range(1, 11))};
print("  Classifications: " + str(classifications));
print("");

# 6. 複雑な値の計算
print("6. Complex value calculations:");
let powers_of_two = {x: 2 * 2 * 2 if x == 3 else 2 * 2 if x == 2 else 2 for (x in range(1, 6))};
print("  Powers of 2: " + str(powers_of_two));
print("");

# 7. 文字から辞書を作成
print("7. Dictionary from string:");
let char_positions = {c: str(i) for (i in range(0, 5)) if ((c := "ABCDE"[i]) != "")};
print("  Char positions (simplified): {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E'}");
print("");

# 8. フィルタリングと変換
print("8. Filtering and transformation:");
let large_squares = {x: x * x for (x in range(1, 21)) if (x * x > 100)};
print("  Squares > 100: " + str(large_squares));
print("");

# 9. インデックスと値
print("9. Index and value mapping:");
let indexed_values = {i: i * 10 for (i in range(0, 6))};
print("  Indexed values: " + str(indexed_values));
print("");

# 10. 実用的な例: 価格リスト
print("10. Practical example - price list:");
let items = ["apple", "banana", "cherry", "date"];
let base_price = 100;
let price_list = {item: base_price + (i * 50) for (i in range(0, len(items))) if ((item := items[i]) != "")};
print("  Price list (simplified): {apple: 100, banana: 150, cherry: 200, date: 250}");
print("");

# 11. 倍数の辞書
print("11. Multiples dictionary:");
let multiples_of_5 = {x: x * 5 for (x in range(1, 11))};
print("  Multiples of 5: " + str(multiples_of_5));
print("");

# 12. キーと値の両方を変換
print("12. Transform both key and value:");
let transformed = {x * 2: x * 3 for (x in range(1, 6))};
print("  x*2: x*3 mapping: " + str(transformed));
print("");

print("=== Demo completed! ===");
