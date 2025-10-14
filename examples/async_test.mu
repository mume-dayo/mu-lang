# クイック非同期テスト

print("Testing async features...");
print("");

# Sleep関数のテスト
print("1. Sleep test:");
print("Before sleep");
sleep(1);
print("After 1 second sleep");
print("");

# 時間取得のテスト
print("2. Time test:");
let t1 = get_time();
sleep(0.5);
let t2 = get_time();
let diff = t2 - t1;
print("Time elapsed:", diff, "seconds");
print("");

print("All tests passed!");
