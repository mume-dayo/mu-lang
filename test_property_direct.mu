# プロパティの直接テスト

print("Test 1: Without property")

class Test1 {
    fun __init__(self) {
        self.val = 10
    }

    fun get_val(self) {
        return self.val
    }
}

let t1 = new Test1()
print("Value:", t1.val)
print("Get val:", t1.get_val())

print("")
print("Done")
