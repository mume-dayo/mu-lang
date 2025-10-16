/// AST (Abstract Syntax Tree) ノード定義
/// Mumei言語の構文木構造

use std::fmt;

/// ASTノードの基底型
#[derive(Debug, Clone, PartialEq)]
pub enum ASTNode {
    // リテラル
    Number(f64),
    String(String),
    Boolean(bool),
    Null,

    // 識別子
    Identifier(String),

    // 変数宣言
    VariableDeclaration {
        name: String,
        value: Box<ASTNode>,
        is_const: bool,
    },

    // 関数定義
    FunctionDeclaration {
        name: String,
        parameters: Vec<String>,
        body: Vec<ASTNode>,
        is_async: bool,
    },

    // 関数呼び出し
    FunctionCall {
        callee: Box<ASTNode>,
        arguments: Vec<ASTNode>,
    },

    // 二項演算
    BinaryOperation {
        left: Box<ASTNode>,
        operator: BinaryOperator,
        right: Box<ASTNode>,
    },

    // 単項演算
    UnaryOperation {
        operator: UnaryOperator,
        operand: Box<ASTNode>,
    },

    // 代入
    Assignment {
        target: Box<ASTNode>,
        value: Box<ASTNode>,
    },

    // 複合代入
    CompoundAssignment {
        target: Box<ASTNode>,
        operator: BinaryOperator,
        value: Box<ASTNode>,
    },

    // if文
    IfStatement {
        condition: Box<ASTNode>,
        then_body: Vec<ASTNode>,
        elif_clauses: Vec<(ASTNode, Vec<ASTNode>)>,
        else_body: Option<Vec<ASTNode>>,
    },

    // while文
    WhileStatement {
        condition: Box<ASTNode>,
        body: Vec<ASTNode>,
    },

    // for文
    ForStatement {
        variable: String,
        iterable: Box<ASTNode>,
        body: Vec<ASTNode>,
    },

    // return文
    ReturnStatement {
        value: Option<Box<ASTNode>>,
    },

    // yield文
    YieldStatement {
        value: Box<ASTNode>,
    },

    // break文
    BreakStatement,

    // continue文
    ContinueStatement,

    // pass文
    PassStatement,

    // リスト
    List {
        elements: Vec<ASTNode>,
    },

    // 辞書
    Dictionary {
        pairs: Vec<(ASTNode, ASTNode)>,
    },

    // インデックスアクセス
    IndexAccess {
        object: Box<ASTNode>,
        index: Box<ASTNode>,
    },

    // メンバーアクセス
    MemberAccess {
        object: Box<ASTNode>,
        member: String,
    },

    // スライス
    Slice {
        object: Box<ASTNode>,
        start: Option<Box<ASTNode>>,
        end: Option<Box<ASTNode>>,
        step: Option<Box<ASTNode>>,
    },

    // ラムダ式
    Lambda {
        parameters: Vec<String>,
        body: Box<ASTNode>,
    },

    // リスト内包表記
    ListComprehension {
        element: Box<ASTNode>,
        variable: String,
        iterable: Box<ASTNode>,
        condition: Option<Box<ASTNode>>,
    },

    // 辞書内包表記
    DictComprehension {
        key: Box<ASTNode>,
        value: Box<ASTNode>,
        variable: String,
        iterable: Box<ASTNode>,
        condition: Option<Box<ASTNode>>,
    },

    // 三項演算子
    TernaryOperation {
        condition: Box<ASTNode>,
        true_value: Box<ASTNode>,
        false_value: Box<ASTNode>,
    },

    // try-catch文
    TryCatch {
        try_body: Vec<ASTNode>,
        catch_variable: Option<String>,
        catch_body: Vec<ASTNode>,
        finally_body: Option<Vec<ASTNode>>,
    },

    // throw文
    ThrowStatement {
        value: Box<ASTNode>,
    },

    // クラス定義
    ClassDeclaration {
        name: String,
        parent: Option<String>,
        body: Vec<ASTNode>,
    },

    // import文
    ImportStatement {
        module: String,
        alias: Option<String>,
    },

    // プログラム（ルートノード）
    Program {
        statements: Vec<ASTNode>,
    },

    // await式
    AwaitExpression {
        expression: Box<ASTNode>,
    },

    // assert文
    AssertStatement {
        condition: Box<ASTNode>,
        message: Option<Box<ASTNode>>,
    },
}

/// 二項演算子
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum BinaryOperator {
    // 算術演算子
    Add,        // +
    Subtract,   // -
    Multiply,   // *
    Divide,     // /
    Modulo,     // %
    Power,      // **
    FloorDiv,   // //

    // 比較演算子
    Equal,          // ==
    NotEqual,       // !=
    Less,           // <
    Greater,        // >
    LessEqual,      // <=
    GreaterEqual,   // >=

    // 論理演算子
    And,    // and
    Or,     // or

    // ビット演算子
    BitwiseAnd,     // &
    BitwiseOr,      // |
    BitwiseXor,     // ^
    LeftShift,      // <<
    RightShift,     // >>
}

/// 単項演算子
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum UnaryOperator {
    Not,            // not
    Negate,         // -
    BitwiseNot,     // ~
}

impl fmt::Display for BinaryOperator {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let symbol = match self {
            BinaryOperator::Add => "+",
            BinaryOperator::Subtract => "-",
            BinaryOperator::Multiply => "*",
            BinaryOperator::Divide => "/",
            BinaryOperator::Modulo => "%",
            BinaryOperator::Power => "**",
            BinaryOperator::FloorDiv => "//",
            BinaryOperator::Equal => "==",
            BinaryOperator::NotEqual => "!=",
            BinaryOperator::Less => "<",
            BinaryOperator::Greater => ">",
            BinaryOperator::LessEqual => "<=",
            BinaryOperator::GreaterEqual => ">=",
            BinaryOperator::And => "and",
            BinaryOperator::Or => "or",
            BinaryOperator::BitwiseAnd => "&",
            BinaryOperator::BitwiseOr => "|",
            BinaryOperator::BitwiseXor => "^",
            BinaryOperator::LeftShift => "<<",
            BinaryOperator::RightShift => ">>",
        };
        write!(f, "{}", symbol)
    }
}

impl fmt::Display for UnaryOperator {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let symbol = match self {
            UnaryOperator::Not => "not",
            UnaryOperator::Negate => "-",
            UnaryOperator::BitwiseNot => "~",
        };
        write!(f, "{}", symbol)
    }
}

// AST可視化用のヘルパー
impl ASTNode {
    /// ASTを読みやすい形式で出力
    pub fn pretty_print(&self, indent: usize) -> String {
        let prefix = "  ".repeat(indent);
        match self {
            ASTNode::Number(n) => format!("{}Number({})", prefix, n),
            ASTNode::String(s) => format!("{}String(\"{}\")", prefix, s),
            ASTNode::Boolean(b) => format!("{}Boolean({})", prefix, b),
            ASTNode::Null => format!("{}Null", prefix),
            ASTNode::Identifier(name) => format!("{}Identifier({})", prefix, name),
            ASTNode::BinaryOperation { left, operator, right } => {
                format!("{}BinaryOp({})\n{}\n{}",
                    prefix, operator,
                    left.pretty_print(indent + 1),
                    right.pretty_print(indent + 1))
            }
            ASTNode::FunctionCall { callee, arguments } => {
                let mut result = format!("{}FunctionCall\n{}", prefix, callee.pretty_print(indent + 1));
                for arg in arguments {
                    result.push_str(&format!("\n{}", arg.pretty_print(indent + 1)));
                }
                result
            }
            ASTNode::Program { statements } => {
                let mut result = format!("{}Program", prefix);
                for stmt in statements {
                    result.push_str(&format!("\n{}", stmt.pretty_print(indent + 1)));
                }
                result
            }
            _ => format!("{}{:?}", prefix, self),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ast_node_creation() {
        let num = ASTNode::Number(42.0);
        assert!(matches!(num, ASTNode::Number(42.0)));

        let str_node = ASTNode::String("hello".to_string());
        assert!(matches!(str_node, ASTNode::String(_)));
    }

    #[test]
    fn test_binary_operation() {
        let left = Box::new(ASTNode::Number(1.0));
        let right = Box::new(ASTNode::Number(2.0));
        let binop = ASTNode::BinaryOperation {
            left,
            operator: BinaryOperator::Add,
            right,
        };

        match binop {
            ASTNode::BinaryOperation { operator, .. } => {
                assert_eq!(operator, BinaryOperator::Add);
            }
            _ => panic!("Expected BinaryOperation"),
        }
    }
}
