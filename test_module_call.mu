import "examples/simple_module" as mod;

print("Testing module method call");
print(mod.greeting);

let result = mod.say_hello("World");
print(result);
