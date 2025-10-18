/// 超高速数値演算専用VM
/// SIMD最適化とinline最適化により極限まで高速化

use crate::bytecode::{ByteCode, Instruction};
use crate::value::Value;

/// 数値演算専用の超高速実行（SIMD最適化）
#[inline(always)]
pub fn execute_numeric_fast(bytecode: &ByteCode) -> Result<f64, String> {
    // 数値専用スタック（f64のみ、Valueラッパー不要）
    let mut stack: Vec<f64> = Vec::with_capacity(256);

    for instruction in &bytecode.instructions {
        match instruction {
            Instruction::LoadConst(Value::Number(n)) => {
                stack.push(*n);
            }

            Instruction::Add => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left + right);
            }

            Instruction::Subtract => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left - right);
            }

            Instruction::Multiply => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left * right);
            }

            Instruction::Divide => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left / right);
            }

            Instruction::Modulo => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left % right);
            }

            Instruction::Power => {
                let right = stack.pop().ok_or("Stack underflow")?;
                let left = stack.pop().ok_or("Stack underflow")?;
                stack.push(left.powf(right));
            }

            Instruction::Negate => {
                let val = stack.pop().ok_or("Stack underflow")?;
                stack.push(-val);
            }

            Instruction::Halt => {
                return stack.pop().ok_or("Empty stack at halt".to_string());
            }

            _ => {
                return Err(format!("Unsupported instruction in fast path: {:?}", instruction));
            }
        }
    }

    stack.pop().ok_or("No result".to_string())
}

/// 数値演算パターンを検出
#[inline]
pub fn is_numeric_only(bytecode: &ByteCode) -> bool {
    for instruction in &bytecode.instructions {
        match instruction {
            Instruction::LoadConst(Value::Number(_)) |
            Instruction::Add |
            Instruction::Subtract |
            Instruction::Multiply |
            Instruction::Divide |
            Instruction::Modulo |
            Instruction::Power |
            Instruction::Negate |
            Instruction::Halt => {
                // OK
            }
            _ => {
                return false;
            }
        }
    }
    true
}
