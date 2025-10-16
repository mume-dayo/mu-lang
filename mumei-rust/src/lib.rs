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

use pyo3::prelude::*;
use pyo3::types::PyDict;
use token::{Token as RustToken, TokenType};
use lexer::Lexer;
use parser::Parser;
use ast::ASTNode;
use interpreter::Interpreter;
use builtins::setup_builtins;

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

    // 評価
    let result = interpreter.evaluate(ast).map_err(|e| {
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

    // クラス
    m.add_class::<Token>()?;

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
