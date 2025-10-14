# Mumei Language - VSCode Extension

Visual Studio Code extension for Mumei (`.mu`) programming language syntax highlighting.

## Features

- 🎨 **Syntax Highlighting** - Beautiful color coding for Mumei code
- 🔧 **Auto-closing brackets** - `()`, `[]`, `{}`
- 📝 **Auto-closing quotes** - `"`, `'`
- 💬 **Comment toggling** - `Cmd+/` or `Ctrl+/`
- 🎯 **Bracket matching** - Highlights matching brackets
- 📦 **Code folding** - Fold code blocks

## Installation

### Quick Install (Recommended)

```bash
./install.sh       # macOS/Linux
# or
install.bat        # Windows
```

Restart VSCode and open any `.mu` file!

### Manual Install

**macOS/Linux:**
```bash
cp -r . ~/.vscode/extensions/mumei-language-1.0.0
```

**Windows:**
```powershell
Copy-Item -Recurse . "$env:USERPROFILE\.vscode\extensions\mumei-language-1.0.0"
```

## Supported Syntax

### Keywords
- Control: `if`, `else`, `while`, `for`, `in`, `return`
- Declarations: `let`, `fun`
- Async: `async`, `await`
- Logical: `and`, `or`, `not`

### Built-in Functions
- Basic: `print`, `input`, `len`, `type`, `str`, `int`, `float`, `range`, `append`, `pop`
- Environment: `env`, `env_set`, `env_has`, `env_list`
- Async: `sleep`, `get_time`, `async_run`, `await_task`
- Discord: `discord_create_bot`, `discord_command`, `discord_on_event`, `discord_run`

### Constants
- Boolean: `true`, `false`
- Null: `none`

## Example

```mu
# Comments are green
let x = 10;  # let is purple (keyword)

fun hello(name) {  # fun is also purple
    return "Hello, " + name;  # strings are orange/red
}

print(hello("World"));  # print is blue (built-in)

# Async functions
sleep(1);  # blue
let time = get_time();  # blue

# Numbers and constants
let num = 42;        # green/blue
let pi = 3.14;       # green/blue
let is_true = true;  # blue
```

## Color Themes

Works with all VSCode themes. Recommended:
- **Dark**: Dark+, One Dark Pro, Dracula
- **Light**: Light+, Solarized Light

## Main Repository

This is the **vscode-extension** branch. For the Mumei language interpreter, see the **main** branch.

## Repository Branches

- **main** - Core Mumei language interpreter
- **discord-extension** - Discord bot functionality
- **vscode-extension** - This extension (you are here)

## Documentation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

## Version

1.0.0

## License

MIT License
