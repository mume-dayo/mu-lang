// 統一設計のテスト: 非同期処理、型チェック、エラーハンドリング、柔軟な引数

print("=== 統一設計テスト開始 ===");
print("");

// 1. 非同期処理のテスト（asyncio統一）
print("1. 非同期処理テスト");
print("----------------------------------------");

// sleepのテスト
print("sleep(1)を実行中...");
let sleep_task = sleep(1);
await sleep_task;
print("✓ sleep完了");

// async_runのテスト
fun heavy_work(n) {
    let sum = 0;
    for (let i = 0; i < n; i = i + 1) {
        sum = sum + i;
    }
    return sum;
}

print("async_runで重い計算を実行中...");
let work_task = async_run(heavy_work, 1000);
let result = await work_task;
print("✓ async_run完了: " + str(result));

// wait_allのテスト
print("複数タスクを並列実行...");
let task1 = sleep(0.5);
let task2 = sleep(0.5);
let task3 = sleep(0.5);
let all_results = await wait_all(task1, task2, task3);
print("✓ wait_all完了");

// delayのテスト
print("delay(1秒後に実行)...");
let delay_task = delay(1, print, "✓ 遅延実行完了");
await delay_task;

print("");

// 2. ファイルI/O改善のテスト
print("2. ファイルI/O改善テスト");
print("----------------------------------------");

// 型チェック付きファイル書き込み
let test_file = "test_output.txt";
print("ファイル書き込み中...");
file_write(test_file, "Hello, Unified Design!\nLine 2\nLine 3");
print("✓ ファイル書き込み完了");

// ファイル読み込み
print("ファイル読み込み中...");
let content = file_read(test_file);
print("✓ 読み込み完了: " + str(len(content)) + " バイト");

// ファイルサイズ取得（新機能）
let size = file_size(test_file);
print("✓ ファイルサイズ: " + str(size) + " バイト");

// 行単位読み込み（改行削除オプション）
let lines = file_readlines(test_file, "utf-8", false);
print("✓ 行数: " + str(len(lines)));
for (let i = 0; i < len(lines); i = i + 1) {
    print("  行" + str(i + 1) + ": " + lines[i]);
}

// パス操作
let abs_path = path_absolute(test_file);
print("✓ 絶対パス: " + abs_path);
let basename = path_basename(abs_path);
print("✓ ファイル名: " + basename);

// ファイル削除（ignore_missingオプション）
file_delete(test_file);
print("✓ ファイル削除完了");

// 存在しないファイルを削除（エラーを無視）
file_delete("non_existent_file.txt", true);
print("✓ 存在しないファイル削除（エラー無視）");

print("");

// 3. HTTP機能改善のテスト
print("3. HTTP機能改善テスト");
print("----------------------------------------");

// JSON操作のテスト
let data = {"name": "Mumei", "version": "2.0", "features": ["async", "types", "errors"]};
let json_str = json_stringify(data, 2);
print("✓ JSON整形出力:");
print(json_str);

let parsed = json_parse(json_str);
print("✓ JSONパース完了: name = " + parsed.name);

print("");

// 4. エラーハンドリングのテスト
print("4. エラーハンドリングテスト");
print("----------------------------------------");

// 型エラーのテスト
print("型エラーをテスト中...");
try {
    file_read(123);  // 数値を渡すとTypeError
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ 型エラーを正しく検出: " + str(e));
}

// ファイル未検出エラーのテスト
print("ファイル未検出エラーをテスト中...");
try {
    file_read("non_existent_file_xyz.txt");
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ ファイル未検出エラーを正しく検出");
}

print("");

// 5. オプショナルパラメータのテスト
print("5. オプショナルパラメータテスト");
print("----------------------------------------");

// デフォルト値の使用
let test_file2 = "test_encoding.txt";
file_write(test_file2, "UTF-8 content");  // encoding省略（デフォルトutf-8）
print("✓ デフォルトエンコーディングで書き込み");

let content2 = file_read(test_file2);  // encoding省略
print("✓ デフォルトエンコーディングで読み込み");

file_delete(test_file2, true);
print("✓ ファイル削除");

// ディレクトリ一覧（隠しファイル除外）
let files = dir_list(".");
print("✓ ディレクトリ一覧（隠しファイル除外）: " + str(len(files)) + " 件");

print("");

// 6. 統合テスト：非同期ファイルI/O
print("6. 統合テスト：非同期ファイルI/O");
print("----------------------------------------");

print("非同期ファイル書き込み開始...");
let async_file = "async_test.txt";
let write_task = file_write(async_file, "Async content!", "utf-8", true);
await write_task;
print("✓ 非同期書き込み完了");

print("非同期ファイル読み込み開始...");
let read_task = file_read(async_file, "utf-8", true);
let async_content = await read_task;
print("✓ 非同期読み込み完了: " + async_content);

file_delete(async_file, true);
print("✓ クリーンアップ完了");

print("");
print("=== すべてのテスト完了 ===");
print("");
print("改善点まとめ:");
print("✓ 非同期処理の統一（asyncio.create_task()）");
print("✓ 包括的な型チェック");
print("✓ 詳細なエラーハンドリング");
print("✓ 柔軟なオプショナルパラメータ");
print("✓ 完全なモジュール統合");
