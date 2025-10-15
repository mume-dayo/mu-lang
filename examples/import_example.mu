# Mumei言語でのimport/moduleの例
# 使い方: mumei import_example.mu

print("=== import/moduleシステムの例 ===");
print("");

# 例1: 基本的なimport
print("1. 基本的なimport");
import "examples/math_module" as math;

print("  math.PI =", math.PI);
print("  math.E =", math.E);
print("");

# 例2: モジュールの関数を使用
print("2. モジュールの関数を使用");
print("  math.add(10, 20) =", math.add(10, 20));
print("  math.subtract(50, 30) =", math.subtract(50, 30));
print("  math.multiply(7, 8) =", math.multiply(7, 8));
print("  math.divide(100, 4) =", math.divide(100, 4));
print("");

# 例3: 累乗と階乗
print("3. 累乗と階乗");
print("  2の10乗 =", math.power(2, 10));
print("  5の階乗 =", math.factorial(5));
print("");

# 例4: 数学関数の組み合わせ
print("4. 数学関数の組み合わせ");
let a = 15;
let b = -10;
print("  a =", a, ", b =", b);
print("  abs(b) =", math.abs(b));
print("  max(a, b) =", math.max(a, b));
print("  min(a, b) =", math.min(a, b));
print("");

# 例5: 円の面積計算
print("5. 円の面積計算");
fun circle_area(radius) {
    return math.PI * radius * radius;
}

let radius = 10;
print("  半径", radius, "の円の面積 =", circle_area(radius));
print("");

# 例6: フィボナッチ数列（モジュール関数を使用）
print("6. フィボナッチ数列");
fun fibonacci(n) {
    if (n <= 1) {
        return n;
    }
    return math.add(fibonacci(n - 1), fibonacci(n - 2));
}

print("  フィボナッチ数列（最初の10項）:");
for (i in range(10)) {
    print("    F(" + str(i) + ") =", fibonacci(i));
}
print("");

print("=== モジュールのメリット ===");
print("1. コードの再利用: 一度書いた関数を複数のファイルで使用");
print("2. 名前空間の分離: 変数名の衝突を防ぐ");
print("3. 保守性の向上: 機能ごとにファイルを分割");
print("4. キャッシング: 一度読み込んだモジュールは再利用");
