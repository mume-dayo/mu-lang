# プロパティのみのテスト

print("Creating class...")

class Test {
    fun __init__(self) {
        self.value = 42
    }
}

print("Creating instance...")
let t = new Test()
print("Getting value:", t.value)
print("Done")
