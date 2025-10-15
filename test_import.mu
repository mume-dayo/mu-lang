print("Testing import");

import "examples/simple_module" as mod;

print("Module loaded");
print(mod.greeting);
print(mod.say_hello("World"));
