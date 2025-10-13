# Mumei Language Support for Visual Studio Code

Syntax highlighting and language support for Mumei (`.mu`) programming language.

## Features

- **Syntax Highlighting**: Beautiful color coding for Mumei code
- **Auto-closing brackets**: Automatic closing of `()`, `[]`, `{}`
- **Auto-closing quotes**: Automatic closing of `"` and `'`
- **Comment toggling**: Use `Cmd+/` (Mac) or `Ctrl+/` (Windows/Linux)
- **Bracket matching**: Highlights matching brackets
- **Code folding**: Fold code blocks with `{}`

## Supported Syntax

### Keywords
- Control flow: `if`, `else`, `while`, `for`, `in`, `return`
- Declarations: `let`, `fun`
- Logical operators: `and`, `or`, `not`

### Built-in Functions
- Basic: `print`, `input`, `len`, `type`, `str`, `int`, `float`, `range`, `append`, `pop`
- Environment: `env`, `env_set`, `env_has`, `env_list`
- Discord: `discord_create_bot`, `discord_command`, `discord_on_event`, `discord_run`

### Constants
- Boolean: `true`, `false`
- Null: `none`

### Comments
- Line comments: `#` or `//`
- Block comments: `/* ... */`

## Installation

### From VSIX (Recommended)

1. Download the `.vsix` file
2. Open VSCode
3. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
4. Type "Install from VSIX"
5. Select the downloaded file

### Manual Installation

1. Copy the `vscode-mumei` folder to:
   - **macOS/Linux**: `~/.vscode/extensions/`
   - **Windows**: `%USERPROFILE%\.vscode\extensions\`
2. Restart VSCode

## Usage

Once installed, all `.mu` files will automatically get syntax highlighting!

### Example

```mu
# Mumei code with syntax highlighting
let x = 10;
let name = "Mumei";

fun greet(name) {
    return "Hello, " + name + "!";
}

if (x > 5) {
    print(greet(name));
}

# Discord bot example
discord_create_bot("!");

fun cmd_hello(ctx) {
    return "Hello from Mumei!";
}

discord_command("hello", cmd_hello);
```

## Color Themes

The extension works with all VSCode color themes. For best results, we recommend:
- **Dark**: Dark+ (default), One Dark Pro, Dracula
- **Light**: Light+ (default), Solarized Light

## Commands

- **Toggle Line Comment**: `Cmd+/` or `Ctrl+/`
- **Toggle Block Comment**: `Shift+Alt+A`
- **Format Document**: `Shift+Alt+F`

## Known Issues

None at the moment. Please report issues on GitHub!

## Release Notes

### 1.0.0

- Initial release
- Syntax highlighting for all Mumei keywords
- Support for Discord bot functions
- Environment variable functions
- Auto-closing pairs
- Comment toggling

## Contributing

Contributions are welcome! Please visit our GitHub repository.

## License

MIT License

---

**Enjoy coding in Mumei!** 🚀
