# Mumei言語 辞書（Dictionary）デモ
# 辞書型の基本的な使い方

print("=== Mumei Dictionary Demo ===");
print("");

# 1. 辞書の作成
print("1. Creating dictionaries");
let person = {"name": "Alice", "age": 25, "city": "Tokyo"};
print("  person =", person);

let empty_dict = {};
print("  empty_dict =", empty_dict);

let numbers = {1: "one", 2: "two", 3: "three"};
print("  numbers =", numbers);
print("");

# 2. 辞書の要素へのアクセス
print("2. Accessing dictionary elements");
print("  person['name'] =", person["name"]);
print("  person['age'] =", person["age"]);
print("  numbers[1] =", numbers[1]);
print("");

# 3. メンバーアクセス（ドット記法）
print("3. Member access (dot notation)");
print("  person.name =", person.name);
print("  person.city =", person.city);
print("");

# 4. 辞書の型チェック
print("4. Type checking");
print("  type(person) =", type(person));
print("");

# 5. 辞書操作関数
print("5. Dictionary operations");

# キー一覧
let person_keys = keys(person);
print("  keys(person) =", person_keys);

# 値一覧
let person_values = values(person);
print("  values(person) =", person_values);

# キーと値のペア
let person_items = items(person);
print("  items(person) =", person_items);

# キーの存在確認
print("  has_key(person, 'name') =", has_key(person, "name"));
print("  has_key(person, 'email') =", has_key(person, "email"));
print("");

# 6. デフォルト値付き取得
print("6. Get with default value");
let email = dict_get(person, "email", "no-email@example.com");
print("  email (with default) =", email);
print("");

# 7. ネストされた辞書
print("7. Nested dictionaries");
let user = {
    "name": "Bob",
    "age": 30,
    "address": {
        "city": "Osaka",
        "country": "Japan"
    }
};
print("  user =", user);
print("  user.name =", user.name);
print("  user.address =", user.address);
print("  user.address.city =", user.address.city);
print("");

# 8. 辞書とリストの組み合わせ
print("8. Dictionary with lists");
let student = {
    "name": "Carol",
    "grades": [85, 90, 92, 88],
    "subjects": ["Math", "Science", "English"]
};
print("  student =", student);
print("  student.name =", student.name);
print("  student.grades =", student.grades);
print("  student.grades[0] =", student.grades[0]);
print("");

# 9. リストの中の辞書
print("9. List of dictionaries");
let users = [
    {"name": "Alice", "age": 25},
    {"name": "Bob", "age": 30},
    {"name": "Carol", "age": 28}
];

print("  users =", users);
for (user_item in users) {
    print("   ", user_item["name"], "-", user_item["age"], "years old");
}
print("");

# 10. 辞書のコピー
print("10. Copying dictionaries");
let original = {"a": 1, "b": 2};
let copied = dict_copy(original);
print("  original =", original);
print("  copied =", copied);
print("");

print("=== Demo Complete! ===");
print("Dictionary features:");
print("  - Dictionary literals: {key: value}");
print("  - Index access: dict[key]");
print("  - Member access: dict.key");
print("  - keys(), values(), items()");
print("  - has_key(), dict_get()");
print("  - Nested dictionaries");
print("  - Mixed with lists");
