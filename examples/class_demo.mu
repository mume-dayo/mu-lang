# Mumei言語 クラスとOOPデモ
# オブジェクト指向プログラミングの基本

print("=== Mumei Class and OOP Demo ===");
print("");

# 1. 基本的なクラス定義
print("1. Basic class definition");

class Person {
    fun __init__(self, name, age) {
        self.name = name;
        self.age = age;
    }

    fun greet(self) {
        return "Hello, I'm " + str(self.name) + ", " + str(self.age) + " years old.";
    }

    fun birthday(self) {
        self.age = self.age + 1;
        return "Happy birthday! Now " + str(self.age) + " years old.";
    }
}

let alice = new Person("Alice", 25);
print("  alice.greet() =", alice.greet());
print("  alice.birthday() =", alice.birthday());
print("  alice.name =", alice.name);
print("  alice.age =", alice.age);
print("");

# 2. 複数のインスタンス
print("2. Multiple instances");
let bob = new Person("Bob", 30);
let carol = new Person("Carol", 28);

print("  ", alice.greet());
print("  ", bob.greet());
print("  ", carol.greet());
print("");

# 3. メソッドの呼び出し
print("3. Method calls");
fun introduce_person(person) {
    print("  ", person.greet());
}

introduce_person(alice);
introduce_person(bob);
print("");

# 4. より複雑なクラス - 銀行口座
print("4. Bank Account class");

class BankAccount {
    fun __init__(self, owner, balance) {
        self.owner = owner;
        self.balance = balance;
    }

    fun deposit(self, amount) {
        self.balance = self.balance + amount;
        return "Deposited " + str(amount) + ". New balance: " + str(self.balance);
    }

    fun withdraw(self, amount) {
        if (self.balance >= amount) {
            self.balance = self.balance - amount;
            return "Withdrew " + str(amount) + ". New balance: " + str(self.balance);
        } else {
            return "Insufficient funds!";
        }
    }

    fun get_balance(self) {
        return self.owner + "'s balance: " + str(self.balance);
    }
}

let account = new BankAccount("Alice", 1000);
print("  ", account.get_balance());
print("  ", account.deposit(500));
print("  ", account.withdraw(300));
print("  ", account.withdraw(2000));
print("  ", account.get_balance());
print("");

# 5. カウンタークラス
print("5. Counter class");

class Counter {
    fun __init__(self, start) {
        self.count = start;
    }

    fun increment(self) {
        self.count = self.count + 1;
        return self.count;
    }

    fun decrement(self) {
        self.count = self.count - 1;
        return self.count;
    }

    fun reset(self) {
        self.count = 0;
        return "Counter reset";
    }

    fun get_value(self) {
        return self.count;
    }
}

let counter = new Counter(0);
print("  Initial:", counter.get_value());
print("  Increment:", counter.increment());
print("  Increment:", counter.increment());
print("  Increment:", counter.increment());
print("  Decrement:", counter.decrement());
print("  Current:", counter.get_value());
print("  ", counter.reset());
print("  After reset:", counter.get_value());
print("");

# 6. Pointクラス（座標）
print("6. Point class");

class Point {
    fun __init__(self, x, y) {
        self.x = x;
        self.y = y;
    }

    fun distance_from_origin(self) {
        let dx = self.x * self.x;
        let dy = self.y * self.y;
        return sqrt(dx + dy);
    }

    fun move(self, dx, dy) {
        self.x = self.x + dx;
        self.y = self.y + dy;
        return "Moved to (" + str(self.x) + ", " + str(self.y) + ")";
    }

    fun to_string(self) {
        return "Point(" + str(self.x) + ", " + str(self.y) + ")";
    }
}

let p1 = new Point(3, 4);
print("  ", p1.to_string());
print("  Distance from origin:", p1.distance_from_origin());
print("  ", p1.move(2, -1));
print("  ", p1.to_string());
print("");

# 7. 型チェック
print("7. Type checking");
print("  type(alice) =", type(alice));
print("  type(account) =", type(account));
print("  type(Person) =", type(Person));
print("");

print("=== Demo Complete! ===");
print("OOP features:");
print("  - class ClassName { }");
print("  - fun __init__(self, ...) { } constructor");
print("  - self.property for instance variables");
print("  - new ClassName(...) for instantiation");
print("  - instance.method() for method calls");
print("  - instance.property for property access");
