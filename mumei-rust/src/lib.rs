/// Mumei Language - Rust Implementation
/// 高性能なRustベースのインタプリタコア

mod token;
mod lexer;
mod ast;
mod parser;
mod value;
mod environment;
mod interpreter;
mod builtins;
mod bytecode;
mod compiler;
mod vm;
mod vm_fast;  // 超高速数値演算専用VM
// mod cache;  // Disabled due to thread-safety issues with Rc<Environment>
mod jit;
mod http;      // HTTP client module (Rust-based, no Python dependency)
mod discord;   // Discord API module (Rust-based, REST API)
mod gateway;   // Discord Gateway (WebSocket, real-time events)

use pyo3::prelude::*;
use token::{Token as RustToken};
use lexer::Lexer;
use parser::Parser;
use interpreter::Interpreter;
use builtins::setup_builtins;
use compiler::Compiler;
use vm::VM;
use bytecode::ByteCode as RustByteCode;
use std::collections::HashMap;
use std::cell::RefCell;

/// コンパイル済みバイトコードのキャッシュ（スレッドローカル）
thread_local! {
    static BYTECODE_CACHE: RefCell<HashMap<usize, RustByteCode>> = RefCell::new(HashMap::new());
    static NEXT_BYTECODE_ID: RefCell<usize> = RefCell::new(0);
}

/// Pythonに公開するトークン型
#[pyclass]
#[derive(Clone)]
pub struct Token {
    #[pyo3(get)]
    token_type: String,
    #[pyo3(get)]
    lexeme: String,
    #[pyo3(get)]
    line: usize,
    #[pyo3(get)]
    column: usize,
}

#[pymethods]
impl Token {
    fn __repr__(&self) -> String {
        format!(
            "Token(type='{}', lexeme='{}', line={}, column={})",
            self.token_type, self.lexeme, self.line, self.column
        )
    }
}

impl From<RustToken> for Token {
    fn from(rust_token: RustToken) -> Self {
        Token {
            token_type: format!("{:?}", rust_token.token_type),
            lexeme: rust_token.lexeme,
            line: rust_token.line,
            column: rust_token.column,
        }
    }
}

/// ソースコードをトークン化する関数（Python公開）
#[pyfunction]
fn tokenize(source: String) -> PyResult<Vec<Token>> {
    let lexer = Lexer::new(source);

    match lexer.tokenize() {
        Ok(tokens) => {
            let py_tokens: Vec<Token> = tokens
                .into_iter()
                .map(|t| t.into())
                .collect();
            Ok(py_tokens)
        }
        Err(e) => Err(PyErr::new::<pyo3::exceptions::PySyntaxError, _>(
            format!("Lexer error: {}", e)
        )),
    }
}

/// トークンタイプの情報を取得（デバッグ用）
#[pyfunction]
fn get_token_types() -> Vec<String> {
    vec![
        "Number", "String", "True", "False", "Null",
        "Identifier", "Let", "Const", "Fun", "Return",
        "If", "Elif", "Else", "While", "For", "In",
        "Plus", "Minus", "Star", "Slash", "Equal",
        "LeftParen", "RightParen", "LeftBrace", "RightBrace",
        "Eof",
    ]
    .into_iter()
    .map(|s| s.to_string())
    .collect()
}

/// ベンチマーク用：大量のコードをトークン化
#[pyfunction]
fn tokenize_batch(sources: Vec<String>) -> PyResult<Vec<Vec<Token>>> {
    sources
        .into_iter()
        .map(|source| tokenize(source))
        .collect()
}

/// ソースコードをパースしてAST文字列を返す（Python公開）
#[pyfunction]
fn parse(source: String) -> PyResult<String> {
    // トークン化
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    // パース
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    // ASTを文字列として返す（デバッグ用）
    Ok(format!("{:#?}", ast))
}

/// ソースコードをパースしてAST表示（整形版）
#[pyfunction]
fn parse_pretty(source: String) -> PyResult<String> {
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    Ok(ast.pretty_print(0))
}

/// 完全なパイプライン：レキサー + パーサー（ベンチマーク用）
#[pyfunction]
fn lex_and_parse(source: String) -> PyResult<String> {
    parse(source)
}

/// ソースコードを評価して結果を返す（Python公開）
#[pyfunction]
fn evaluate(source: String) -> PyResult<String> {
    // トークン化
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    // パース
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    // インタプリタを作成して組み込み関数をセットアップ
    let mut interpreter = Interpreter::new();
    setup_builtins(&*interpreter.global_env());

    // ProgramノードからVec<ASTNode>を抽出
    use ast::ASTNode;
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // 評価
    let result = interpreter.evaluate(statements).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Runtime error: {}", e))
    })?;

    // 結果を文字列として返す
    Ok(result.to_string())
}

/// ベンチマーク用：完全なパイプライン（lex + parse + eval）
#[pyfunction]
fn run(source: String) -> PyResult<String> {
    evaluate(source)
}

// /// バイトコード経由で評価（キャッシュ付き超高速版）
// /// Disabled due to thread-safety issues with Rc<Environment> in cache
// #[pyfunction]
// fn evaluate_cached(source: String) -> PyResult<String> {
//     // キャッシュから取得を試みる
//     let bytecode = if let Some(cached) = cache::get_cached_bytecode(&source) {
//         cached
//     } else {
//         // キャッシュミス：コンパイルしてキャッシュに保存
//         let lexer = Lexer::new(source.clone());
//         let tokens = lexer.tokenize().map_err(|e| {
//             PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
//         })?;

//         let parser = Parser::new(tokens);
//         let ast = parser.parse().map_err(|e| {
//             PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
//         })?;

//         use ast::ASTNode;
//         let statements = match ast {
//             ASTNode::Program { statements } => statements,
//             single_node => vec![single_node],
//         };

//         let mut compiler = Compiler::new();
//         let bytecode = compiler.compile(statements).map_err(|e| {
//             PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Compile error: {}", e))
//         })?;

//         // キャッシュに保存
//         cache::cache_bytecode(&source, bytecode.clone());

//         bytecode
//     };

//     // VMで実行
//     let mut vm = VM::new();
//     let result = vm.execute(bytecode).map_err(|e| {
//         PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Runtime error: {}", e))
//     })?;

//     Ok(result.to_string())
// }

/// バイトコード経由で評価（キャッシュなし）
#[pyfunction]
fn evaluate_bytecode(source: String) -> PyResult<String> {
    // トークン化
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    // パース
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    // ProgramノードからVec<ASTNode>を抽出
    use ast::ASTNode;
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // バイトコードにコンパイル
    let mut compiler = Compiler::new();
    let bytecode = compiler.compile(statements).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Compile error: {}", e))
    })?;

    // VMで実行
    let mut vm = VM::new();
    let result = vm.execute(bytecode).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Runtime error: {}", e))
    })?;

    // 結果を文字列として返す
    Ok(result.to_string())
}

/// JIT経由で評価（最速版 - 簡単な算術演算のみ）
#[pyfunction]
fn evaluate_jit(source: String) -> PyResult<String> {
    // トークン化
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    // パース
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    use ast::ASTNode;
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // バイトコードにコンパイル
    let mut compiler = Compiler::new();
    let bytecode = compiler.compile(statements).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Compile error: {}", e))
    })?;

    // JITコンパイルして実行
    let mut jit_compiler = jit::JITCompiler::new().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("JIT error: {}", e))
    })?;

    let result = jit_compiler.compile_and_execute(&bytecode).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("JIT execution error: {}", e))
    })?;

    Ok(result.to_string())
}

/// ソースコードをバイトコードにコンパイル（コンパイルのみ）
/// バイトコードIDを返す
#[pyfunction]
fn compile_to_bytecode(source: String) -> PyResult<usize> {
    // トークン化
    let lexer = Lexer::new(source);
    let tokens = lexer.tokenize().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Lexer error: {}", e))
    })?;

    // パース
    let parser = Parser::new(tokens);
    let ast = parser.parse().map_err(|e| {
        PyErr::new::<pyo3::exceptions::PySyntaxError, _>(format!("Parser error: {}", e))
    })?;

    // ProgramノードからVec<ASTNode>を抽出
    use ast::ASTNode;
    let statements = match ast {
        ASTNode::Program { statements } => statements,
        single_node => vec![single_node],
    };

    // バイトコードにコンパイル
    let mut compiler = Compiler::new();
    let bytecode = compiler.compile(statements).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Compile error: {}", e))
    })?;

    // バイトコードをキャッシュに保存してIDを返す
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

/// バイトコードを実行（実行のみ - 純粋な実行速度）
#[pyfunction]
fn execute_bytecode(bytecode_id: usize) -> PyResult<String> {
    // バイトコードをキャッシュから取得
    let bytecode = BYTECODE_CACHE.with(|cache| {
        cache.borrow().get(&bytecode_id).cloned()
    }).ok_or_else(|| PyErr::new::<pyo3::exceptions::PyValueError, _>(
        format!("Invalid bytecode ID: {}", bytecode_id)
    ))?;

    // VMで実行
    let mut vm = VM::new();
    let result = vm.execute(bytecode).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Runtime error: {}", e))
    })?;

    Ok(result.to_string())
}

/// 超高速数値演算専用（f64直接返却 + SIMD最適化）
/// PyO3オーバーヘッドを最小化
#[pyfunction]
fn execute_bytecode_fast(bytecode_id: usize) -> PyResult<f64> {
    // バイトコードをキャッシュから取得
    let bytecode = BYTECODE_CACHE.with(|cache| {
        cache.borrow().get(&bytecode_id).cloned()
    }).ok_or_else(|| PyErr::new::<pyo3::exceptions::PyValueError, _>(
        format!("Invalid bytecode ID: {}", bytecode_id)
    ))?;

    // 数値演算のみの場合は超高速パスを使用
    if vm_fast::is_numeric_only(&bytecode) {
        return vm_fast::execute_numeric_fast(&bytecode).map_err(|e| {
            PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Fast path error: {}", e))
        });
    }

    // 通常のVM実行（フォールバック）
    let mut vm = VM::new();
    let result = vm.execute(bytecode).map_err(|e| {
        PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(format!("Runtime error: {}", e))
    })?;

    // 数値のみ対応
    match result {
        value::Value::Number(n) => Ok(n),
        _ => Err(PyErr::new::<pyo3::exceptions::PyTypeError, _>(
            "Result is not a number"
        ))
    }
}

/// Python モジュールの定義
#[pymodule]
fn mumei_rust(_py: Python, m: &PyModule) -> PyResult<()> {
    // レキサー関数
    m.add_function(wrap_pyfunction!(tokenize, m)?)?;
    m.add_function(wrap_pyfunction!(get_token_types, m)?)?;
    m.add_function(wrap_pyfunction!(tokenize_batch, m)?)?;

    // パーサー関数
    m.add_function(wrap_pyfunction!(parse, m)?)?;
    m.add_function(wrap_pyfunction!(parse_pretty, m)?)?;
    m.add_function(wrap_pyfunction!(lex_and_parse, m)?)?;

    // インタプリタ関数
    m.add_function(wrap_pyfunction!(evaluate, m)?)?;
    m.add_function(wrap_pyfunction!(run, m)?)?;
    m.add_function(wrap_pyfunction!(evaluate_bytecode, m)?)?;
    m.add_function(wrap_pyfunction!(evaluate_jit, m)?)?;

    // コンパイル・実行分離API（純粋な実行速度測定用）
    m.add_function(wrap_pyfunction!(compile_to_bytecode, m)?)?;
    m.add_function(wrap_pyfunction!(execute_bytecode, m)?)?;
    m.add_function(wrap_pyfunction!(execute_bytecode_fast, m)?)?;

    // クラス
    m.add_class::<Token>()?;

    // HTTP functions (Rust-based, no Python dependency)
    http::register_http_functions(m)?;

    // Discord functions (Rust-based, REST API only)
    discord::register_discord_functions(m)?;

    // Discord Gateway (WebSocket, real-time events)
    gateway::register_gateway_functions(m)?;

    // バージョン情報
    m.add("__version__", env!("CARGO_PKG_VERSION"))?;
    m.add("__author__", "Mumei Language Team")?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tokenize_simple() {
        let source = "let x = 42".to_string();
        let result = tokenize(source);
        assert!(result.is_ok());

        let tokens = result.unwrap();
        assert_eq!(tokens.len(), 5);
        assert_eq!(tokens[0].token_type, "Let");
        assert_eq!(tokens[1].token_type, "Identifier");
        assert_eq!(tokens[1].lexeme, "x");
    }

    #[test]
    fn test_tokenize_function() {
        let source = r#"
fun add(a, b) {
    return a + b;
}
"#.to_string();

        let result = tokenize(source);
        assert!(result.is_ok());
    }

    #[test]
    fn test_tokenize_error() {
        let source = "let x = !invalid".to_string();
        let result = tokenize(source);
        assert!(result.is_err());
    }
}
