# リスト操作の例

# リストの作成
let numbers = [1, 2, 3, 4, 5];
print("Original list:", numbers);

# リストの長さ
print("Length:", len(numbers));

# リストの要素にアクセス
print("First element:", numbers[0]);
print("Last element:", numbers[4]);

# リストへの要素追加
append(numbers, 6);
append(numbers, 7);
print("After append:", numbers);

# リストから要素を削除
let removed = pop(numbers);
print("Removed element:", removed);
print("After pop:", numbers);

# リストのイテレーション
print("Iterating through list:");
for (num in numbers) {
    print("  -", num);
}

# 文字列のリスト
let fruits = ["apple", "banana", "cherry"];
print("Fruits:", fruits);

for (fruit in fruits) {
    print("I like", fruit);
}
