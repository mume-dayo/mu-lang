# Mumei言語 例外処理デモ
# try-catch-finally構文の使い方

print("=== Mumei Exception Handling Demo ===");
print("");

# 1. 基本的なtry-catch
print("1. Basic try-catch");
try {
    print("  Attempting division...");
    let result = 10 / 0;  # ゼロ除算エラー
    print("  Result:", result);
} catch (error) {
    print("  Caught error:", error);
}
print("");

# 2. throwで例外をスロー
print("2. Throwing exceptions");
fun divide(a, b) {
    if (b == 0) {
        throw "Cannot divide by zero!";
    }
    return a / b;
}

try {
    let x = divide(10, 0);
    print("  Result:", x);
} catch (e) {
    print("  Error caught:", e);
}
print("");

# 3. finally節 - 必ず実行される
print("3. try-catch-finally");
fun open_file() {
    print("  Opening file...");
    return "file_handle";
}

fun close_file(handle) {
    print("  Closing file:", handle);
}

let file = none;
try {
    file = open_file();
    print("  Processing file...");
    throw "File processing error!";
} catch (e) {
    print("  Error:", e);
} finally {
    if (file != none) {
        close_file(file);
    }
    print("  Cleanup complete");
}
print("");

# 4. try-finally (catchなし)
print("4. try-finally without catch");
try {
    print("  Executing important code...");
    let data = [1, 2, 3];
    print("  Data:", data);
} finally {
    print("  This always runs!");
}
print("");

# 5. ネストされたtry-catch
print("5. Nested try-catch");
try {
    print("  Outer try block");
    try {
        print("    Inner try block");
        throw "Inner error";
    } catch (e) {
        print("    Inner catch:", e);
        throw "Outer error from inner catch";
    }
} catch (e) {
    print("  Outer catch:", e);
}
print("");

# 6. HTTP リクエストでの例外処理
print("6. Exception handling with HTTP requests");
try {
    print("  Fetching data from API...");
    let response = http_get("https://dog.ceo/api/breeds/image/random");
    let data = json_parse(response);
    print("  Success! Got dog image:", data["message"]);
} catch (error) {
    print("  Failed to fetch data:", error);
}
print("");

# 7. リスト操作での例外処理
print("7. Exception handling with list operations");
let numbers = [1, 2, 3, 4, 5];

try {
    print("  Accessing index 10...");
    let value = numbers[10];  # インデックスエラー
    print("  Value:", value);
} catch (e) {
    print("  Index out of range:", e);
}
print("");

# 8. 関数内での例外処理
print("8. Exception handling in functions");
fun safe_divide(a, b) {
    try {
        if (b == 0) {
            throw "Division by zero in safe_divide";
        }
        return a / b;
    } catch (e) {
        print("  Error in safe_divide:", e);
        return none;
    }
}

let result1 = safe_divide(10, 2);
print("  10 / 2 =", result1);

let result2 = safe_divide(10, 0);
print("  10 / 0 =", result2);
print("");

# 9. ユーザー入力の検証
print("9. Input validation with exceptions");
fun validate_age(age) {
    if (type(age) != "int") {
        throw "Age must be an integer";
    }
    if (age < 0) {
        throw "Age cannot be negative";
    }
    if (age > 150) {
        throw "Age is unrealistic";
    }
    return true;
}

let ages = [25, -5, 200, "abc"];
for (age in ages) {
    try {
        validate_age(age);
        print("  Age", age, "is valid");
    } catch (e) {
        print("  Invalid age", age, ":", e);
    }
}
print("");

# 10. リソース管理パターン
print("10. Resource management pattern");
fun with_resource(action) {
    let resource = "database_connection";
    try {
        print("  Acquiring resource:", resource);
        action(resource);
    } catch (e) {
        print("  Error during action:", e);
    } finally {
        print("  Releasing resource:", resource);
    }
}

fun use_database(db) {
    print("  Using database:", db);
    # 何か処理...
}

with_resource(use_database);
print("");

print("=== Demo Complete! ===");
print("");
print("Exception handling features:");
print("  - try { } catch (e) { } - Catch exceptions");
print("  - try { } finally { } - Always execute cleanup");
print("  - try { } catch (e) { } finally { } - Both");
print("  - throw <message> - Throw custom exceptions");
print("  - Nested try-catch blocks");
print("  - Exception handling in functions");
