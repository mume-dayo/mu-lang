# Mumei言語 標準ライブラリデモ
# Python標準ライブラリ関数の使い方

print("=== Mumei Standard Library Demo ===");
print("");

# 1. 数学関数
print("1. Math functions");
print("  abs(-5) =", abs(-5));
print("  ceil(4.3) =", ceil(4.3));
print("  floor(4.8) =", floor(4.8));
print("  round(3.14159, 2) =", round(3.14159, 2));
print("  sqrt(16) =", sqrt(16));
print("  pow(2, 8) =", pow(2, 8));
print("  max(1, 5, 3, 9, 2) =", max(1, 5, 3, 9, 2));
print("  min(1, 5, 3, 9, 2) =", min(1, 5, 3, 9, 2));
let numbers = [1, 2, 3, 4, 5];
print("  sum([1,2,3,4,5]) =", sum(numbers));
print("  pi() =", pi());
print("  e() =", e());
print("  sin(0) =", sin(0));
print("  cos(0) =", cos(0));
print("");

# 2. ランダム関数
print("2. Random functions");
print("  random() =", random());
print("  randint(1, 10) =", randint(1, 10));
let items = ["apple", "banana", "cherry"];
print("  choice(['apple','banana','cherry']) =", choice(items));
let shuffled = shuffle([1, 2, 3, 4, 5]);
print("  shuffle([1,2,3,4,5]) =", shuffled);
print("");

# 3. 文字列関数
print("3. String functions");
let text = "Hello World";
print("  upper('Hello World') =", upper(text));
print("  lower('Hello World') =", lower(text));
print("  capitalize('hello') =", capitalize("hello"));
print("  strip('  hello  ') =", strip("  hello  "));
let words = split("apple,banana,cherry", ",");
print("  split('apple,banana,cherry', ',') =", words);
print("  join('-', ['a','b','c']) =", join("-", ["a", "b", "c"]));
print("  replace('hello', 'l', 'L') =", replace("hello", "l", "L"));
print("  startswith('hello', 'hel') =", startswith("hello", "hel"));
print("  endswith('hello', 'lo') =", endswith("hello", "lo"));
print("  find('hello', 'l') =", find("hello", "l"));
print("");

# 4. リスト関数
print("4. List functions");
let nums = [3, 1, 4, 1, 5, 9, 2, 6];
print("  original:", nums);
print("  reverse([3,1,4,1,5,9,2,6]) =", reverse(nums));
print("  sort([3,1,4,1,5,9,2,6]) =", sort(nums));
let copied_list = list_copy(nums);
print("  list_copy(nums) =", copied_list);
print("");

# 5. 辞書関数
print("5. Dictionary functions");
let person = {"name": "Alice", "age": 25, "city": "Tokyo"};
print("  person =", person);
print("  keys(person) =", keys(person));
print("  values(person) =", values(person));
print("  items(person) =", items(person));
print("  dict_get(person, 'name') =", dict_get(person, "name"));
print("  dict_get(person, 'email', 'N/A') =", dict_get(person, "email", "N/A"));
print("  has_key(person, 'age') =", has_key(person, "age"));
print("");

# 6. 日時関数
print("6. Date/Time functions");
print("  now() =", now());
print("  today() =", today());
print("  timestamp() =", timestamp());
print("");

# 7. 正規表現
print("7. Regular expressions");
print("  regex_match('^[a-z]+$', 'hello') =", regex_match("^[a-z]+$", "hello"));
print("  regex_match('^[a-z]+$', 'Hello') =", regex_match("^[a-z]+$", "Hello"));
print("  regex_search('[0-9]+', 'age: 25') =", regex_search("[0-9]+", "age: 25"));
print("  regex_findall('[0-9]+', 'a1b2c3') =", regex_findall("[0-9]+", "a1b2c3"));
print("  regex_replace('[0-9]', 'X', 'a1b2c3') =", regex_replace("[0-9]", "X", "a1b2c3"));
print("");

# 8. 実用例：データ処理
print("8. Practical example: Data processing");
let data = [
    {"name": "Alice", "score": 85},
    {"name": "Bob", "score": 92},
    {"name": "Carol", "score": 78},
    {"name": "David", "score": 95}
];

print("  Students:");
let scores = [];
for (student in data) {
    print("   ", student["name"], "-", student["score"]);
    append(scores, student["score"]);
}

print("  Average score:", sum(scores) / len(scores));
print("  Highest score:", max(scores));
print("  Lowest score:", min(scores));
print("");

# 9. 実用例：テキスト処理
print("9. Practical example: Text processing");
let sentence = "  The Quick Brown Fox Jumps Over The Lazy Dog  ";
print("  Original:", sentence);
let cleaned = strip(sentence);
print("  Cleaned:", cleaned);
let lowercase = lower(cleaned);
print("  Lowercase:", lowercase);
let words_list = split(lowercase, " ");
print("  Words:", words_list);
print("  Word count:", len(words_list));
print("  Sorted:", sort(words_list));
print("");

print("=== Demo Complete! ===");
print("Standard library features:");
print("  - Math: abs, ceil, floor, round, sqrt, pow, max, min, sum");
print("  - Random: random, randint, choice, shuffle");
print("  - String: upper, lower, split, join, replace, strip");
print("  - List: reverse, sort, copy, extend, insert, remove");
print("  - Dict: keys, values, items, dict_get, has_key");
print("  - DateTime: now, today, timestamp");
print("  - Regex: regex_match, regex_search, regex_findall, regex_replace");
