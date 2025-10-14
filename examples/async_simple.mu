# シンプルな非同期処理デモ
# sleepとタイミング機能を使用

print("=== Simple Async Demo ===");
print("");

# 1. 基本的なスリープ
print("1. Sleep function:");
print("Start:", get_time());
sleep(1);
print("After 1 second:", get_time());
sleep(2);
print("After 3 seconds total:", get_time());
print("");

# 2. タイマー実装
print("2. Timer:");
let start = get_time();

for (i in range(1, 6)) {
    print("Step", i);
    sleep(0.5);
}

let end = get_time();
let elapsed = end - start;
print("Total time:", elapsed, "seconds");
print("");

# 3. カウントダウン
print("3. Countdown:");

fun countdown(from_num) {
    let current = from_num;
    while (current > 0) {
        print("  ", current);
        sleep(1);
        current = current - 1;
    }
    print("  Go!");
}

countdown(5);
print("");

# 4. プログレスバー風
print("4. Progress bar:");

fun show_progress(steps) {
    let current = 0;
    while (current <= steps) {
        let percent = (current * 100) / steps;
        print("  Progress:", percent, "%");
        sleep(0.3);
        current = current + 1;
    }
    print("  Complete!");
}

show_progress(10);
print("");

# 5. 実用例: バッチ処理
print("5. Batch processing simulation:");

let items = ["file1.txt", "file2.txt", "file3.txt", "file4.txt", "file5.txt"];

fun process_file(filename) {
    print("  Processing", filename, "...");
    sleep(0.5);  # 処理時間をシミュレート
    print("  ", filename, "completed");
    return filename + ".processed";
}

let processed_files = [];
let batch_start = get_time();

for (file in items) {
    let result = process_file(file);
    append(processed_files, result);
}

let batch_end = get_time();
print("Processed files:", len(processed_files));
print("Total time:", batch_end - batch_start, "seconds");
print("");

# 6. リトライロジック
print("6. Retry logic:");

let attempts = 0;
let max_attempts = 3;
let success = false;

fun try_operation() {
    attempts = attempts + 1;
    print("  Attempt", attempts);
    sleep(0.5);

    # 3回目で成功すると仮定
    if (attempts >= 3) {
        return true;
    }
    return false;
}

while (attempts < max_attempts and not success) {
    success = try_operation();
    if (not success) {
        print("  Failed, retrying...");
    }
}

if (success) {
    print("  Operation succeeded after", attempts, "attempts");
} else {
    print("  Operation failed after", max_attempts, "attempts");
}
print("");

print("=== Demo Complete ===");
