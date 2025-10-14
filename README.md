# Mumei Language - Discord Extension

Discord Bot functionality extension for Mumei programming language.

## Overview

This branch contains the Discord bot extension for Mumei language. The extension allows you to create Discord bots using simple Mumei syntax.

## Installation

### 1. Install discord.py

```bash
pip install discord.py
```

### 2. Copy the Discord module

The Discord extension consists of a single file:
- `mm_discord.py` - Discord bot module

Copy it to your Mumei language directory, and the interpreter will automatically detect and load it.

## Quick Start

### Basic Bot

```mu
# Create bot
discord_create_bot("!");

# Define command
fun cmd_hello(ctx) {
    return "Hello from Mumei!";
}

# Register command
discord_command("hello", cmd_hello);

# Run bot
let token = env("DISCORD_BOT_TOKEN");
discord_run(token);
```

### Setting Token

```bash
# Set environment variable
export DISCORD_BOT_TOKEN="your_token_here"

# Run bot
mumei discord_bot_simple.mu
```

## Available Functions

- **discord_create_bot(prefix)** - Create bot instance
- **discord_command(name, callback)** - Register command
- **discord_on_event(event, callback)** - Register event handler
- **discord_run(token)** - Start bot

## Examples

This branch includes:
- `examples/discord_bot_simple.mu` - Simple bot
- `examples/discord_bot_advanced.mu` - Advanced bot
- `examples/DISCORD_QUICKSTART.md` - 5-minute guide

## Documentation

See `DISCORD_BOT.md` for complete documentation.

## Main Repository

This is the Discord extension branch. For the core Mumei language:

👉 **Main Branch**: https://github.com/mume-dayo/mu-lang

## Other Branches

- **main** - Core Mumei language
- **discord-extension** - This extension (you are here)
- **vscode-extension** - VSCode syntax highlighting

## Requirements

- Mumei language interpreter (from main branch)
- Python 3.6+
- discord.py library

## License

MIT License
