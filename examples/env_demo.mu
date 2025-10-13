# 環境変数のデモ
# 使い方: mumei env_demo.mu

print("=== Environment Variables Demo ===");
print("");

# 環境変数を取得
print("1. Getting environment variables:");
let user = env("USER");
let home = env("HOME");
let path = env("PATH");

print("  USER =", user);
print("  HOME =", home);
print("  PATH =", path);
print("");

# デフォルト値を指定して取得
print("2. Getting with default value:");
let api_key = env("API_KEY", "not_set");
let debug_mode = env("DEBUG", "false");

print("  API_KEY =", api_key);
print("  DEBUG =", debug_mode);
print("");

# 環境変数の存在チェック
print("3. Checking if environment variable exists:");
let has_user = env_has("USER");
let has_api_key = env_has("API_KEY");

print("  USER exists?", has_user);
print("  API_KEY exists?", has_api_key);
print("");

# 環境変数を設定（プロセス内のみ）
print("4. Setting environment variables:");
env_set("MY_VAR", "Hello from Mumei");
env_set("MY_NUMBER", "42");

let my_var = env("MY_VAR");
let my_number = env("MY_NUMBER");

print("  MY_VAR =", my_var);
print("  MY_NUMBER =", my_number);
print("");

# 環境変数一覧（最初の10個だけ表示）
print("5. Listing environment variables (first 10):");
let all_vars = env_list();
let count = 0;

for (var_name in all_vars) {
    if (count < 10) {
        let value = env(var_name);
        print("  " + str(var_name) + " = " + str(value));
        count = count + 1;
    }
}

print("");
print("Total environment variables:", len(all_vars));
print("");

# 実用例: 設定ファイルの代わりに環境変数を使う
print("6. Practical example - Configuration:");

fun get_config(key, default) {
    let value = env(key, default);
    print("  Config[" + str(key) + "] =", value);
    return value;
}

let app_name = get_config("APP_NAME", "MyApp");
let app_port = get_config("APP_PORT", "8080");
let app_debug = get_config("APP_DEBUG", "false");

print("");
print("Application configuration loaded!");
print("");

# セキュリティのヒント
print("7. Security tip:");
print("  Use environment variables for sensitive data like:");
print("  - API keys");
print("  - Database passwords");
print("  - Discord bot tokens");
print("  - Secret keys");
print("");
print("  Never commit sensitive data to your code repository!");
print("");

print("=== Demo Complete ===");
