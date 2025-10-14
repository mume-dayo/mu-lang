# Mumei言語の新しい制御構文の例
# 使い方: mumei control_flow_features.mu

print("=== Mumei Control Flow Features Demo ===");
print("");

# 1. elif文の例
print("1. elif statement example:");
let score = 75;
if (score >= 90) {
    print("  Grade: A");
} elif (score >= 80) {
    print("  Grade: B");
} elif (score >= 70) {
    print("  Grade: C");
} elif (score >= 60) {
    print("  Grade: D");
} else {
    print("  Grade: F");
}
print("");

# 2. break文の例
print("2. break statement example:");
print("  Counting to 10, but breaking at 5:");
let i = 1;
while (i <= 10) {
    if (i == 5) {
        print("    Breaking at " + str(i));
        break;
    }
    print("    Count: " + str(i));
    i = i + 1;
}
print("");

# 3. continue文の例
print("3. continue statement example:");
print("  Printing odd numbers from 1 to 10:");
for (num in range(1, 11)) {
    if (num % 2 == 0) {
        continue;
    }
    print("    " + str(num));
}
print("");

# 4. pass文の例
print("4. pass statement example:");
print("  Using pass as a placeholder:");
let x = 5;
if (x > 0) {
    pass;  # プレースホルダー、何もしない
}
print("  Pass statement executed (no output)");
print("");

# 5. 三項演算子の例
print("5. ternary operator example:");
let age = 20;
let status = "adult" if age >= 18 else "minor";
print("  Age: " + str(age) + ", Status: " + status);

let temperature = 25;
let weather = "hot" if temperature > 30 else "cold" if temperature < 15 else "moderate";
print("  Temperature: " + str(temperature) + "°C, Weather: " + weather);
print("");

# 6. ウォルラス演算子の例
print("6. walrus operator (:=) example:");
print("  Processing a list with walrus operator:");
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
for (n in numbers) {
    if ((doubled := n * 2) > 10) {
        print("    " + str(n) + " * 2 = " + str(doubled) + " (greater than 10)");
    }
}
print("");

# 7. match/case文の例
print("7. match/case statement example:");
fun describe_number(n) {
    match (n) {
        case 0:
            return "zero";
        case 1:
            return "one";
        case 2:
            return "two";
        case 3:
            return "three";
        case _:
            return "other";
    }
}

print("  0 -> " + describe_number(0));
print("  1 -> " + describe_number(1));
print("  2 -> " + describe_number(2));
print("  5 -> " + describe_number(5));
print("");

# 8. match/caseでの文字列パターンマッチ
print("8. match/case with strings:");
fun get_greeting(lang) {
    match (lang) {
        case "ja":
            return "こんにちは";
        case "en":
            return "Hello";
        case "es":
            return "Hola";
        case "fr":
            return "Bonjour";
        case _:
            return "Unknown language";
    }
}

print("  ja -> " + get_greeting("ja"));
print("  en -> " + get_greeting("en"));
print("  de -> " + get_greeting("de"));
print("");

# 9. 複雑な三項演算子の例
print("9. nested ternary operator:");
let value = 42;
let category = "small" if value < 10 else "medium" if value < 50 else "large" if value < 100 else "huge";
print("  Value: " + str(value) + ", Category: " + category);
print("");

# 10. break/continueとelif/ternaryの組み合わせ
print("10. combining multiple features:");
for (i in range(1, 21)) {
    if (i % 15 == 0) {
        print("  FizzBuzz (" + str(i) + ")");
        continue;
    } elif (i % 3 == 0) {
        print("  Fizz (" + str(i) + ")");
        continue;
    } elif (i % 5 == 0) {
        print("  Buzz (" + str(i) + ")");
        continue;
    }

    let message = "even" if i % 2 == 0 else "odd";
    print("  " + str(i) + " is " + message);

    if (i >= 15) {
        print("  Reached 15, breaking...");
        break;
    }
}

print("");
print("=== Demo completed! ===");
