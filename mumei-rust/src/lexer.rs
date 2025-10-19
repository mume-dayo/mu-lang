use crate::token::{keyword_to_token_type, Token, TokenType};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum LexerError {
    #[error("Unexpected character '{0}' at line {1}:{2}")]
    UnexpectedCharacter(char, usize, usize),

    #[error("Unterminated string at line {0}:{1}")]
    UnterminatedString(usize, usize),

    #[error("Invalid number format at line {0}:{1}")]
    InvalidNumber(usize, usize),
}

pub struct Lexer {
    source: Vec<char>,
    tokens: Vec<Token>,
    start: usize,
    current: usize,
    line: usize,
    column: usize,
    indent_stack: Vec<usize>,
}

impl Lexer {
    pub fn new(source: String) -> Self {
        Lexer {
            source: source.chars().collect(),
            tokens: Vec::new(),
            start: 0,
            current: 0,
            line: 1,
            column: 1,
            indent_stack: vec![0],
        }
    }

    /// ソースコードをトークン化
    pub fn tokenize(mut self) -> Result<Vec<Token>, LexerError> {
        while !self.is_at_end() {
            self.start = self.current;
            self.scan_token()?;
        }

        // 最後にインデント解除トークンを追加
        while self.indent_stack.len() > 1 {
            self.indent_stack.pop();
            self.add_token(TokenType::Dedent);
        }

        self.add_token(TokenType::Eof);
        Ok(self.tokens)
    }

    fn scan_token(&mut self) -> Result<(), LexerError> {
        let c = self.advance();

        match c {
            // 空白とインデント
            ' ' | '\t' | '\r' => Ok(()),
            '\n' => {
                self.add_token(TokenType::Newline);
                self.line += 1;
                self.column = 1;
                self.handle_indentation()
            }

            // コメント
            '#' => {
                while self.peek() != '\n' && !self.is_at_end() {
                    self.advance();
                }
                Ok(())
            }

            // 演算子と区切り文字
            '(' => {
                self.add_token(TokenType::LeftParen);
                Ok(())
            }
            ')' => {
                self.add_token(TokenType::RightParen);
                Ok(())
            }
            '{' => {
                self.add_token(TokenType::LeftBrace);
                Ok(())
            }
            '}' => {
                self.add_token(TokenType::RightBrace);
                Ok(())
            }
            '[' => {
                self.add_token(TokenType::LeftBracket);
                Ok(())
            }
            ']' => {
                self.add_token(TokenType::RightBracket);
                Ok(())
            }
            ',' => {
                self.add_token(TokenType::Comma);
                Ok(())
            }
            '.' => {
                self.add_token(TokenType::Dot);
                Ok(())
            }
            ';' => {
                self.add_token(TokenType::Semicolon);
                Ok(())
            }
            '?' => {
                self.add_token(TokenType::Question);
                Ok(())
            }
            '@' => {
                self.add_token(TokenType::At);
                Ok(())
            }

            // 演算子（複数文字の可能性あり）
            '+' => {
                if self.match_char('=') {
                    self.add_token(TokenType::PlusAssign);
                } else {
                    self.add_token(TokenType::Plus);
                }
                Ok(())
            }
            '-' => {
                if self.match_char('=') {
                    self.add_token(TokenType::MinusAssign);
                } else if self.match_char('>') {
                    self.add_token(TokenType::Arrow);
                } else {
                    self.add_token(TokenType::Minus);
                }
                Ok(())
            }
            '*' => {
                if self.match_char('*') {
                    if self.match_char('=') {
                        self.add_token(TokenType::PowerAssign);
                    } else {
                        self.add_token(TokenType::Power);
                    }
                } else if self.match_char('=') {
                    self.add_token(TokenType::StarAssign);
                } else {
                    self.add_token(TokenType::Star);
                }
                Ok(())
            }
            '/' => {
                if self.match_char('/') {
                    if self.match_char('=') {
                        self.add_token(TokenType::FloorDivAssign);
                    } else {
                        self.add_token(TokenType::FloorDiv);
                    }
                } else if self.match_char('=') {
                    self.add_token(TokenType::SlashAssign);
                } else {
                    self.add_token(TokenType::Slash);
                }
                Ok(())
            }
            '%' => {
                if self.match_char('=') {
                    self.add_token(TokenType::PercentAssign);
                } else {
                    self.add_token(TokenType::Percent);
                }
                Ok(())
            }

            '=' => {
                if self.match_char('=') {
                    self.add_token(TokenType::Equal);
                } else if self.match_char('>') {
                    self.add_token(TokenType::FatArrow);
                } else {
                    self.add_token(TokenType::Assign);
                }
                Ok(())
            }
            '!' => {
                if self.match_char('=') {
                    self.add_token(TokenType::NotEqual);
                    Ok(())
                } else {
                    Err(LexerError::UnexpectedCharacter(c, self.line, self.column))
                }
            }
            '<' => {
                if self.match_char('=') {
                    self.add_token(TokenType::LessEqual);
                } else if self.match_char('<') {
                    self.add_token(TokenType::LeftShift);
                } else {
                    self.add_token(TokenType::Less);
                }
                Ok(())
            }
            '>' => {
                if self.match_char('=') {
                    self.add_token(TokenType::GreaterEqual);
                } else if self.match_char('>') {
                    self.add_token(TokenType::RightShift);
                } else {
                    self.add_token(TokenType::Greater);
                }
                Ok(())
            }

            ':' => {
                if self.match_char('=') {
                    self.add_token(TokenType::Walrus);
                } else {
                    self.add_token(TokenType::Colon);
                }
                Ok(())
            }

            '&' => {
                self.add_token(TokenType::BitwiseAnd);
                Ok(())
            }
            '|' => {
                self.add_token(TokenType::BitwiseOr);
                Ok(())
            }
            '^' => {
                self.add_token(TokenType::BitwiseXor);
                Ok(())
            }
            '~' => {
                self.add_token(TokenType::BitwiseNot);
                Ok(())
            }

            // 文字列リテラル
            '"' => self.string('"'),
            '\'' => self.string('\''),

            // 数値リテラル
            _ if c.is_ascii_digit() => self.number(),

            // 識別子とキーワード
            _ if c.is_alphabetic() || c == '_' => {
                self.identifier();
                Ok(())
            }

            _ => Err(LexerError::UnexpectedCharacter(c, self.line, self.column)),
        }
    }

    fn string(&mut self, quote: char) -> Result<(), LexerError> {
        while self.peek() != quote && !self.is_at_end() {
            if self.peek() == '\n' {
                self.line += 1;
                self.column = 1;
            }
            if self.peek() == '\\' {
                self.advance(); // エスケープ文字をスキップ
                if !self.is_at_end() {
                    self.advance(); // エスケープされた文字
                }
            } else {
                self.advance();
            }
        }

        if self.is_at_end() {
            return Err(LexerError::UnterminatedString(self.line, self.column));
        }

        self.advance(); // 閉じクォート
        self.add_token(TokenType::String);
        Ok(())
    }

    fn number(&mut self) -> Result<(), LexerError> {
        while self.peek().is_ascii_digit() {
            self.advance();
        }

        // 小数点チェック
        if self.peek() == '.' && self.peek_next().is_ascii_digit() {
            self.advance(); // .を消費

            while self.peek().is_ascii_digit() {
                self.advance();
            }
        }

        self.add_token(TokenType::Number);
        Ok(())
    }

    fn identifier(&mut self) {
        while self.peek().is_alphanumeric() || self.peek() == '_' {
            self.advance();
        }

        let text: String = self.source[self.start..self.current].iter().collect();
        let token_type = keyword_to_token_type(&text).unwrap_or(TokenType::Identifier);
        self.add_token(token_type);
    }

    fn handle_indentation(&mut self) -> Result<(), LexerError> {
        let mut indent = 0;
        while self.peek() == ' ' || self.peek() == '\t' {
            if self.peek() == ' ' {
                indent += 1;
            } else {
                indent += 4; // タブは4スペース相当
            }
            self.advance();
        }

        // 空行はスキップ
        if self.peek() == '\n' || self.peek() == '#' {
            return Ok(());
        }

        let current_indent = *self.indent_stack.last().unwrap();

        if indent > current_indent {
            self.indent_stack.push(indent);
            self.add_token(TokenType::Indent);
        } else if indent < current_indent {
            while let Some(&stack_indent) = self.indent_stack.last() {
                if stack_indent <= indent {
                    break;
                }
                self.indent_stack.pop();
                self.add_token(TokenType::Dedent);
            }
        }

        Ok(())
    }

    // ヘルパー関数
    fn is_at_end(&self) -> bool {
        self.current >= self.source.len()
    }

    fn advance(&mut self) -> char {
        let c = self.source[self.current];
        self.current += 1;
        self.column += 1;
        c
    }

    fn peek(&self) -> char {
        if self.is_at_end() {
            '\0'
        } else {
            self.source[self.current]
        }
    }

    fn peek_next(&self) -> char {
        if self.current + 1 >= self.source.len() {
            '\0'
        } else {
            self.source[self.current + 1]
        }
    }

    fn match_char(&mut self, expected: char) -> bool {
        if self.is_at_end() || self.source[self.current] != expected {
            false
        } else {
            self.current += 1;
            self.column += 1;
            true
        }
    }

    fn add_token(&mut self, token_type: TokenType) {
        let lexeme: String = self.source[self.start..self.current].iter().collect();
        self.tokens.push(Token::new(
            token_type,
            lexeme,
            self.line,
            self.column - (self.current - self.start),
        ));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_tokens() {
        let source = "let x = 42".to_string();
        let lexer = Lexer::new(source);
        let tokens = lexer.tokenize().unwrap();

        assert_eq!(tokens.len(), 5); // let, x, =, 42, EOF
        assert!(matches!(tokens[0].token_type, TokenType::Let));
        assert!(matches!(tokens[1].token_type, TokenType::Identifier));
        assert!(matches!(tokens[2].token_type, TokenType::Assign));
        assert!(matches!(tokens[3].token_type, TokenType::Number));
        assert!(matches!(tokens[4].token_type, TokenType::Eof));
    }

    #[test]
    fn test_string_literal() {
        let source = r#"let s = "hello world""#.to_string();
        let lexer = Lexer::new(source);
        let tokens = lexer.tokenize().unwrap();

        assert!(matches!(tokens[3].token_type, TokenType::String));
        assert_eq!(tokens[3].lexeme, r#""hello world""#);
    }

    #[test]
    fn test_operators() {
        let source = "+ - * / ** // % == != < > <= >=".to_string();
        let lexer = Lexer::new(source);
        let tokens = lexer.tokenize().unwrap();

        assert!(matches!(tokens[0].token_type, TokenType::Plus));
        assert!(matches!(tokens[1].token_type, TokenType::Minus));
        assert!(matches!(tokens[2].token_type, TokenType::Star));
        assert!(matches!(tokens[3].token_type, TokenType::Slash));
        assert!(matches!(tokens[4].token_type, TokenType::Power));
        assert!(matches!(tokens[5].token_type, TokenType::FloorDiv));
    }
}
