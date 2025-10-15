# Mumei言語のasync/awaitの例
# 使い方: mumei async_await_example.mu

print("=== Mumei Async/Await Demo ===");
print("");

# 1. 基本的なasync関数の定義とawait
print("1. Basic async function:");
async fun fetch_data(url) {
    print("  Fetching data from " + url + "...");
    sleep(1);  # 1秒待機してAPIリクエストをシミュレート
    return "Data from " + url;
}

let task1 = fetch_data("https://api.example.com/users");
print("  Task started (non-blocking)");
let result1 = await task1;
print("  Result: " + result1);
print("");

# 2. 複数のasync関数を並行実行
print("2. Parallel async execution:");
async fun download_file(filename) {
    print("  Downloading " + filename + "...");
    sleep(2);
    return filename + " downloaded";
}

let start_time = get_time();
let task_a = download_file("file_a.txt");
let task_b = download_file("file_b.txt");
let task_c = download_file("file_c.txt");

print("  All tasks started...");
let result_a = await task_a;
let result_b = await task_b;
let result_c = await task_c;

let elapsed = get_time() - start_time;
print("  " + result_a);
print("  " + result_b);
print("  " + result_c);
print("  Total time: ~" + str(int(elapsed)) + " seconds");
print("");

# 3. async関数の中でawaitを使用
print("3. Await inside async function:");
async fun process_data() {
    print("  Step 1: Fetching user data...");
    let user_task = fetch_data("https://api.example.com/user/123");
    let user_data = await user_task;

    print("  Step 2: Fetching user posts...");
    let posts_task = fetch_data("https://api.example.com/posts");
    let posts_data = await posts_task;

    return "Processed: " + user_data + " and " + posts_data;
}

let process_task = process_data();
let final_result = await process_task;
print("  " + final_result);
print("");

# 4. タスクの状態チェック
print("4. Task status checking:");
async fun long_operation() {
    sleep(3);
    return "Long operation completed";
}

let long_task = long_operation();
print("  Task started...");
sleep(1);

if (task_done(long_task)) {
    print("  Task is already done!");
} else {
    print("  Task is still running...");
    let result4 = await long_task;
    print("  " + result4);
}
print("");

# 5. 複数タスクの結果を一括取得
print("5. Wait for all tasks:");
async fun calculate(n) {
    sleep(1);
    return n * n;
}

let tasks = [
    calculate(2),
    calculate(3),
    calculate(4),
    calculate(5)
];

print("  Calculating squares in parallel...");
let results = wait_all(tasks[0], tasks[1], tasks[2], tasks[3]);
print("  Results: " + str(results));
print("");

# 6. エラーハンドリングを含むasync関数
print("6. Async with error handling:");
async fun risky_operation(should_fail) {
    sleep(1);
    if (should_fail) {
        throw "Operation failed!";
    }
    return "Operation succeeded";
}

try {
    let safe_task = risky_operation(false);
    let safe_result = await safe_task;
    print("  " + safe_result);
} catch (e) {
    print("  Caught error: " + e);
}
print("");

# 7. 非同期でデータを処理
print("7. Async data processing:");
async fun process_number(n) {
    sleep(0.5);
    return n * 2;
}

let numbers = [1, 2, 3, 4, 5];
let processing_tasks = [];

print("  Processing numbers asynchronously...");
for (num in numbers) {
    let t = process_number(num);
    append(processing_tasks, t);
}

let processed = wait_all(
    processing_tasks[0],
    processing_tasks[1],
    processing_tasks[2],
    processing_tasks[3],
    processing_tasks[4]
);
print("  Original: " + str(numbers));
print("  Processed: " + str(processed));
print("");

# 8. タイムアウト付きのasync操作
print("8. Async with timing:");
async fun timed_operation(duration, name) {
    let start = get_time();
    sleep(duration);
    let end = get_time();
    let elapsed = end - start;
    return name + " took " + str(int(elapsed)) + " seconds";
}

let timed_task = timed_operation(2, "Task A");
let timing_result = await timed_task;
print("  " + timing_result);
print("");

# 9. 順次実行 vs 並行実行の比較
print("9. Sequential vs Parallel:");

# 順次実行
print("  Sequential execution:");
let seq_start = get_time();
let r1 = await fetch_data("https://api.example.com/1");
let r2 = await fetch_data("https://api.example.com/2");
let r3 = await fetch_data("https://api.example.com/3");
let seq_time = get_time() - seq_start;
print("    Time: ~" + str(int(seq_time)) + " seconds");

# 並行実行
print("  Parallel execution:");
let par_start = get_time();
let pt1 = fetch_data("https://api.example.com/1");
let pt2 = fetch_data("https://api.example.com/2");
let pt3 = fetch_data("https://api.example.com/3");
let pr1 = await pt1;
let pr2 = await pt2;
let pr3 = await pt3;
let par_time = get_time() - par_start;
print("    Time: ~" + str(int(par_time)) + " seconds");
print("");

# 10. 実用例: Webスクレイピングのシミュレーション
print("10. Practical example - web scraping simulation:");
async fun scrape_page(page_num) {
    print("  Scraping page " + str(page_num) + "...");
    sleep(1.5);
    return "Page " + str(page_num) + " data";
}

let page_tasks = [];
for (i in range(1, 4)) {
    append(page_tasks, scrape_page(i));
}

let scraped_data = wait_all(page_tasks[0], page_tasks[1], page_tasks[2]);
print("  Scraped data: " + str(scraped_data));
print("");

print("=== Demo completed! ===");
