/// Mumei Language - Rust Implementation
/// 高性能なRustベースのインタプリタコア
/// 100% Rust - Python依存なし

// コアモジュール
pub mod token;
pub mod lexer;
pub mod ast;
pub mod parser;
pub mod value;
pub mod environment;
pub mod interpreter;
pub mod builtins;
pub mod bytecode;
pub mod compiler;
pub mod vm;
pub mod vm_fast;  // 超高速数値演算専用VM
pub mod jit;

// 外部機能モジュール（一時的に無効化 - PyO3依存を削除中）
// TODO: これらをbuilt-in関数として再実装する
// pub mod http;      // HTTP client module (Rust-based, no Python dependency)
// pub mod discord;   // Discord API module (Rust-based, REST API)
// pub mod gateway;   // Discord Gateway (WebSocket, real-time events)

use std::collections::HashMap;
use std::cell::RefCell;
use bytecode::ByteCode as RustByteCode;

/// コンパイル済みバイトコードのキャッシュ（スレッドローカル）
thread_local! {
    static BYTECODE_CACHE: RefCell<HashMap<usize, RustByteCode>> = RefCell::new(HashMap::new());
    static NEXT_BYTECODE_ID: RefCell<usize> = RefCell::new(0);
}

/// バイトコードキャッシュAPI
pub mod bytecode_cache {
    use super::*;

    pub fn compile_and_cache(source: &str) -> Result<usize, String> {
        use lexer::Lexer;
        use parser::Parser;
        use compiler::Compiler;
        use ast::ASTNode;

        // Tokenize
        let lexer = Lexer::new(source.to_string());
        let tokens = lexer.tokenize().map_err(|e| format!("Lexer error: {}", e))?;

        // Parse
        let parser = Parser::new(tokens);
        let ast = parser.parse().map_err(|e| format!("Parser error: {}", e))?;

        // Extract statements
        let statements = match ast {
            ASTNode::Program { statements } => statements,
            single_node => vec![single_node],
        };

        // Compile to bytecode
        let mut compiler = Compiler::new();
        let bytecode = compiler.compile(statements).map_err(|e| format!("Compile error: {}", e))?;

        // Cache and return ID
        let id = NEXT_BYTECODE_ID.with(|counter| {
            let mut c = counter.borrow_mut();
            let id = *c;
            *c += 1;
            id
        });

        BYTECODE_CACHE.with(|cache| {
            cache.borrow_mut().insert(id, bytecode);
        });

        Ok(id)
    }

    pub fn execute_cached(bytecode_id: usize) -> Result<String, String> {
        use vm::VM;

        // Get bytecode from cache
        let bytecode = BYTECODE_CACHE.with(|cache| {
            cache.borrow().get(&bytecode_id).cloned()
        }).ok_or_else(|| format!("Invalid bytecode ID: {}", bytecode_id))?;

        // Execute on VM
        let mut vm = VM::new();
        let result = vm.execute(bytecode).map_err(|e| format!("Runtime error: {}", e))?;

        Ok(result.to_string())
    }

    pub fn execute_cached_fast(bytecode_id: usize) -> Result<f64, String> {
        use vm::VM;
        use vm_fast;
        use value::Value;

        // Get bytecode from cache
        let bytecode = BYTECODE_CACHE.with(|cache| {
            cache.borrow().get(&bytecode_id).cloned()
        }).ok_or_else(|| format!("Invalid bytecode ID: {}", bytecode_id))?;

        // Try fast path for numeric-only code
        if vm_fast::is_numeric_only(&bytecode) {
            return vm_fast::execute_numeric_fast(&bytecode);
        }

        // Fallback to normal VM
        let mut vm = VM::new();
        let result = vm.execute(bytecode).map_err(|e| format!("Runtime error: {}", e))?;

        // Extract number
        match result {
            Value::Number(n) => Ok(n),
            _ => Err("Result is not a number".to_string())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_execution() {
        use lexer::Lexer;
        use parser::Parser;
        use interpreter::Interpreter;
        use ast::ASTNode;

        let source = "let x = 42; x";

        let lexer = Lexer::new(source.to_string());
        let tokens = lexer.tokenize().unwrap();

        let parser = Parser::new(tokens);
        let ast = parser.parse().unwrap();

        let statements = match ast {
            ASTNode::Program { statements } => statements,
            single_node => vec![single_node],
        };

        let mut interpreter = Interpreter::new();
        builtins::setup_builtins(&*interpreter.global_env());

        let result = interpreter.evaluate(statements).unwrap();
        assert_eq!(result.to_string(), "42");
    }

    #[test]
    fn test_bytecode_cache() {
        let source = "1 + 2 + 3";
        let id = bytecode_cache::compile_and_cache(source).unwrap();
        let result = bytecode_cache::execute_cached(id).unwrap();
        assert_eq!(result, "6");
    }
}
