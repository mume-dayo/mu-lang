# Mumei言語でのset（集合）型
# 使い方: mumei set_example.mu

print("=== set（集合）型の例 ===");
print("");

# 例1: 基本的なset作成
print("1. setの作成");
let empty_set = set();
let numbers_set = set([1, 2, 3, 4, 5]);
let colors_set = set(["red", "green", "blue"]);

print("  空のset:", empty_set);
print("  数字のset:", numbers_set);
print("  色のset:", colors_set);
print("");

# 例2: setのサイズ
print("2. setのサイズ");
print("  numbers_setのサイズ:", len(numbers_set));
print("  colors_setのサイズ:", len(colors_set));
print("");

# 例3: setに要素を追加
print("3. setに要素を追加");
let fruits = set();
set_add(fruits, "apple");
set_add(fruits, "banana");
set_add(fruits, "orange");
set_add(fruits, "apple");  # 重複は無視される
print("  fruits:", fruits);
print("  サイズ:", len(fruits));  # 3（appleの重複は無視）
print("");

# 例4: setから要素を削除
print("4. setから要素を削除");
let my_set = set([1, 2, 3, 4, 5]);
print("  元のset:", my_set);
set_remove(my_set, 3);
print("  3を削除後:", my_set);
set_discard(my_set, 10);  # 存在しなくてもエラーにならない
print("  10をdiscard後:", my_set);
print("");

# 例5: set内の要素チェック
print("5. 要素の存在チェック");
let numbers = set([1, 2, 3, 4, 5]);
print("  numbers:", numbers);
print("  3は含まれる?", set_has(numbers, 3));
print("  10は含まれる?", set_has(numbers, 10));
print("");

# 例6: 和集合（union）
print("6. 和集合");
let set1 = set([1, 2, 3]);
let set2 = set([3, 4, 5]);
let union_set = set_union(set1, set2);
print("  set1:", set1);
print("  set2:", set2);
print("  和集合:", union_set);  # {1, 2, 3, 4, 5}
print("");

# 例7: 積集合（intersection）
print("7. 積集合");
let a = set([1, 2, 3, 4]);
let b = set([3, 4, 5, 6]);
let intersection_set = set_intersection(a, b);
print("  A:", a);
print("  B:", b);
print("  積集合:", intersection_set);  # {3, 4}
print("");

# 例8: 差集合（difference）
print("8. 差集合");
let x = set([1, 2, 3, 4, 5]);
let y = set([4, 5, 6, 7]);
let diff_set = set_difference(x, y);
print("  X:", x);
print("  Y:", y);
print("  X - Y:", diff_set);  # {1, 2, 3}
print("");

# 例9: 重複の除去
print("9. リストから重複を除去");
let list_with_duplicates = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5];
print("  元のリスト:", list_with_duplicates);
let unique_set = set(list_with_duplicates);
print("  setに変換:", unique_set);
let unique_list = set_to_list(unique_set);
print("  リストに戻す:", unique_list);
print("");

# 例10: setのイテレーション
print("10. setの要素を反復処理");
let languages = set(["Python", "JavaScript", "Mumei", "Rust", "Go"]);
print("  プログラミング言語:");
for (lang in languages) {
    print("    -", lang);
}
print("");

# 例11: 複数のsetの操作
print("11. 複数のsetの組み合わせ");
let students_math = set(["Alice", "Bob", "Charlie"]);
let students_physics = set(["Bob", "Charlie", "David"]);
let students_chemistry = set(["Charlie", "David", "Eve"]);

print("  数学履修者:", students_math);
print("  物理履修者:", students_physics);
print("  化学履修者:", students_chemistry);

let all_students = set_union(students_math, set_union(students_physics, students_chemistry));
print("  全履修者:", all_students);

let math_and_physics = set_intersection(students_math, students_physics);
print("  数学と物理の両方:", math_and_physics);

let only_math = set_difference(students_math, set_union(students_physics, students_chemistry));
print("  数学のみ:", only_math);
print("");

# 例12: setを使った素数判定の高速化
print("12. setを使ったメンバーシップテスト");
let primes = set([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]);
print("  素数のset:", primes);

fun is_prime_fast(n) {
    return set_has(primes, n);
}

for (i in range(1, 15)) {
    if (is_prime_fast(i)) {
        print("  ", i, "は素数");
    }
}
print("");

print("=== setのメリット ===");
print("1. 重複排除: 自動的に重複を除去");
print("2. 高速な検索: メンバーシップテストが高速");
print("3. 集合演算: 和集合、積集合、差集合が簡単");
print("4. 一意性の保証: 要素の一意性が保証される");
