/// Mumei Language - Standalone CLI
/// スタンドアロンのRust実装 - Python依存なし

use mumei_rust::*;
use std::env;
use std::fs;
use std::io::{self, Write};
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_usage();
        process::exit(1);
    }

    match args[1].as_str() {
        "-h" | "--help" => {
            print_help();
        }
        "-v" | "--version" => {
            println!("Mumei Language v{}", env!("CARGO_PKG_VERSION"));
            println!("100% Rust implementation - No Python dependencies");
        }
        "-i" | "--interactive" | "repl" => {
            run_repl();
        }
        file_path => {
            run_file(file_path);
        }
    }
}

fn print_usage() {
    eprintln!("Usage: mumei [options] <file.mu>");
    eprintln!("       mumei -i | --interactive  # Start REPL");
    eprintln!("       mumei -h | --help         # Show help");
    eprintln!("       mumei -v | --version      # Show version");
}

fn print_help() {
    println!("Mumei Language - High-performance Rust implementation");
    println!();
    println!("Usage:");
    println!("  mumei <file.mu>           Execute a Mumei script");
    println!("  mumei -i, --interactive   Start interactive REPL");
    println!("  mumei repl                Start interactive REPL");
    println!("  mumei -h, --help          Show this help message");
    println!("  mumei -v, --version       Show version information");
    println!();
    println!("Examples:");
    println!("  mumei hello.mu            # Run hello.mu");
    println!("  mumei -i                  # Start REPL");
    println!();
    println!("Features:");
    println!("  ✓ 100% Rust implementation");
    println!("  ✓ No Python dependencies");
    println!("  ✓ 3-10x faster than Python");
    println!("  ✓ Discord bot support (Gateway + REST API)");
    println!("  ✓ HTTP/WebSocket support");
}

fn run_file(file_path: &str) {
    // ファイルを読み込む
    let source = match fs::read_to_string(file_path) {
        Ok(content) => content,
        Err(e) => {
            eprintln!("Error reading file '{}': {}", file_path, e);
            process::exit(1);
        }
    };

    // 実行
    match execute_mumei(&source) {
        Ok(result) => {
            if result != "null" && !result.is_empty() {
                println!("{}", result);
            }
        }
        Err(e) => {
            eprintln!("Runtime error: {}", e);
            process::exit(1);
        }
    }
}

fn run_repl() {
    println!("Mumei Language REPL v{}", env!("CARGO_PKG_VERSION"));
    println!("Type 'exit' or Ctrl+C to quit");
    println!();

    let stdin = io::stdin();
    let mut interpreter = interpreter::Interpreter::new();
    builtins::setup_builtins(&*interpreter.global_env());

    loop {
        print!(">>> ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        match stdin.read_line(&mut input) {
            Ok(_) => {
                let input = input.trim();

                if input.is_empty() {
                    continue;
                }

                if input == "exit" || input == "quit" {
                    println!("Goodbye!");
                    break;
                }

                // 実行
                match execute_line(&mut interpreter, input) {
                    Ok(result) => {
                        if result != "null" && !result.is_empty() {
                            println!("{}", result);
                        }
                    }
                    Err(e) => {
                        eprintln!("Error: {}", e);
                    }
                }
            }
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                break;
            }
        }
    }
}

fn execute_mumei(source: &str) -> Result<String, String> {
    use lexer::Lexer;
    use parser::Parser;
    use interpreter::Interpreter;
    use ast::ASTNode;

    // Lexer
    let lexer = Lexer::new(source.to_string());
    let tokens = lexer.tokenize().map_err(|e| format!("Lexer error: {}", e))?;

    // Parser
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| format!("Parser error: {}", e))?;

    // Interpreter
    let mut interpreter = Interpreter::new();
    builtins::setup_builtins(&*interpreter.global_env());

    // Extract statements from Program node
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // Execute
    let result = interpreter.evaluate(statements).map_err(|e| format!("Runtime error: {}", e))?;

    Ok(result.to_string())
}

fn execute_line(interpreter: &mut interpreter::Interpreter, source: &str) -> Result<String, String> {
    use lexer::Lexer;
    use parser::Parser;
    use ast::ASTNode;

    // Lexer
    let lexer = Lexer::new(source.to_string());
    let tokens = lexer.tokenize().map_err(|e| format!("Lexer error: {}", e))?;

    // Parser
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| format!("Parser error: {}", e))?;

    // Extract statements
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // Execute
    let result = interpreter.evaluate(statements).map_err(|e| format!("Runtime error: {}", e))?;

    Ok(result.to_string())
}
