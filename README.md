# Mumei Language - Discord Extension

Discord Bot functionality extension for Mumei programming language.

## Overview

This branch contains the Discord bot extension for Mumei language. The extension allows you to create Discord bots using simple Mumei syntax.

## Installation

### 1. Install Mumei language

First, get the Mumei language interpreter from the **main** branch.

### 2. Install discord.py

```bash
pip install discord.py
```

### 3. Use the examples

This branch contains Discord bot examples and documentation. Copy them to your Mumei project directory.

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

## Repository Branches

- **main** - Core Mumei language interpreter
- **discord-extension** - This extension (you are here)
- **vscode-extension** - VSCode syntax highlighting

Switch to the **main** branch to get the Mumei language interpreter.

## Requirements

- Mumei language interpreter (from main branch)
- Python 3.6+
- discord.py library

## License

MIT License
