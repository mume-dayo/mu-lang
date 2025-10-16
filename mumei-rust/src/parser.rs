/// パーサー - トークンからASTを構築
use crate::ast::*;
use crate::token::{Token, TokenType};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParserError {
    #[error("Unexpected token: expected {expected}, got {got} at line {line}:{column}")]
    UnexpectedToken {
        expected: String,
        got: String,
        line: usize,
        column: usize,
    },

    #[error("Unexpected end of input")]
    UnexpectedEof,

    #[error("Invalid syntax at line {line}:{column}: {message}")]
    InvalidSyntax {
        message: String,
        line: usize,
        column: usize,
    },
}

pub struct Parser {
    tokens: Vec<Token>,
    current: usize,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Parser { tokens, current: 0 }
    }

    /// トークンからASTを構築
    pub fn parse(mut self) -> Result<ASTNode, ParserError> {
        let mut statements = Vec::new();

        // NEWLINEとINDENT/DEDENTをスキップ
        self.skip_newlines();

        while !self.is_at_end() {
            statements.push(self.statement()?);
            self.skip_newlines();
        }

        Ok(ASTNode::Program { statements })
    }

    /// 文のパース
    fn statement(&mut self) -> Result<ASTNode, ParserError> {
        // let/const宣言
        if self.match_token(&[TokenType::Let, TokenType::Const]) {
            return self.variable_declaration();
        }

        // 関数定義
        if self.match_token(&[TokenType::Fun, TokenType::AsyncFun]) {
            return self.function_declaration();
        }

        // return文
        if self.match_token(&[TokenType::Return]) {
            return self.return_statement();
        }

        // yield文
        if self.match_token(&[TokenType::Yield]) {
            return self.yield_statement();
        }

        // if文
        if self.match_token(&[TokenType::If]) {
            return self.if_statement();
        }

        // while文
        if self.match_token(&[TokenType::While]) {
            return self.while_statement();
        }

        // for文
        if self.match_token(&[TokenType::For]) {
            return self.for_statement();
        }

        // break文
        if self.match_token(&[TokenType::Break]) {
            self.skip_newlines();
            return Ok(ASTNode::BreakStatement);
        }

        // continue文
        if self.match_token(&[TokenType::Continue]) {
            self.skip_newlines();
            return Ok(ASTNode::ContinueStatement);
        }

        // pass文
        if self.match_token(&[TokenType::Pass]) {
            self.skip_newlines();
            return Ok(ASTNode::PassStatement);
        }

        // assert文
        if self.match_token(&[TokenType::Assert]) {
            return self.assert_statement();
        }

        // 式文
        let expr = self.expression()?;
        self.skip_newlines();
        Ok(expr)
    }

    /// 変数宣言
    fn variable_declaration(&mut self) -> Result<ASTNode, ParserError> {
        let is_const = self.previous().token_type == TokenType::Const;

        let name = self.consume_identifier("variable name")?;

        self.consume(&TokenType::Assign, "=")?;

        let value = Box::new(self.expression()?);

        self.skip_newlines();

        Ok(ASTNode::VariableDeclaration {
            name,
            value,
            is_const,
        })
    }

    /// 関数定義
    fn function_declaration(&mut self) -> Result<ASTNode, ParserError> {
        let is_async = self.previous().token_type == TokenType::AsyncFun;

        let name = self.consume_identifier("function name")?;

        self.consume(&TokenType::LeftParen, "(")?;

        let mut parameters = Vec::new();
        if !self.check(&TokenType::RightParen) {
            loop {
                parameters.push(self.consume_identifier("parameter name")?);

                if !self.match_token(&[TokenType::Comma]) {
                    break;
                }
            }
        }

        self.consume(&TokenType::RightParen, ")")?;
        self.consume(&TokenType::LeftBrace, "{")?;
        self.skip_newlines();

        let body = self.block()?;

        self.consume(&TokenType::RightBrace, "}")?;
        self.skip_newlines();

        Ok(ASTNode::FunctionDeclaration {
            name,
            parameters,
            body,
            is_async,
        })
    }

    /// ブロック（複数の文）
    fn block(&mut self) -> Result<Vec<ASTNode>, ParserError> {
        let mut statements = Vec::new();

        while !self.check(&TokenType::RightBrace) && !self.is_at_end() {
            statements.push(self.statement()?);
            self.skip_newlines();
        }

        Ok(statements)
    }

    /// return文
    fn return_statement(&mut self) -> Result<ASTNode, ParserError> {
        let value = if self.check(&TokenType::Newline) || self.check(&TokenType::Semicolon) {
            None
        } else {
            Some(Box::new(self.expression()?))
        };

        self.skip_newlines();

        Ok(ASTNode::ReturnStatement { value })
    }

    /// yield文
    fn yield_statement(&mut self) -> Result<ASTNode, ParserError> {
        let value = Box::new(self.expression()?);
        self.skip_newlines();

        Ok(ASTNode::YieldStatement { value })
    }

    /// if文
    fn if_statement(&mut self) -> Result<ASTNode, ParserError> {
        let condition = Box::new(self.expression()?);

        self.consume(&TokenType::LeftBrace, "{")?;
        self.skip_newlines();

        let then_body = self.block()?;

        self.consume(&TokenType::RightBrace, "}")?;
        self.skip_newlines();

        let mut elif_clauses = Vec::new();
        while self.match_token(&[TokenType::Elif]) {
            let elif_condition = self.expression()?;
            self.consume(&TokenType::LeftBrace, "{")?;
            self.skip_newlines();

            let elif_body = self.block()?;

            self.consume(&TokenType::RightBrace, "}")?;
            self.skip_newlines();

            elif_clauses.push((elif_condition, elif_body));
        }

        let else_body = if self.match_token(&[TokenType::Else]) {
            self.consume(&TokenType::LeftBrace, "{")?;
            self.skip_newlines();

            let body = self.block()?;

            self.consume(&TokenType::RightBrace, "}")?;
            self.skip_newlines();

            Some(body)
        } else {
            None
        };

        Ok(ASTNode::IfStatement {
            condition,
            then_body,
            elif_clauses,
            else_body,
        })
    }

    /// while文
    fn while_statement(&mut self) -> Result<ASTNode, ParserError> {
        let condition = Box::new(self.expression()?);

        self.consume(&TokenType::LeftBrace, "{")?;
        self.skip_newlines();

        let body = self.block()?;

        self.consume(&TokenType::RightBrace, "}")?;
        self.skip_newlines();

        Ok(ASTNode::WhileStatement { condition, body })
    }

    /// for文
    fn for_statement(&mut self) -> Result<ASTNode, ParserError> {
        self.consume(&TokenType::LeftParen, "(")?;

        let variable = self.consume_identifier("loop variable")?;

        self.consume(&TokenType::In, "in")?;

        let iterable = Box::new(self.expression()?);

        self.consume(&TokenType::RightParen, ")")?;
        self.consume(&TokenType::LeftBrace, "{")?;
        self.skip_newlines();

        let body = self.block()?;

        self.consume(&TokenType::RightBrace, "}")?;
        self.skip_newlines();

        Ok(ASTNode::ForStatement {
            variable,
            iterable,
            body,
        })
    }

    /// assert文
    fn assert_statement(&mut self) -> Result<ASTNode, ParserError> {
        let condition = Box::new(self.expression()?);

        let message = if self.match_token(&[TokenType::Comma]) {
            Some(Box::new(self.expression()?))
        } else {
            None
        };

        self.skip_newlines();

        Ok(ASTNode::AssertStatement { condition, message })
    }

    /// 式のパース
    fn expression(&mut self) -> Result<ASTNode, ParserError> {
        self.assignment()
    }

    /// 代入
    fn assignment(&mut self) -> Result<ASTNode, ParserError> {
        let expr = self.ternary()?;

        if self.match_token(&[TokenType::Assign]) {
            let value = Box::new(self.assignment()?);
            return Ok(ASTNode::Assignment {
                target: Box::new(expr),
                value,
            });
        }

        // 複合代入
        if let Some(op) = self.match_compound_assignment() {
            let value = Box::new(self.assignment()?);
            return Ok(ASTNode::CompoundAssignment {
                target: Box::new(expr),
                operator: op,
                value,
            });
        }

        Ok(expr)
    }

    /// 複合代入演算子のマッチング
    fn match_compound_assignment(&mut self) -> Option<BinaryOperator> {
        let op = match self.peek().token_type {
            TokenType::PlusAssign => Some(BinaryOperator::Add),
            TokenType::MinusAssign => Some(BinaryOperator::Subtract),
            TokenType::StarAssign => Some(BinaryOperator::Multiply),
            TokenType::SlashAssign => Some(BinaryOperator::Divide),
            TokenType::PercentAssign => Some(BinaryOperator::Modulo),
            _ => None,
        };

        if op.is_some() {
            self.advance();
        }

        op
    }

    /// 三項演算子
    fn ternary(&mut self) -> Result<ASTNode, ParserError> {
        let mut expr = self.logical_or()?;

        if self.match_token(&[TokenType::Question]) {
            let true_value = Box::new(self.expression()?);
            self.consume(&TokenType::Colon, ":")?;
            let false_value = Box::new(self.expression()?);

            expr = ASTNode::TernaryOperation {
                condition: Box::new(expr),
                true_value,
                false_value,
            };
        }

        Ok(expr)
    }

    /// 論理OR
    fn logical_or(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.logical_and()?;

        while self.match_token(&[TokenType::Or]) {
            let right = Box::new(self.logical_and()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: BinaryOperator::Or,
                right,
            };
        }

        Ok(left)
    }

    /// 論理AND
    fn logical_and(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.equality()?;

        while self.match_token(&[TokenType::And]) {
            let right = Box::new(self.equality()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: BinaryOperator::And,
                right,
            };
        }

        Ok(left)
    }

    /// 比較演算子
    fn equality(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.comparison()?;

        while let Some(op) = self.match_binary_operator(&[TokenType::Equal, TokenType::NotEqual]) {
            let right = Box::new(self.comparison()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: op,
                right,
            };
        }

        Ok(left)
    }

    /// 比較
    fn comparison(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.term()?;

        while let Some(op) = self.match_binary_operator(&[
            TokenType::Less,
            TokenType::Greater,
            TokenType::LessEqual,
            TokenType::GreaterEqual,
        ]) {
            let right = Box::new(self.term()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: op,
                right,
            };
        }

        Ok(left)
    }

    /// 加減算
    fn term(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.factor()?;

        while let Some(op) = self.match_binary_operator(&[TokenType::Plus, TokenType::Minus]) {
            let right = Box::new(self.factor()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: op,
                right,
            };
        }

        Ok(left)
    }

    /// 乗除算
    fn factor(&mut self) -> Result<ASTNode, ParserError> {
        let mut left = self.unary()?;

        while let Some(op) =
            self.match_binary_operator(&[TokenType::Star, TokenType::Slash, TokenType::Percent])
        {
            let right = Box::new(self.unary()?);
            left = ASTNode::BinaryOperation {
                left: Box::new(left),
                operator: op,
                right,
            };
        }

        Ok(left)
    }

    /// 単項演算
    fn unary(&mut self) -> Result<ASTNode, ParserError> {
        if self.match_token(&[TokenType::Not]) {
            let operand = Box::new(self.unary()?);
            return Ok(ASTNode::UnaryOperation {
                operator: UnaryOperator::Not,
                operand,
            });
        }

        if self.match_token(&[TokenType::Minus]) {
            let operand = Box::new(self.unary()?);
            return Ok(ASTNode::UnaryOperation {
                operator: UnaryOperator::Negate,
                operand,
            });
        }

        self.postfix()
    }

    /// 後置演算子（関数呼び出し、インデックスアクセス等）
    fn postfix(&mut self) -> Result<ASTNode, ParserError> {
        let mut expr = self.primary()?;

        loop {
            if self.match_token(&[TokenType::LeftParen]) {
                // 関数呼び出し
                expr = self.finish_call(expr)?;
            } else if self.match_token(&[TokenType::LeftBracket]) {
                // インデックスアクセス
                let index = Box::new(self.expression()?);
                self.consume(&TokenType::RightBracket, "]")?;
                expr = ASTNode::IndexAccess {
                    object: Box::new(expr),
                    index,
                };
            } else if self.match_token(&[TokenType::Dot]) {
                // メンバーアクセス
                let member = self.consume_identifier("property name")?;
                expr = ASTNode::MemberAccess {
                    object: Box::new(expr),
                    member,
                };
            } else {
                break;
            }
        }

        Ok(expr)
    }

    /// 関数呼び出しの完了
    fn finish_call(&mut self, callee: ASTNode) -> Result<ASTNode, ParserError> {
        let mut arguments = Vec::new();

        if !self.check(&TokenType::RightParen) {
            loop {
                arguments.push(self.expression()?);

                if !self.match_token(&[TokenType::Comma]) {
                    break;
                }
            }
        }

        self.consume(&TokenType::RightParen, ")")?;

        Ok(ASTNode::FunctionCall {
            callee: Box::new(callee),
            arguments,
        })
    }

    /// プライマリ式
    fn primary(&mut self) -> Result<ASTNode, ParserError> {
        // リテラル
        if self.match_token(&[TokenType::True]) {
            return Ok(ASTNode::Boolean(true));
        }

        if self.match_token(&[TokenType::False]) {
            return Ok(ASTNode::Boolean(false));
        }

        if self.match_token(&[TokenType::Null]) {
            return Ok(ASTNode::Null);
        }

        // 数値
        if let TokenType::Number = self.peek().token_type {
            let token = self.advance();
            let value = token.lexeme.parse::<f64>().map_err(|_| {
                ParserError::InvalidSyntax {
                    message: format!("Invalid number: {}", token.lexeme),
                    line: token.line,
                    column: token.column,
                }
            })?;
            return Ok(ASTNode::Number(value));
        }

        // 文字列
        if let TokenType::String = self.peek().token_type {
            let token = self.advance();
            // クォートを削除
            let value = token.lexeme[1..token.lexeme.len() - 1].to_string();
            return Ok(ASTNode::String(value));
        }

        // 識別子
        if let TokenType::Identifier = self.peek().token_type {
            let name = self.advance().lexeme;
            return Ok(ASTNode::Identifier(name));
        }

        // リスト
        if self.match_token(&[TokenType::LeftBracket]) {
            return self.list();
        }

        // 辞書
        if self.match_token(&[TokenType::LeftBrace]) {
            return self.dictionary();
        }

        // グループ化
        if self.match_token(&[TokenType::LeftParen]) {
            let expr = self.expression()?;
            self.consume(&TokenType::RightParen, ")")?;
            return Ok(expr);
        }

        // await式
        if self.match_token(&[TokenType::Await]) {
            let expression = Box::new(self.expression()?);
            return Ok(ASTNode::AwaitExpression { expression });
        }

        Err(ParserError::UnexpectedToken {
            expected: "expression".to_string(),
            got: format!("{:?}", self.peek().token_type),
            line: self.peek().line,
            column: self.peek().column,
        })
    }

    /// リスト
    fn list(&mut self) -> Result<ASTNode, ParserError> {
        let mut elements = Vec::new();

        if !self.check(&TokenType::RightBracket) {
            loop {
                elements.push(self.expression()?);

                if !self.match_token(&[TokenType::Comma]) {
                    break;
                }
            }
        }

        self.consume(&TokenType::RightBracket, "]")?;

        Ok(ASTNode::List { elements })
    }

    /// 辞書
    fn dictionary(&mut self) -> Result<ASTNode, ParserError> {
        let mut pairs = Vec::new();

        if !self.check(&TokenType::RightBrace) {
            loop {
                let key = self.expression()?;
                self.consume(&TokenType::Colon, ":")?;
                let value = self.expression()?;

                pairs.push((key, value));

                if !self.match_token(&[TokenType::Comma]) {
                    break;
                }
            }
        }

        self.consume(&TokenType::RightBrace, "}")?;

        Ok(ASTNode::Dictionary { pairs })
    }

    // ヘルパーメソッド
    fn match_token(&mut self, types: &[TokenType]) -> bool {
        for token_type in types {
            if self.check(token_type) {
                self.advance();
                return true;
            }
        }
        false
    }

    fn match_binary_operator(&mut self, types: &[TokenType]) -> Option<BinaryOperator> {
        let op = match self.peek().token_type {
            TokenType::Plus => Some(BinaryOperator::Add),
            TokenType::Minus => Some(BinaryOperator::Subtract),
            TokenType::Star => Some(BinaryOperator::Multiply),
            TokenType::Slash => Some(BinaryOperator::Divide),
            TokenType::Percent => Some(BinaryOperator::Modulo),
            TokenType::Power => Some(BinaryOperator::Power),
            TokenType::Equal => Some(BinaryOperator::Equal),
            TokenType::NotEqual => Some(BinaryOperator::NotEqual),
            TokenType::Less => Some(BinaryOperator::Less),
            TokenType::Greater => Some(BinaryOperator::Greater),
            TokenType::LessEqual => Some(BinaryOperator::LessEqual),
            TokenType::GreaterEqual => Some(BinaryOperator::GreaterEqual),
            _ => None,
        };

        if op.is_some() && types.contains(&self.peek().token_type) {
            self.advance();
            op
        } else {
            None
        }
    }

    fn check(&self, token_type: &TokenType) -> bool {
        if self.is_at_end() {
            return false;
        }
        std::mem::discriminant(&self.peek().token_type) == std::mem::discriminant(token_type)
    }

    fn advance(&mut self) -> Token {
        if !self.is_at_end() {
            self.current += 1;
        }
        self.previous()
    }

    fn is_at_end(&self) -> bool {
        matches!(self.peek().token_type, TokenType::Eof)
    }

    fn peek(&self) -> &Token {
        &self.tokens[self.current]
    }

    fn previous(&self) -> Token {
        self.tokens[self.current - 1].clone()
    }

    fn consume(&mut self, token_type: &TokenType, message: &str) -> Result<Token, ParserError> {
        if self.check(token_type) {
            return Ok(self.advance());
        }

        Err(ParserError::UnexpectedToken {
            expected: message.to_string(),
            got: format!("{:?}", self.peek().token_type),
            line: self.peek().line,
            column: self.peek().column,
        })
    }

    fn consume_identifier(&mut self, context: &str) -> Result<String, ParserError> {
        if let TokenType::Identifier = self.peek().token_type {
            Ok(self.advance().lexeme)
        } else {
            Err(ParserError::UnexpectedToken {
                expected: context.to_string(),
                got: format!("{:?}", self.peek().token_type),
                line: self.peek().line,
                column: self.peek().column,
            })
        }
    }

    fn skip_newlines(&mut self) {
        while self.match_token(&[TokenType::Newline, TokenType::Indent, TokenType::Dedent]) {}
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::Lexer;

    fn parse_source(source: &str) -> Result<ASTNode, ParserError> {
        let lexer = Lexer::new(source.to_string());
        let tokens = lexer.tokenize().unwrap();
        let parser = Parser::new(tokens);
        parser.parse()
    }

    #[test]
    fn test_parse_number() {
        let ast = parse_source("42").unwrap();
        if let ASTNode::Program { statements } = ast {
            assert_eq!(statements.len(), 1);
            assert!(matches!(statements[0], ASTNode::Number(42.0)));
        }
    }

    #[test]
    fn test_parse_variable() {
        let ast = parse_source("let x = 10").unwrap();
        if let ASTNode::Program { statements } = ast {
            assert_eq!(statements.len(), 1);
            assert!(matches!(
                &statements[0],
                ASTNode::VariableDeclaration { .. }
            ));
        }
    }

    #[test]
    fn test_parse_function() {
        let source = r#"
fun add(a, b) {
    return a + b
}
"#;
        let ast = parse_source(source).unwrap();
        if let ASTNode::Program { statements } = ast {
            assert_eq!(statements.len(), 1);
            assert!(matches!(
                &statements[0],
                ASTNode::FunctionDeclaration { .. }
            ));
        }
    }

    #[test]
    fn test_parse_binary_operation() {
        let ast = parse_source("1 + 2 * 3").unwrap();
        if let ASTNode::Program { statements } = ast {
            assert!(matches!(&statements[0], ASTNode::BinaryOperation { .. }));
        }
    }
}
