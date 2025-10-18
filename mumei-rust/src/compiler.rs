/// バイトコードコンパイラ
/// ASTをバイトコードにコンパイル

use crate::ast::{ASTNode, BinaryOperator, UnaryOperator};
use crate::bytecode::{ByteCode, Instruction};
use crate::value::Value;

/// コンパイラ
pub struct Compiler {
    bytecode: ByteCode,
}

impl Compiler {
    /// 新しいコンパイラを作成
    pub fn new() -> Self {
        Compiler {
            bytecode: ByteCode::new(),
        }
    }

    /// ASTノードのリストをコンパイル
    pub fn compile(&mut self, nodes: Vec<ASTNode>) -> Result<ByteCode, String> {
        for node in nodes {
            self.compile_node(&node)?;
        }

        // 最後にHalt命令を追加
        self.bytecode.emit(Instruction::Halt);

        Ok(self.bytecode.clone())
    }

    /// 単一のASTノードをコンパイル
    fn compile_node(&mut self, node: &ASTNode) -> Result<(), String> {
        match node {
            // リテラル
            ASTNode::Number(n) => {
                self.bytecode.emit(Instruction::LoadConst(Value::Number(*n)));
                Ok(())
            }

            ASTNode::String(s) => {
                self.bytecode.emit(Instruction::LoadConst(Value::String(s.clone())));
                Ok(())
            }

            ASTNode::Boolean(b) => {
                self.bytecode.emit(Instruction::LoadConst(Value::Boolean(*b)));
                Ok(())
            }

            ASTNode::Null => {
                self.bytecode.emit(Instruction::LoadConst(Value::Null));
                Ok(())
            }

            // 識別子（変数参照）
            ASTNode::Identifier(name) => {
                self.bytecode.emit(Instruction::LoadVar(name.clone()));
                Ok(())
            }

            // 変数宣言
            ASTNode::VariableDeclaration { name, value, .. } => {
                // 値をコンパイル
                self.compile_node(value)?;
                // 変数に保存
                self.bytecode.emit(Instruction::StoreVar(name.clone()));
                Ok(())
            }

            // 代入
            ASTNode::Assignment { target, value } => {
                // 値をコンパイル
                self.compile_node(value)?;

                match target.as_ref() {
                    ASTNode::Identifier(name) => {
                        self.bytecode.emit(Instruction::StoreVar(name.clone()));
                        Ok(())
                    }
                    _ => Err("Complex assignment not yet supported in bytecode".to_string()),
                }
            }

            // 二項演算
            ASTNode::BinaryOperation { left, operator, right } => {
                // 左辺をコンパイル
                self.compile_node(left)?;
                // 右辺をコンパイル
                self.compile_node(right)?;

                // 演算子に対応する命令を発行
                let instruction = match operator {
                    BinaryOperator::Add => Instruction::Add,
                    BinaryOperator::Subtract => Instruction::Subtract,
                    BinaryOperator::Multiply => Instruction::Multiply,
                    BinaryOperator::Divide => Instruction::Divide,
                    BinaryOperator::Modulo => Instruction::Modulo,
                    BinaryOperator::Power => Instruction::Power,
                    BinaryOperator::Less => Instruction::Less,
                    BinaryOperator::Greater => Instruction::Greater,
                    BinaryOperator::LessEqual => Instruction::LessEqual,
                    BinaryOperator::GreaterEqual => Instruction::GreaterEqual,
                    BinaryOperator::Equal => Instruction::Equal,
                    BinaryOperator::NotEqual => Instruction::NotEqual,
                    BinaryOperator::And => Instruction::And,
                    BinaryOperator::Or => Instruction::Or,
                    _ => return Err(format!("Unsupported binary operator: {:?}", operator)),
                };

                self.bytecode.emit(instruction);
                Ok(())
            }

            // 単項演算
            ASTNode::UnaryOperation { operator, operand } => {
                // オペランドをコンパイル
                self.compile_node(operand)?;

                // 演算子に対応する命令を発行
                let instruction = match operator {
                    UnaryOperator::Negate => Instruction::Negate,
                    UnaryOperator::Not => Instruction::Not,
                    _ => return Err(format!("Unsupported unary operator: {:?}", operator)),
                };

                self.bytecode.emit(instruction);
                Ok(())
            }

            // if文
            ASTNode::IfStatement { condition, then_body, elif_clauses, else_body } => {
                // 条件をコンパイル
                self.compile_node(condition)?;

                // JumpIfFalseの位置を記録（後でパッチする）
                let jump_to_else_or_end = self.bytecode.current_index();
                self.bytecode.emit(Instruction::JumpIfFalse(0)); // 仮の値

                // then_bodyをコンパイル
                for stmt in then_body {
                    self.compile_node(stmt)?;
                }

                // then_bodyの後のジャンプ（end へ）
                let jump_to_end = self.bytecode.current_index();
                self.bytecode.emit(Instruction::Jump(0)); // 仮の値

                // elif句の処理
                let elif_start = self.bytecode.current_index();
                for (elif_cond, elif_body) in elif_clauses {
                    self.compile_node(elif_cond)?;

                    let elif_jump = self.bytecode.current_index();
                    self.bytecode.emit(Instruction::JumpIfFalse(0));

                    for stmt in elif_body {
                        self.compile_node(stmt)?;
                    }

                    let elif_end_jump = self.bytecode.current_index();
                    self.bytecode.emit(Instruction::Jump(0));

                    // elif のJumpIfFalse をパッチ
                    let next_elif = self.bytecode.current_index();
                    self.bytecode.patch(elif_jump, Instruction::JumpIfFalse(next_elif));
                }

                // else_bodyをコンパイル
                if let Some(else_stmts) = else_body {
                    for stmt in else_stmts {
                        self.compile_node(stmt)?;
                    }
                }

                // 最終位置
                let end_index = self.bytecode.current_index();

                // ジャンプ先をパッチ
                if elif_clauses.is_empty() && else_body.is_some() {
                    self.bytecode.patch(jump_to_else_or_end, Instruction::JumpIfFalse(elif_start));
                } else {
                    self.bytecode.patch(jump_to_else_or_end, Instruction::JumpIfFalse(elif_start));
                }
                self.bytecode.patch(jump_to_end, Instruction::Jump(end_index));

                Ok(())
            }

            // while文
            ASTNode::WhileStatement { condition, body } => {
                let loop_start = self.bytecode.current_index();

                // 条件をコンパイル
                self.compile_node(condition)?;

                // JumpIfFalseの位置を記録
                let jump_to_end = self.bytecode.current_index();
                self.bytecode.emit(Instruction::JumpIfFalse(0)); // 仮の値

                // ループ本体をコンパイル
                for stmt in body {
                    self.compile_node(stmt)?;
                }

                // ループの先頭に戻る
                self.bytecode.emit(Instruction::Jump(loop_start));

                // ループ終了位置
                let end_index = self.bytecode.current_index();
                self.bytecode.patch(jump_to_end, Instruction::JumpIfFalse(end_index));

                Ok(())
            }

            // 関数呼び出し
            ASTNode::FunctionCall { callee, arguments } => {
                // 関数をロード
                self.compile_node(callee)?;

                // 引数をコンパイル
                for arg in arguments {
                    self.compile_node(arg)?;
                }

                // 呼び出し
                self.bytecode.emit(Instruction::Call(arguments.len()));
                Ok(())
            }

            // リスト
            ASTNode::List { elements } => {
                // 要素をコンパイル
                for elem in elements {
                    self.compile_node(elem)?;
                }

                // リスト作成
                self.bytecode.emit(Instruction::MakeList(elements.len()));
                Ok(())
            }

            // その他のノード（未実装）
            _ => {
                // とりあえずNullを返す
                self.bytecode.emit(Instruction::LoadConst(Value::Null));
                Ok(())
            }
        }
    }
}

impl Default for Compiler {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compile_arithmetic() {
        let mut compiler = Compiler::new();

        // 2 + 3
        let ast = vec![ASTNode::BinaryOperation {
            left: Box::new(ASTNode::Number(2.0)),
            operator: BinaryOperator::Add,
            right: Box::new(ASTNode::Number(3.0)),
        }];

        let bytecode = compiler.compile(ast).unwrap();

        assert!(bytecode.instructions.len() > 0);
    }

    #[test]
    fn test_compile_variable() {
        let mut compiler = Compiler::new();

        // let x = 42
        let ast = vec![ASTNode::VariableDeclaration {
            name: "x".to_string(),
            value: Box::new(ASTNode::Number(42.0)),
            is_const: false,
        }];

        let bytecode = compiler.compile(ast).unwrap();

        // LoadConst, StoreVar, Halt
        assert_eq!(bytecode.instructions.len(), 3);
    }
}
