# Mumei言語 クイックスタート

## 5分でMumeiを始める

### 1. Hello, World!

最初のMumeiプログラムを書きましょう。`hello.mu`というファイルを作成:

```mu
print("Hello, World!");
```

実行:
```bash
./mumei hello.mu
```

### 2. 変数と計算

```mu
let x = 10;
let y = 20;
let sum = x + y;
print("Sum:", sum);
```

### 3. 関数を定義

```mu
fun add(a, b) {
    return a + b;
}

let result = add(5, 3);
print("5 + 3 =", result);
```

### 4. ループを使う

```mu
# 1から10まで表示
for (i in range(1, 11)) {
    print(i);
}
```

### 5. リストを操作

```mu
let fruits = ["apple", "banana", "cherry"];

# リストの表示
print("Fruits:", fruits);

# 要素を追加
append(fruits, "orange");

# リストをループ
for (fruit in fruits) {
    print("I like", fruit);
}
```

### 6. 条件分岐

```mu
let age = 20;

if (age >= 18) {
    print("You are an adult");
} else {
    print("You are a minor");
}
```

### 7. 再帰関数

```mu
fun factorial(n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

print("5! =", factorial(5));  # 120
```

## REPL（対話モード）

mumeiを引数なしで実行すると、REPLモードが起動します:

```bash
./mumei
```

```
mumei> let x = 10;
mumei> let y = 20;
mumei> print(x + y);
30
mumei> exit
```

## サンプルプログラム

`examples/`ディレクトリに様々なサンプルがあります:

```bash
# フィボナッチ数列
./mumei examples/fibonacci.mu

# FizzBuzz
./mumei examples/fizzbuzz.mu

# 素数判定
./mumei examples/prime_numbers.mu

# リスト操作
./mumei examples/list_operations.mu
```

## よく使う組み込み関数

```mu
# 出力
print("Hello");

# 入力
let name = input("What is your name? ");

# 型変換
let num = int("123");
let text = str(456);
let decimal = float("3.14");

# リスト操作
let list = [1, 2, 3];
let length = len(list);        # 長さ
append(list, 4);               # 追加
let item = pop(list);          # 削除

# 範囲生成
range(10);        # 0から9まで
range(1, 11);     # 1から10まで
range(0, 10, 2);  # 0, 2, 4, 6, 8

# 環境変数
let user = env("USER");                      # 環境変数を取得
let api_key = env("API_KEY", "default");    # デフォルト値付き
env_set("MY_VAR", "value");                 # 環境変数を設定
let exists = env_has("PATH");               # 存在チェック
```

## 次のステップ

1. [README.md](README.md) - 完全な言語仕様
2. [INSTALL.md](INSTALL.md) - 詳細なインストール手順
3. `examples/` - より多くのサンプルコード

## ヒント

- セミコロン`;`で文を終了
- `#`または`//`でコメント
- インデントは自由（Pythonと違い必須ではない）
- ファイル拡張子は`.mu`

楽しくプログラミングしましょう! 🚀
