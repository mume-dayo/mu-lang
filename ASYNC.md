# Mumei言語 非同期処理

Mumei言語での非同期処理とタイミング機能のガイドです。

## 機能概要

Mumei言語は以下の非同期・タイミング機能を提供します:

- **sleep(seconds)** - 指定秒数待機
- **get_time()** - 現在時刻を取得（UNIX時間）
- **async_run(func, args...)** - 関数を非同期実行（将来の機能）
- **await_task(task)** - タスクの完了を待つ（将来の機能）

## 基本的な使い方

### 1. Sleep - スリープ機能

プログラムを指定秒数停止します。

```mu
print("Start");
sleep(2);  # 2秒待つ
print("After 2 seconds");

sleep(0.5);  # 0.5秒待つ
print("After 0.5 more seconds");
```

### 2. 時間の取得

現在のUNIX時間（エポックからの秒数）を取得します。

```mu
let start_time = get_time();
print("Start:", start_time);

# 何か処理をする
sleep(1);

let end_time = get_time();
let elapsed = end_time - start_time;
print("Elapsed:", elapsed, "seconds");
```

## 実用例

### タイマー

```mu
fun timer(seconds) {
    let start = get_time();
    sleep(seconds);
    let end = get_time();
    return end - start;
}

let elapsed = timer(3);
print("Timer ran for", elapsed, "seconds");
```

### カウントダウン

```mu
fun countdown(from_num) {
    let current = from_num;
    while (current > 0) {
        print(current);
        sleep(1);
        current = current - 1;
    }
    print("Go!");
}

countdown(5);
```

### プログレスバー

```mu
fun show_progress(steps) {
    let current = 0;
    while (current <= steps) {
        let percent = (current * 100) / steps;
        print("Progress:", percent, "%");
        sleep(0.2);
        current = current + 1;
    }
    print("Complete!");
}

show_progress(10);
```

### 処理時間の計測

```mu
fun measure_time(func_name) {
    print("Measuring", func_name, "...");
    let start = get_time();

    # ここで何か処理を実行
    sleep(2);  # 例として2秒の処理

    let end = get_time();
    let elapsed = end - start;
    print(func_name, "took", elapsed, "seconds");
    return elapsed;
}

measure_time("my_operation");
```

### リトライロジック

```mu
let attempts = 0;
let max_attempts = 3;
let success = false;

fun try_operation() {
    attempts = attempts + 1;
    print("Attempt", attempts);
    sleep(0.5);  # 処理時間をシミュレート

    # 何らかの条件で成功
    if (attempts >= 3) {
        return true;
    }
    return false;
}

while (attempts < max_attempts and not success) {
    success = try_operation();
    if (not success) {
        print("Retrying...");
    }
}

if (success) {
    print("Success after", attempts, "attempts");
}
```

### バッチ処理

```mu
let items = ["item1", "item2", "item3", "item4", "item5"];

fun process_item(item) {
    print("Processing", item);
    sleep(0.5);  # 処理時間
    return item + "_processed";
}

let start = get_time();
let results = [];

for (item in items) {
    let result = process_item(item);
    append(results, result);
}

let end = get_time();
print("Processed", len(results), "items in", end - start, "seconds");
```

## 将来の拡張機能

### 真の非同期実行（計画中）

```mu
# 将来的にサポート予定

# 非同期関数の実行
let task = async_run(my_function, arg1, arg2);

# 他の作業を続行
print("Task running in background");

# タスクの完了を待つ
let result = await_task(task);
print("Result:", result);
```

### 複数タスクの並列実行（計画中）

```mu
# 将来的にサポート予定

let task1 = async_run(func1);
let task2 = async_run(func2);
let task3 = async_run(func3);

# すべてのタスクを待つ
let results = wait_all(task1, task2, task3);
print("All results:", results);
```

## サンプルファイル

- `examples/async_test.mu` - 基本的な機能テスト
- `examples/async_simple.mu` - 実用的なサンプル集

## パフォーマンスノート

- `sleep()`は指定時間だけプログラムをブロックします
- 高精度タイマーが必要な場合は、`get_time()`で時間を計測してください
- 長い`sleep()`は他の処理をブロックするため注意が必要です

## トラブルシューティング

### sleepが動作しない

```mu
# 正しい
sleep(1);        # OK: 整数
sleep(1.5);      # OK: 浮動小数点数
sleep(0.1);      # OK: 小数

# エラー
sleep("1");      # NG: 文字列は不可
```

### 時間の精度

`get_time()`は秒単位の浮動小数点数を返します:

```mu
let t = get_time();
print(t);  # 例: 1697123456.789
```

ミリ秒単位で扱いたい場合:

```mu
let ms = int(get_time() * 1000);
print(ms, "ms");
```

## ライセンス

MIT License
