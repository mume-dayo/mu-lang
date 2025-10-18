/// 超高速バイトコード実行エンジン
/// スタックベースVM（最適化済み）

use crate::bytecode::{ByteCode, Instruction};
use crate::value::Value;
use std::collections::HashMap;

/// VM実行スタック（高速化のため固定サイズ）
const STACK_SIZE: usize = 1024;

/// 仮想マシン
pub struct VM {
    /// 実行スタック
    stack: Vec<Value>,

    /// グローバル変数
    globals: HashMap<String, Value>,

    /// プログラムカウンタ
    pc: usize,

    /// 実行中のバイトコード
    bytecode: Option<ByteCode>,
}

impl VM {
    /// 新しいVMを作成
    pub fn new() -> Self {
        VM {
            stack: Vec::with_capacity(STACK_SIZE),
            globals: HashMap::new(),
            pc: 0,
            bytecode: None,
        }
    }

    /// バイトコードを実行
    pub fn execute(&mut self, bytecode: ByteCode) -> Result<Value, String> {
        self.bytecode = Some(bytecode);
        self.pc = 0;
        self.stack.clear();

        loop {
            // 命令を取得
            let instruction = self.fetch_instruction()?;

            // デバッグ用（リリースビルドでは削除される）
            #[cfg(debug_assertions)]
            {
                eprintln!("PC: {:04} | {:?} | Stack: {:?}", self.pc - 1, instruction, self.stack);
            }

            match instruction {
                Instruction::LoadConst(value) => {
                    self.push(value)?;
                }

                Instruction::LoadVar(name) => {
                    let value = self.globals
                        .get(&name)
                        .ok_or_else(|| format!("Variable '{}' not found", name))?
                        .clone();
                    self.push(value)?;
                }

                Instruction::StoreVar(name) => {
                    let value = self.pop()?;
                    self.globals.insert(name.clone(), value);
                }

                Instruction::Pop => {
                    self.pop()?;
                }

                Instruction::Add => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    // 数値演算の高速パス
                    match (&left, &right) {
                        (Value::Number(l), Value::Number(r)) => {
                            self.push(Value::Number(l + r))?;
                        }
                        _ => {
                            let result = left.add(&right)?;
                            self.push(result)?;
                        }
                    }
                }

                Instruction::Subtract => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    match (&left, &right) {
                        (Value::Number(l), Value::Number(r)) => {
                            self.push(Value::Number(l - r))?;
                        }
                        _ => {
                            let result = left.subtract(&right)?;
                            self.push(result)?;
                        }
                    }
                }

                Instruction::Multiply => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    match (&left, &right) {
                        (Value::Number(l), Value::Number(r)) => {
                            self.push(Value::Number(l * r))?;
                        }
                        _ => {
                            let result = left.multiply(&right)?;
                            self.push(result)?;
                        }
                    }
                }

                Instruction::Divide => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    match (&left, &right) {
                        (Value::Number(l), Value::Number(r)) => {
                            self.push(Value::Number(l / r))?;
                        }
                        _ => {
                            let result = left.divide(&right)?;
                            self.push(result)?;
                        }
                    }
                }

                Instruction::Modulo => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let result = left.modulo(&right)?;
                    self.push(result)?;
                }

                Instruction::Power => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let result = left.power(&right)?;
                    self.push(result)?;
                }

                Instruction::Less => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let result = left.less_than(&right)?;
                    self.push(result)?;
                }

                Instruction::Greater => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let result = left.greater_than(&right)?;
                    self.push(result)?;
                }

                Instruction::LessEqual => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let greater = left.greater_than(&right)?;
                    self.push(Value::Boolean(!greater.as_boolean()?))?;
                }

                Instruction::GreaterEqual => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    let less = left.less_than(&right)?;
                    self.push(Value::Boolean(!less.as_boolean()?))?;
                }

                Instruction::Equal => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    self.push(Value::Boolean(left.equals(&right)))?;
                }

                Instruction::NotEqual => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    self.push(Value::Boolean(!left.equals(&right)))?;
                }

                Instruction::And => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    if !left.is_truthy() {
                        self.push(left)?;
                    } else {
                        self.push(right)?;
                    }
                }

                Instruction::Or => {
                    let right = self.pop()?;
                    let left = self.pop()?;
                    if left.is_truthy() {
                        self.push(left)?;
                    } else {
                        self.push(right)?;
                    }
                }

                Instruction::Not => {
                    let value = self.pop()?;
                    self.push(Value::Boolean(!value.is_truthy()))?;
                }

                Instruction::Negate => {
                    let value = self.pop()?;
                    let num = value.as_number()?;
                    self.push(Value::Number(-num))?;
                }

                Instruction::Jump(target) => {
                    self.pc = target;
                }

                Instruction::JumpIfFalse(target) => {
                    let condition = self.pop()?;
                    if !condition.is_truthy() {
                        self.pc = target;
                    }
                }

                Instruction::JumpIfTrue(target) => {
                    let condition = self.pop()?;
                    if condition.is_truthy() {
                        self.pc = target;
                    }
                }

                Instruction::MakeList(count) => {
                    let mut elements = Vec::with_capacity(count);
                    for _ in 0..count {
                        elements.insert(0, self.pop()?);
                    }
                    self.push(Value::List(std::rc::Rc::new(std::cell::RefCell::new(elements))))?;
                }

                Instruction::Print => {
                    let value = self.pop()?;
                    println!("{}", value.to_string());
                }

                Instruction::Halt => {
                    // スタックに値があれば返す、なければNull
                    return if !self.stack.is_empty() {
                        Ok(self.pop()?)
                    } else {
                        Ok(Value::Null)
                    };
                }

                _ => {
                    return Err(format!("Unimplemented instruction: {:?}", instruction));
                }
            }
        }
    }

    /// 命令をフェッチ（インライン展開される）
    #[inline(always)]
    fn fetch_instruction(&mut self) -> Result<Instruction, String> {
        let bytecode = self.bytecode.as_ref()
            .ok_or("No bytecode loaded")?;

        if self.pc >= bytecode.instructions.len() {
            return Err("Program counter out of bounds".to_string());
        }

        let instruction = bytecode.instructions[self.pc].clone();
        self.pc += 1;
        Ok(instruction)
    }

    /// スタックにプッシュ（インライン展開される）
    #[inline(always)]
    fn push(&mut self, value: Value) -> Result<(), String> {
        if self.stack.len() >= STACK_SIZE {
            return Err("Stack overflow".to_string());
        }
        self.stack.push(value);
        Ok(())
    }

    /// スタックからポップ（インライン展開される）
    #[inline(always)]
    fn pop(&mut self) -> Result<Value, String> {
        self.stack.pop().ok_or_else(|| "Stack underflow".to_string())
    }
}

impl Default for VM {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_vm_arithmetic() {
        let mut vm = VM::new();

        let mut bytecode = ByteCode::new();
        // 2 + 3
        bytecode.emit(Instruction::LoadConst(Value::Number(2.0)));
        bytecode.emit(Instruction::LoadConst(Value::Number(3.0)));
        bytecode.emit(Instruction::Add);
        bytecode.emit(Instruction::Halt);

        let result = vm.execute(bytecode).unwrap();
        assert_eq!(result, Value::Number(5.0));
    }

    #[test]
    fn test_vm_variable() {
        let mut vm = VM::new();

        let mut bytecode = ByteCode::new();
        // let x = 10; x + 5
        bytecode.emit(Instruction::LoadConst(Value::Number(10.0)));
        bytecode.emit(Instruction::StoreVar("x".to_string()));
        bytecode.emit(Instruction::LoadVar("x".to_string()));
        bytecode.emit(Instruction::LoadConst(Value::Number(5.0)));
        bytecode.emit(Instruction::Add);
        bytecode.emit(Instruction::Halt);

        let result = vm.execute(bytecode).unwrap();
        assert_eq!(result, Value::Number(15.0));
    }
}
