# Mumei言語のスライス記法の例
# 使い方: mumei slice_example.mu

print("=== Mumei Slice Notation Demo ===");
print("");

# 1. 基本的なスライス
print("1. Basic slicing:");
let numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
print("  Original list: " + str(numbers));
print("  numbers[2:5] = " + str(numbers[2:5]));
print("  numbers[0:3] = " + str(numbers[0:3]));
print("  numbers[5:10] = " + str(numbers[5:10]));
print("");

# 2. 開始位置や終了位置の省略
print("2. Omitting start or end:");
print("  numbers[:5] = " + str(numbers[:5]));
print("  numbers[5:] = " + str(numbers[5:]));
print("  numbers[:] = " + str(numbers[:]));
print("");

# 3. ステップを使ったスライス
print("3. Slicing with step:");
print("  numbers[::2] = " + str(numbers[::2]) + " (every 2nd element)");
print("  numbers[1::2] = " + str(numbers[1::2]) + " (every 2nd, starting from index 1)");
print("  numbers[::3] = " + str(numbers[::3]) + " (every 3rd element)");
print("");

# 4. 逆順のスライス
print("4. Reverse slicing:");
print("  numbers[::(0-1)] = " + str(numbers[::(0-1)]) + " (reversed)");
print("  numbers[8:2:(0-1)] = " + str(numbers[8:2:(0-1)]) + " (8 to 3, reversed)");
print("");

# 5. 文字列のスライス
print("5. String slicing:");
let text = "Hello, World!";
print("  Original: " + text);
print("  text[0:5] = " + text[0:5]);
print("  text[7:12] = " + text[7:12]);
print("  text[:5] = " + text[:5]);
print("  text[7:] = " + text[7:]);
print("  text[::(0-1)] = " + text[::(0-1)] + " (reversed)");
print("");

# 6. 負のインデックス（Pythonスタイル）
print("6. Negative indices:");
let lst = [10, 20, 30, 40, 50];
print("  List: " + str(lst));
print("  lst[(0-1)] = " + str(lst[(0-1)]) + " (last element)");
print("  lst[(0-2)] = " + str(lst[(0-2)]) + " (second to last)");
print("");

# 7. スライスを使ったリストのコピー
print("7. Copying lists with slicing:");
let original = [1, 2, 3, 4, 5];
let copy = original[:];
print("  Original: " + str(original));
print("  Copy: " + str(copy));
print("");

# 8. 部分リストの取得
print("8. Getting sublists:");
let data = [100, 200, 300, 400, 500, 600, 700, 800];
print("  First 3 elements: " + str(data[:3]));
print("  Last 3 elements: " + str(data[(0-3):]));
print("  Middle elements: " + str(data[2:6]));
print("");

# 9. スライスとリスト内包表記の組み合わせ
print("9. Combining slicing with list comprehension:");
let range_nums = range(0, 20);
let first_half = range_nums[:10];
let squared_first_half = [x * x for (x in first_half)];
print("  Squared first half: " + str(squared_first_half));

let every_third = range_nums[::3];
print("  Every 3rd element: " + str(every_third));
print("");

# 10. 実用的な例
print("10. Practical examples:");

# 文字列の一部を取得
let email = "user@example.com";
let username = email[:4];
let domain = email[5:];
print("  Email: " + email);
print("  Username: " + username);
print("  Domain: " + domain);
print("");

# リストの最初と最後を除く
let scores = [95, 88, 92, 78, 85, 90];
let middle_scores = scores[1:(0-1)];
print("  All scores: " + str(scores));
print("  Middle scores (excluding first and last): " + str(middle_scores));
print("");

# 11. ステップを使った要素の抽出
print("11. Extracting elements with step:");
let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
print("  Every 2nd letter: " + alphabet[::2]);
print("  Every 3rd letter: " + alphabet[::3]);
print("  Every 5th letter: " + alphabet[::5]);
print("");

# 12. 逆順とスライスの組み合わせ
print("12. Combining reverse and slicing:");
let sequence = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let reversed_first_five = sequence[4::(0-1)];
print("  First 5 elements reversed: " + str(reversed_first_five));

let reversed_last_five = sequence[:4:(0-1)];
print("  Last 5 elements reversed: " + str(reversed_last_five));
print("");

print("=== Demo completed! ===");
