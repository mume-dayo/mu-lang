# Mumei言語のwith文の例
# 使い方: mumei with_statement_example.mu

print("=== Mumei With Statement Demo ===");
print("");

# with文のためのコンテキストマネージャークラスを定義
class FileContext {
    fun __init__(self, filename) {
        self.filename = filename;
        self.is_open = false;
        print("  Opening file: " + self.filename);
        self.is_open = true;
    }

    fun read(self) {
        if (self.is_open) {
            return "File content from " + self.filename;
        } else {
            return "Error: File is not open";
        }
    }

    fun close(self) {
        if (self.is_open) {
            print("  Closing file: " + self.filename);
            self.is_open = false;
        }
    }
}

# 1. with文の基本的な使い方
print("1. Basic with statement:");
with (new FileContext("data.txt") as file) {
    let content = file.read();
    print("  Read: " + content);
}
print("  File automatically closed!");
print("");

# 2. with文なしでの比較（手動でclose）
print("2. Without with statement (manual close):");
let file2 = new FileContext("manual.txt");
let content2 = file2.read();
print("  Read: " + content2);
file2.close();
print("  Manually closed file");
print("");

# 3. データベースコネクションのような例
class DatabaseConnection {
    fun __init__(self, db_name) {
        self.db_name = db_name;
        self.connected = false;
        print("  Connecting to database: " + self.db_name);
        self.connected = true;
    }

    fun query(self, sql) {
        if (self.connected) {
            return "Query result from " + self.db_name + ": " + sql;
        } else {
            return "Error: Not connected";
        }
    }

    fun close(self) {
        if (self.connected) {
            print("  Disconnecting from database: " + self.db_name);
            self.connected = false;
        }
    }
}

print("3. Database connection with 'with' statement:");
with (new DatabaseConnection("users_db") as db) {
    let result = db.query("SELECT * FROM users");
    print("  " + result);
}
print("  Database connection automatically closed!");
print("");

# 4. タイマーのような例
class Timer {
    fun __init__(self, name) {
        self.name = name;
        print("  Timer '" + self.name + "' started");
    }

    fun close(self) {
        print("  Timer '" + self.name + "' stopped");
    }
}

print("4. Timer example:");
with (new Timer("Operation Timer") as timer) {
    print("  Performing some operations...");
    let sum = 0;
    for (i in range(1, 101)) {
        sum = sum + i;
    }
    print("  Sum of 1 to 100: " + str(sum));
}
print("");

print("=== Demo completed! ===");
