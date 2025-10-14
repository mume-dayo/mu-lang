# Mumei言語 ファイルI/Oデモ
# ファイル操作の基本

print("=== Mumei File I/O Demo ===");
print("");

# 1. ファイルへの書き込み
print("1. Writing to file");
let content = "Hello, Mumei!\nThis is a test file.\nLine 3";
file_write("test.txt", content);
print("  Wrote to test.txt");
print("");

# 2. ファイルの読み込み
print("2. Reading from file");
let read_content = file_read("test.txt");
print("  Content:");
print(read_content);
print("");

# 3. ファイルの存在確認
print("3. Checking file existence");
print("  file_exists('test.txt') =", file_exists("test.txt"));
print("  file_exists('nonexistent.txt') =", file_exists("nonexistent.txt"));
print("");

# 4. ファイルへの追記
print("4. Appending to file");
file_append("test.txt", "\nAppended line");
let updated_content = file_read("test.txt");
print("  Content after append:");
print(updated_content);
print("");

# 5. 行ごとに読み込み
print("5. Reading lines");
let lines = file_readlines("test.txt");
print("  Number of lines:", len(lines));
for (line in lines) {
    print("   ", strip(line));
}
print("");

# 6. 行のリストを書き込み
print("6. Writing lines");
let new_lines = ["Line 1", "Line 2", "Line 3"];
file_writelines("lines.txt", new_lines);
print("  Wrote lines to lines.txt");

let read_lines = file_readlines("lines.txt");
print("  Read back:");
for (l in read_lines) {
    print("   ", strip(l));
}
print("");

# 7. ディレクトリ操作
print("7. Directory operations");

# ディレクトリ作成
dir_create("test_dir");
print("  Created directory: test_dir");

# ディレクトリ存在確認
print("  dir_exists('test_dir') =", dir_exists("test_dir"));

# ファイル一覧
let files = dir_list(".");
print("  Files in current directory:");
for (f in files) {
    print("   ", f);
}
print("");

# 8. パス操作
print("8. Path operations");
let joined_path = path_join("folder", "subfolder", "file.txt");
print("  path_join('folder', 'subfolder', 'file.txt') =", joined_path);

let basename = path_basename("/path/to/file.txt");
print("  path_basename('/path/to/file.txt') =", basename);

let dirname = path_dirname("/path/to/file.txt");
print("  path_dirname('/path/to/file.txt') =", dirname);

let ext = path_ext("document.pdf");
print("  path_ext('document.pdf') =", ext);
print("");

# 9. ファイル削除
print("9. Deleting files");
file_delete("test.txt");
print("  Deleted test.txt");
print("  file_exists('test.txt') =", file_exists("test.txt"));
print("");

# クリーンアップ
file_delete("lines.txt");
print("Cleanup complete");
print("");

print("=== Demo Complete! ===");
print("File I/O functions:");
print("  - file_read(path) - Read file");
print("  - file_write(path, content) - Write file");
print("  - file_append(path, content) - Append to file");
print("  - file_exists(path) - Check if file exists");
print("  - file_delete(path) - Delete file");
print("  - file_readlines(path) - Read lines");
print("  - file_writelines(path, lines) - Write lines");
print("  - dir_list(path) - List directory");
print("  - dir_create(path) - Create directory");
print("  - path_join(...) - Join paths");
