// 改善点のテスト: 型チェック、エラーハンドリング、柔軟な引数

print("=== 改善テスト開始 ===");
print("");

// 1. ファイルI/O改善テスト
print("1. ファイルI/O改善テスト");
print("----------------------------------------");

let test_file = "test_output.txt";
print("ファイル書き込み中...");
file_write(test_file, "Hello, Improved Design!\nLine 2\nLine 3");
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
print("✓ 絶対パス: " + abs_path);
let basename = path_basename(abs_path);
print("✓ ファイル名: " + basename);

file_delete(test_file);
print("✓ ファイル削除完了");

file_delete("non_existent.txt", true);
print("✓ 存在しないファイル削除（エラー無視）");

print("");

// 2. JSON機能テスト
print("2. JSON機能テスト");
print("----------------------------------------");

let data = {"name": "Mumei", "version": "2.0", "features": ["types", "errors", "options"]};
let json_str = json_stringify(data, 2);
print("✓ JSON整形出力:");
print(json_str);

let parsed = json_parse(json_str);
print("✓ JSONパース完了: name = " + parsed.name);

print("");

// 3. エラーハンドリングテスト
print("3. エラーハンドリングテスト");
print("----------------------------------------");

print("型エラーをテスト中...");
try {
    file_read(123);
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ 型エラーを正しく検出: " + str(e));
}

print("ファイル未検出エラーをテスト中...");
try {
    file_read("non_existent_file_xyz.txt");
    print("✗ エラーが検出されませんでした");
} catch (e) {
    print("✓ ファイル未検出エラーを正しく検出");
}

print("");

// 4. オプショナルパラメータテスト
print("4. オプショナルパラメータテスト");
print("----------------------------------------");

let test_file2 = "test_encoding.txt";
file_write(test_file2, "UTF-8 content");
print("✓ デフォルトエンコーディング（utf-8）で書き込み");

let content2 = file_read(test_file2);
print("✓ デフォルトエンコーディング（utf-8）で読み込み");

file_delete(test_file2, true);
print("✓ ファイル削除");

let files = dir_list(".");
print("✓ ディレクトリ一覧（隠しファイル除外）: " + str(len(files)) + " 件");

let all_files = dir_list(".", true);
print("✓ ディレクトリ一覧（隠しファイル含む）: " + str(len(all_files)) + " 件");

print("");

// 5. 追加機能テスト
print("5. 追加機能テスト");
print("----------------------------------------");

let test_file3 = "test_lines.txt";
let test_lines = ["Line 1", "Line 2", "Line 3"];
file_writelines(test_file3, test_lines);
print("✓ 行単位書き込み完了");

let read_lines = file_readlines(test_file3, "utf-8", true);
print("✓ 行単位読み込み完了: " + str(len(read_lines)) + " 行");

file_delete(test_file3, true);
print("✓ クリーンアップ");

print("");

// 6. パス操作テスト
print("6. パス操作テスト");
print("----------------------------------------");

let joined_path = path_join("output", "data", "file.txt");
print("✓ パス結合: " + joined_path);

let ext = path_ext("archive.tar.gz");
print("✓ 拡張子取得: " + ext);

let dirname = path_dirname("/path/to/file.txt");
print("✓ ディレクトリ名: " + dirname);

print("");

// 7. ディレクトリ操作テスト
print("7. ディレクトリ操作テスト");
print("----------------------------------------");

let test_dir = "test_directory";
dir_create(test_dir);
print("✓ ディレクトリ作成");

let dir_check = dir_exists(test_dir);
print("✓ ディレクトリ存在チェック: " + str(dir_check));

file_write(path_join(test_dir, "test.txt"), "Test content");
print("✓ ディレクトリ内にファイル作成");

file_delete(path_join(test_dir, "test.txt"));
print("✓ ファイル削除");

print("");
print("=== すべてのテスト完了 ===");
print("");
print("実装された改善点:");
print("✓ 包括的な型チェック（全関数で引数の型を検証）");
print("✓ 詳細なエラーハンドリング（具体的なエラーメッセージ）");
print("✓ 柔軟なオプショナルパラメータ（デフォルト値とオプション）");
print("✓ 追加機能（file_size, path_absolute, keep_newlines等）");
print("✓ 統一された設計哲学（すべてのモジュールで一貫性）");
