# 非同期処理のデモ
# Mumei言語での非同期タスク実行

print("=== Async Demo ===");
print("");

# 1. 基本的なスリープ
print("1. Basic sleep:");
print("Sleeping for 1 second...");
sleep(1);
print("Done!");
print("");

# 2. 非同期タスクの実行
print("2. Async task:");

fun slow_task(n) {
    print("  Task", n, "starting...");
    sleep(2);
    print("  Task", n, "completed!");
    return n * 2;
}

# タスクを非同期で実行
let task1 = async_run(slow_task, 1);
let task2 = async_run(slow_task, 2);
let task3 = async_run(slow_task, 3);

print("All tasks started (running in background)");
print("Waiting for results...");
print("");

# タスクの完了を待つ
let result1 = await_task(task1);
let result2 = await_task(task2);
let result3 = await_task(task3);

print("Task 1 result:", result1);
print("Task 2 result:", result2);
print("Task 3 result:", result3);
print("");

# 3. 複数のタスクを一度に待つ
print("3. Wait for multiple tasks:");

fun countdown(name, seconds) {
    print("  " + str(name) + " starting countdown from", seconds);
    let i = seconds;
    while (i > 0) {
        print("    " + str(name) + ":", i);
        sleep(0.5);
        i = i - 1;
    }
    print("  " + str(name) + " done!");
    return name + " finished";
}

let task_a = async_run(countdown, "Task A", 3);
let task_b = async_run(countdown, "Task B", 2);
let task_c = async_run(countdown, "Task C", 4);

# すべてのタスクを待つ
let results = wait_all(task_a, task_b, task_c);
print("All results:", results);
print("");

# 4. タスク完了チェック
print("4. Task completion check:");

fun long_task() {
    print("  Long task running...");
    sleep(3);
    return "completed";
}

let long = async_run(long_task);

# タスクが完了するまでチェック
let waiting = 0;
while (not task_done(long)) {
    print("  Still waiting... (" + str(waiting) + "s)");
    sleep(0.5);
    waiting = waiting + 0.5;
}

print("  Task is done!");
let result = await_task(long);
print("  Result:", result);
print("");

# 5. 実用例: 並列データ処理
print("5. Practical example - parallel data processing:");

let data = [1, 2, 3, 4, 5];

fun process_data(item) {
    print("  Processing item", item);
    sleep(0.5);  # シミュレート処理時間
    return item * item;
}

print("Processing", len(data), "items in parallel...");

let start_time = get_time();

# すべてのアイテムを並列処理
let tasks = [];
for (item in data) {
    let t = async_run(process_data, item);
    append(tasks, t);
}

# すべての結果を取得
let processed = [];
for (task in tasks) {
    let result = await_task(task);
    append(processed, result);
}

let end_time = get_time();
let elapsed = end_time - start_time;

print("Results:", processed);
print("Time taken:", elapsed, "seconds");
print("(Sequential would take ~2.5 seconds)");
print("");

print("=== Demo Complete ===");
