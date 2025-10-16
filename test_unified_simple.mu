// 統一設計の簡易テスト

print("=== 統一設計テスト開始 ===");
print("");

// 1. 非同期処理テスト（asyncio統一）
print("1. 非同期処理テスト");
print("----------------------------------------");

print("sleep(0.5)を実行中...");
let sleep_task = sleep(0.5);
await sleep_task;
print("✓ sleep完了");

print("wait_allテスト...");
let task1 = sleep(0.3);
let task2 = sleep(0.3);
let all_results = await wait_all(task1, task2);
print("✓ wait_all完了");

print("");

// 2. ファイルI/O改善テスト
print("2. ファイルI/O改善テスト");
print("----------------------------------------");

let test_file = "test_output.txt";
print("ファイル書き込み中...");
file_write(test_file, "Hello, Unified Design!\nLine 2\nLine 3");
print("✓ ファイル書き込み完了");

print("ファイル読み込み中...");
let content = file_read(test_file);
print("✓ 読み込み完了: " + str(len(content)) + " バイト");

let size = file_size(test_file);
print("✓ ファイルサイズ: " + str(size) + " バイト");

let lines = file_readlines(test_file, "utf-8", false);
print("✓ 行数: " + str(len(lines)));
let line_idx = 0;
for (line in lines) {
    line_idx = line_idx + 1;
    print("  行" + str(line_idx) + ": " + line);
}

let abs_path = path_absolute(test_file);
print("✓ 絶対パス取得完了");
let basename = path_basename(abs_path);
print("✓ ファイル名: " + basename);

file_delete(test_file);
print("✓ ファイル削除完了");

file_delete("non_existent.txt", true);
print("✓ 存在しないファイル削除（エラー無視）");

print("");

// 3. JSON機能テスト
print("3. JSON機能テスト");
print("----------------------------------------");

let data = {"name": "Mumei", "version": "2.0", "features": ["async", "types", "errors"]};
let json_str = json_stringify(data, 2);
print("✓ JSON整形出力:");
print(json_str);

let parsed = json_parse(json_str);
print("✓ JSONパース完了: name = " + parsed.name);

print("");

// 4. エラーハンドリングテスト
print("4. エラーハンドリングテスト");
print("----------------------------------------");

print("型エラーをテスト中...");
try {
    file_read(123);
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ 型エラーを正しく検出");
}

print("ファイル未検出エラーをテスト中...");
try {
    file_read("non_existent_file_xyz.txt");
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ ファイル未検出エラーを正しく検出");
}

print("");

// 5. オプショナルパラメータテスト
print("5. オプショナルパラメータテスト");
print("----------------------------------------");

let test_file2 = "test_encoding.txt";
file_write(test_file2, "UTF-8 content");
print("✓ デフォルトエンコーディングで書き込み");

let content2 = file_read(test_file2);
print("✓ デフォルトエンコーディングで読み込み");

file_delete(test_file2, true);
print("✓ ファイル削除");

let files = dir_list(".");
print("✓ ディレクトリ一覧: " + str(len(files)) + " 件");

print("");

// 6. 非同期ファイルI/O統合テスト
print("6. 非同期ファイルI/O統合テスト");
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
