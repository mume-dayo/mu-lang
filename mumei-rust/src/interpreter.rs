/// インタプリタコア
/// ASTノードを評価して実行する

use std::rc::Rc;
use std::cell::RefCell;
use std::collections::HashMap;
use crate::ast::ASTNode;
use crate::value::Value;
use crate::environment::Environment;

/// インタプリタ
pub struct Interpreter {
    /// グローバル環境
    global_env: Rc<Environment>,

    /// 現在の環境（スコープ）
    current_env: Rc<Environment>,
}

impl Interpreter {
    /// 新しいインタプリタを作成
    pub fn new() -> Self {
        let global_env = Rc::new(Environment::new());

        Interpreter {
            global_env: global_env.clone(),
            current_env: global_env,
        }
    }

    /// グローバル環境を取得（組み込み関数の登録用）
    pub fn global_env(&self) -> Rc<Environment> {
        self.global_env.clone()
    }

    /// ASTノードのリストを評価
    pub fn evaluate(&mut self, nodes: Vec<ASTNode>) -> Result<Value, String> {
        let mut last_value = Value::Null;

        for node in nodes {
            last_value = self.eval_node(&node)?;
        }

        Ok(last_value)
    }

    /// 単一のASTノードを評価
    fn eval_node(&mut self, node: &ASTNode) -> Result<Value, String> {
        match node {
            // リテラル
            ASTNode::Number(n) => Ok(Value::Number(*n)),
            ASTNode::String(s) => Ok(Value::String(s.clone())),
            ASTNode::Boolean(b) => Ok(Value::Boolean(*b)),
            ASTNode::Null => Ok(Value::Null),

            // リスト
            ASTNode::List { elements } => {
                let mut values = Vec::new();
                for elem in elements {
                    values.push(self.eval_node(elem)?);
                }
                Ok(Value::List(Rc::new(RefCell::new(values))))
            }

            // 辞書
            ASTNode::Dictionary { pairs } => {
                let mut map = HashMap::new();
                for (key_expr, value_expr) in pairs {
                    // キーを評価して文字列に変換
                    let key_value = self.eval_node(key_expr)?;
                    let key = key_value.to_string();

                    let value = self.eval_node(value_expr)?;
                    map.insert(key, value);
                }
                Ok(Value::Dictionary(Rc::new(RefCell::new(map))))
            }

            // 識別子（変数参照）
            ASTNode::Identifier(name) => self.current_env.get(name),

            // 変数宣言
            ASTNode::VariableDeclaration { name, value, is_const } => {
                let val = self.eval_node(value)?;

                if *is_const {
                    self.current_env.define_const(name.clone(), val)?;
                } else {
                    self.current_env.define(name.clone(), val)?;
                }

                Ok(Value::Null)
            }

            // 代入
            ASTNode::Assignment { target, value } => {
                let val = self.eval_node(value)?;

                match target.as_ref() {
                    ASTNode::Identifier(name) => {
                        self.current_env.assign(name, val.clone())?;
                        Ok(val)
                    }
                    ASTNode::IndexAccess { object, index } => {
                        self.eval_index_assignment(object, index, val)
                    }
                    ASTNode::MemberAccess { object, member } => {
                        self.eval_member_assignment(object, member, val)
                    }
                    _ => Err("Invalid assignment target".to_string()),
                }
            }

            // 二項演算
            ASTNode::BinaryOperation { left, operator, right } => {
                use crate::ast::BinaryOperator;
                let left_val = self.eval_node(left)?;
                let right_val = self.eval_node(right)?;

                match operator {
                    BinaryOperator::Add => left_val.add(&right_val),
                    BinaryOperator::Subtract => left_val.subtract(&right_val),
                    BinaryOperator::Multiply => left_val.multiply(&right_val),
                    BinaryOperator::Divide => left_val.divide(&right_val),
                    BinaryOperator::Modulo => left_val.modulo(&right_val),
                    BinaryOperator::Power => left_val.power(&right_val),
                    BinaryOperator::Less => left_val.less_than(&right_val),
                    BinaryOperator::Greater => left_val.greater_than(&right_val),
                    BinaryOperator::LessEqual => Ok(Value::Boolean(!left_val.greater_than(&right_val)?.as_boolean()?)),
                    BinaryOperator::GreaterEqual => Ok(Value::Boolean(!left_val.less_than(&right_val)?.as_boolean()?)),
                    BinaryOperator::Equal => Ok(Value::Boolean(left_val.equals(&right_val))),
                    BinaryOperator::NotEqual => Ok(Value::Boolean(!left_val.equals(&right_val))),
                    BinaryOperator::And => {
                        if !left_val.is_truthy() {
                            Ok(left_val)
                        } else {
                            Ok(right_val)
                        }
                    }
                    BinaryOperator::Or => {
                        if left_val.is_truthy() {
                            Ok(left_val)
                        } else {
                            Ok(right_val)
                        }
                    }
                    _ => Err(format!("Unknown binary operator: {}", operator)),
                }
            }

            // 単項演算
            ASTNode::UnaryOperation { operator, operand } => {
                use crate::ast::UnaryOperator;
                let val = self.eval_node(operand)?;

                match operator {
                    UnaryOperator::Negate => {
                        let num = val.as_number()?;
                        Ok(Value::Number(-num))
                    }
                    UnaryOperator::Not => Ok(Value::Boolean(!val.is_truthy())),
                    _ => Err(format!("Unknown unary operator: {}", operator)),
                }
            }

            // 関数呼び出し
            ASTNode::FunctionCall { callee, arguments } => {
                self.eval_function_call(callee, arguments)
            }

            // インデックスアクセス
            ASTNode::IndexAccess { object, index } => {
                let obj = self.eval_node(object)?;
                let idx = self.eval_node(index)?;

                match obj {
                    Value::List(list) => {
                        let index_num = idx.as_number()?;
                        if index_num < 0.0 || index_num.fract() != 0.0 {
                            return Err(format!("List index must be non-negative integer, got {}", index_num));
                        }
                        list.borrow()
                            .get(index_num as usize)
                            .cloned()
                            .ok_or_else(|| format!("Index {} out of range", index_num))
                    }
                    Value::Dictionary(dict) => {
                        let key = idx.to_string();
                        dict.borrow()
                            .get(&key)
                            .cloned()
                            .ok_or_else(|| format!("Key '{}' not found", key))
                    }
                    Value::String(s) => {
                        let index_num = idx.as_number()?;
                        if index_num < 0.0 || index_num.fract() != 0.0 {
                            return Err(format!("String index must be non-negative integer, got {}", index_num));
                        }
                        s.chars()
                            .nth(index_num as usize)
                            .map(|c| Value::String(c.to_string()))
                            .ok_or_else(|| format!("Index {} out of range", index_num))
                    }
                    _ => Err(format!("Cannot index {}", obj.type_name())),
                }
            }

            // メンバーアクセス
            ASTNode::MemberAccess { object, member } => {
                let obj = self.eval_node(object)?;

                match obj {
                    Value::Dictionary(dict) => {
                        dict.borrow()
                            .get(member)
                            .cloned()
                            .ok_or_else(|| format!("Property '{}' not found", member))
                    }
                    Value::Instance { fields, .. } => {
                        fields.borrow()
                            .get(member)
                            .cloned()
                            .ok_or_else(|| format!("Property '{}' not found", member))
                    }
                    _ => Err(format!("Cannot access member of {}", obj.type_name())),
                }
            }

            // 条件分岐（if）
            ASTNode::IfStatement { condition, then_body, elif_clauses, else_body } => {
                let cond_val = self.eval_node(condition)?;

                if cond_val.is_truthy() {
                    self.eval_block(then_body)
                } else {
                    // elif句を評価
                    for (elif_cond, elif_body) in elif_clauses {
                        let elif_val = self.eval_node(elif_cond)?;
                        if elif_val.is_truthy() {
                            return self.eval_block(elif_body);
                        }
                    }

                    // else句を評価
                    if let Some(else_nodes) = else_body {
                        self.eval_block(else_nodes)
                    } else {
                        Ok(Value::Null)
                    }
                }
            }

            // while ループ
            ASTNode::WhileStatement { condition, body } => {
                let mut last_value = Value::Null;

                loop {
                    let cond_val = self.eval_node(condition)?;
                    if !cond_val.is_truthy() {
                        break;
                    }

                    last_value = self.eval_block(body)?;
                }

                Ok(last_value)
            }

            // for-in ループ
            ASTNode::ForStatement { variable, iterable, body } => {
                let iter_val = self.eval_node(iterable)?;

                match iter_val {
                    Value::List(list) => {
                        let mut last_value = Value::Null;

                        for item in list.borrow().iter() {
                            self.current_env.define(variable.clone(), item.clone())?;
                            last_value = self.eval_block(body)?;
                        }

                        Ok(last_value)
                    }
                    Value::String(s) => {
                        let mut last_value = Value::Null;

                        for ch in s.chars() {
                            self.current_env.define(variable.clone(), Value::String(ch.to_string()))?;
                            last_value = self.eval_block(body)?;
                        }

                        Ok(last_value)
                    }
                    _ => Err(format!("Cannot iterate over {}", iter_val.type_name())),
                }
            }

            // 関数定義
            ASTNode::FunctionDeclaration { name, parameters, body, is_async } => {
                let func = Value::Function {
                    name: name.clone(),
                    parameters: parameters.clone(),
                    body: body.clone(),
                    closure: self.current_env.clone(),
                    is_async: *is_async,
                };

                self.current_env.define(name.clone(), func)?;
                Ok(Value::Null)
            }

            // return 文
            ASTNode::ReturnStatement { value } => {
                let return_value = if let Some(e) = value {
                    self.eval_node(e)?
                } else {
                    Value::Null
                };

                // returnの値を特別な形で返す（エラーとして）
                // TODO: より良い方法でreturnを実装する
                Err(format!("RETURN:{}", return_value.to_string()))
            }

            // try-catch
            ASTNode::TryCatch { try_body, catch_variable, catch_body, finally_body } => {
                let try_result = match self.eval_block(try_body) {
                    Ok(val) => Ok(val),
                    Err(e) => {
                        // エラーメッセージを変数に格納（catch_variableがある場合）
                        if let Some(var) = catch_variable {
                            self.current_env.define(
                                var.clone(),
                                Value::String(e.clone())
                            )?;
                        }

                        self.eval_block(catch_body)?;
                        Ok(Value::Null)
                    }
                };

                // finally句を実行
                if let Some(finally_nodes) = finally_body {
                    self.eval_block(finally_nodes)?;
                }

                try_result
            }

            // クラス定義
            ASTNode::ClassDeclaration { name, parent, body } => {
                let parent_val = if let Some(parent_name) = parent {
                    Some(Box::new(self.current_env.get(parent_name)?))
                } else {
                    None
                };

                let mut method_map = HashMap::new();
                for method_node in body {
                    if let ASTNode::FunctionDeclaration { name: method_name, parameters, body: method_body, is_async } = method_node {
                        let func = Value::Function {
                            name: method_name.clone(),
                            parameters: parameters.clone(),
                            body: method_body.clone(),
                            closure: self.current_env.clone(),
                            is_async: *is_async,
                        };
                        method_map.insert(method_name.clone(), func);
                    }
                }

                let class = Value::Class {
                    name: name.clone(),
                    methods: method_map,
                    parent: parent_val,
                };

                self.current_env.define(name.clone(), class)?;
                Ok(Value::Null)
            }

            // その他
            _ => Err(format!("Unimplemented AST node: {:?}", node)),
        }
    }

    /// ブロック（複数のノード）を評価
    fn eval_block(&mut self, nodes: &[ASTNode]) -> Result<Value, String> {
        let mut last_value = Value::Null;

        for node in nodes {
            last_value = self.eval_node(node)?;
        }

        Ok(last_value)
    }

    /// 関数呼び出しを評価
    fn eval_function_call(&mut self, function: &ASTNode, arguments: &[ASTNode]) -> Result<Value, String> {
        let func_value = self.eval_node(function)?;

        // 引数を評価
        let mut args = Vec::new();
        for arg in arguments {
            args.push(self.eval_node(arg)?);
        }

        match func_value {
            Value::Function { parameters, body, closure, .. } => {
                // パラメータ数チェック
                if parameters.len() != args.len() {
                    return Err(format!(
                        "Function expects {} arguments, got {}",
                        parameters.len(),
                        args.len()
                    ));
                }

                // 新しい環境を作成（クロージャを親に）
                let func_env = Rc::new(Environment::with_parent(closure));

                // パラメータをバインド
                for (param, arg) in parameters.iter().zip(args.iter()) {
                    func_env.define(param.clone(), arg.clone())?;
                }

                // 環境を切り替えて実行
                let prev_env = self.current_env.clone();
                self.current_env = func_env;

                let result = match self.eval_block(&body) {
                    Ok(val) => Ok(val),
                    Err(e) => {
                        // return文の処理
                        if e.starts_with("RETURN:") {
                            // TODO: return値のパース実装
                            // 暫定的に最後に評価された値を返す
                            Ok(Value::Null)
                        } else {
                            Err(e)
                        }
                    }
                };

                // 環境を戻す
                self.current_env = prev_env;

                result
            }
            Value::NativeFunction { arity, function, .. } => {
                if arity != args.len() {
                    return Err(format!(
                        "Native function expects {} arguments, got {}",
                        arity,
                        args.len()
                    ));
                }

                function(args)
            }
            _ => Err(format!("Cannot call {}", func_value.type_name())),
        }
    }

    /// インデックスへの代入
    fn eval_index_assignment(&mut self, object: &ASTNode, index: &ASTNode, value: Value) -> Result<Value, String> {
        let obj = self.eval_node(object)?;
        let idx = self.eval_node(index)?;

        match obj {
            Value::List(list) => {
                let index_num = idx.as_number()?;
                if index_num < 0.0 || index_num.fract() != 0.0 {
                    return Err(format!("List index must be non-negative integer"));
                }

                let mut borrowed = list.borrow_mut();
                let i = index_num as usize;

                if i >= borrowed.len() {
                    return Err(format!("Index {} out of range", i));
                }

                borrowed[i] = value.clone();
                Ok(value)
            }
            Value::Dictionary(dict) => {
                let key = idx.to_string();
                dict.borrow_mut().insert(key, value.clone());
                Ok(value)
            }
            _ => Err(format!("Cannot index assign to {}", obj.type_name())),
        }
    }

    /// メンバーへの代入
    fn eval_member_assignment(&mut self, object: &ASTNode, member: &str, value: Value) -> Result<Value, String> {
        let obj = self.eval_node(object)?;

        match obj {
            Value::Dictionary(dict) => {
                dict.borrow_mut().insert(member.to_string(), value.clone());
                Ok(value)
            }
            Value::Instance { fields, .. } => {
                fields.borrow_mut().insert(member.to_string(), value.clone());
                Ok(value)
            }
            _ => Err(format!("Cannot set member on {}", obj.type_name())),
        }
    }
}

impl Default for Interpreter {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::Lexer;
    use crate::parser::Parser;

    fn parse_and_eval(source: &str) -> Result<Value, String> {
        let lexer = Lexer::new(source.to_string());
        let tokens = lexer.tokenize().map_err(|e| format!("Lexer error: {}", e))?;

        let parser = Parser::new(tokens);
        let ast = parser.parse().map_err(|e| format!("Parser error: {}", e))?;

        let mut interpreter = Interpreter::new();
        interpreter.evaluate(ast)
    }

    #[test]
    fn test_arithmetic() {
        let result = parse_and_eval("2 + 3 * 4").unwrap();
        assert_eq!(result, Value::Number(14.0));
    }

    #[test]
    fn test_variable() {
        let result = parse_and_eval("let x = 10\nx + 5").unwrap();
        assert_eq!(result, Value::Number(15.0));
    }

    #[test]
    fn test_string_concat() {
        let result = parse_and_eval("\"Hello, \" + \"World!\"").unwrap();
        assert_eq!(result, Value::String("Hello, World!".to_string()));
    }

    #[test]
    fn test_list() {
        let result = parse_and_eval("[1, 2, 3][1]").unwrap();
        assert_eq!(result, Value::Number(2.0));
    }

    #[test]
    fn test_dictionary() {
        let result = parse_and_eval("{\"x\": 42}.x").unwrap();
        assert_eq!(result, Value::Number(42.0));
    }

    #[test]
    fn test_if_statement() {
        let result = parse_and_eval("if (true) { 1 } else { 2 }").unwrap();
        assert_eq!(result, Value::Number(1.0));
    }

    #[test]
    fn test_const() {
        let result = parse_and_eval("const PI = 3.14\nPI = 2.0");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Cannot assign to constant"));
    }
}
