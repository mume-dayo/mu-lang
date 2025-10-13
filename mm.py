#!/usr/bin/env python3
"""
MM Programming Language
Main entry point
"""

import sys
from mm_interpreter import Interpreter


def print_banner():
    print("=" * 50)
    print("MM Programming Language Interpreter")
    print("Type 'exit' or press Ctrl+C to quit")
    print("=" * 50)


def repl():
    """Read-Eval-Print Loop (REPL)"""
    interpreter = Interpreter()
    print_banner()

    while True:
        try:
            source = input("mm> ")

            if source.strip() in ('exit', 'quit'):
                print("Goodbye!")
                break

            if not source.strip():
                continue

            interpreter.run(source)

        except KeyboardInterrupt:
            print("\nGoodbye!")
            break
        except EOFError:
            print("\nGoodbye!")
            break
        except Exception as e:
            print(f"Error: {e}")


def run_file(filename: str):
    """Run a .mm file"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            source = f.read()

        interpreter = Interpreter()
        interpreter.run(source)

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


def main():
    if len(sys.argv) == 1:
        # REPLモード
        repl()
    elif len(sys.argv) == 2:
        # ファイル実行モード
        filename = sys.argv[1]
        run_file(filename)
    else:
        print("Usage:")
        print("  mm.py          # Start REPL")
        print("  mm.py <file>   # Run a .mm file")
        sys.exit(1)


if __name__ == '__main__':
    main()
