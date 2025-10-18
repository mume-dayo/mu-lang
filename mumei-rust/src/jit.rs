/// JITコンパイラ（Cranelift使用）
/// ホットパスをネイティブ機械語にコンパイルして超高速実行

use cranelift::prelude::*;
use cranelift_jit::{JITBuilder, JITModule};
use cranelift_module::{Linkage, Module};
use std::collections::HashMap;
use crate::bytecode::{ByteCode, Instruction};
use crate::value::Value;

/// JITコンパイルされた関数型
type JITFunction = unsafe extern "C" fn() -> f64;

/// JITコンパイラ
pub struct JITCompiler {
    /// Cranelift JITモジュール
    module: JITModule,

    /// 関数ビルダーコンテキスト
    ctx: codegen::Context,

    /// コンパイル済み関数のキャッシュ
    compiled_functions: HashMap<String, *const u8>,
}

impl JITCompiler {
    /// 新しいJITコンパイラを作成
    pub fn new() -> Result<Self, String> {
        let mut flag_builder = settings::builder();
        flag_builder.set("use_colocated_libcalls", "false")
            .map_err(|e| format!("Failed to set flag: {}", e))?;
        flag_builder.set("is_pic", "false")
            .map_err(|e| format!("Failed to set flag: {}", e))?;

        let isa_builder = cranelift_native::builder()
            .map_err(|e| format!("Failed to create ISA builder: {}", e))?;
        let isa = isa_builder
            .finish(settings::Flags::new(flag_builder))
            .map_err(|e| format!("Failed to create ISA: {}", e))?;

        let builder = JITBuilder::with_isa(isa, cranelift_module::default_libcall_names());
        let mut module = JITModule::new(builder);
        let ctx = module.make_context();

        Ok(JITCompiler {
            module,
            ctx,
            compiled_functions: HashMap::new(),
        })
    }

    /// バイトコードをJITコンパイル
    pub fn compile_bytecode(&mut self, bytecode: &ByteCode) -> Result<JITFunction, String> {
        // 関数シグネチャを定義（引数なし、f64を返す）
        self.ctx.func.signature.returns.push(AbiParam::new(types::F64));

        // エントリーブロックを作成
        let mut builder_ctx = FunctionBuilderContext::new();
        let mut builder = FunctionBuilder::new(&mut self.ctx.func, &mut builder_ctx);

        let entry_block = builder.create_block();
        builder.append_block_params_for_function_params(entry_block);
        builder.switch_to_block(entry_block);
        builder.seal_block(entry_block);

        // 簡単な算術演算のみをJITコンパイル（デモ版）
        let mut stack: Vec<cranelift::prelude::Value> = Vec::new();

        for instruction in &bytecode.instructions {
            match instruction {
                Instruction::LoadConst(Value::Number(n)) => {
                    let val = builder.ins().f64const(*n);
                    stack.push(val);
                }

                Instruction::Add => {
                    if stack.len() >= 2 {
                        let right = stack.pop().unwrap();
                        let left = stack.pop().unwrap();
                        let result = builder.ins().fadd(left, right);
                        stack.push(result);
                    }
                }

                Instruction::Subtract => {
                    if stack.len() >= 2 {
                        let right = stack.pop().unwrap();
                        let left = stack.pop().unwrap();
                        let result = builder.ins().fsub(left, right);
                        stack.push(result);
                    }
                }

                Instruction::Multiply => {
                    if stack.len() >= 2 {
                        let right = stack.pop().unwrap();
                        let left = stack.pop().unwrap();
                        let result = builder.ins().fmul(left, right);
                        stack.push(result);
                    }
                }

                Instruction::Divide => {
                    if stack.len() >= 2 {
                        let right = stack.pop().unwrap();
                        let left = stack.pop().unwrap();
                        let result = builder.ins().fdiv(left, right);
                        stack.push(result);
                    }
                }

                Instruction::Halt => {
                    // スタックトップを返す
                    if let Some(result) = stack.pop() {
                        builder.ins().return_(&[result]);
                    } else {
                        let zero = builder.ins().f64const(0.0);
                        builder.ins().return_(&[zero]);
                    }
                    break;
                }

                _ => {
                    // 複雑な命令は未対応（バイトコードVMにフォールバック）
                    return Err("Complex instruction not supported in JIT".to_string());
                }
            }
        }

        builder.finalize();

        // 関数を定義
        let id = self.module
            .declare_function("jit_function", Linkage::Export, &self.ctx.func.signature)
            .map_err(|e| format!("Failed to declare function: {}", e))?;

        self.module
            .define_function(id, &mut self.ctx)
            .map_err(|e| format!("Failed to define function: {}", e))?;

        self.module.clear_context(&mut self.ctx);

        // コード生成を確定
        self.module.finalize_definitions()
            .map_err(|e| format!("Failed to finalize: {}", e))?;

        // 関数ポインタを取得
        let code = self.module.get_finalized_function(id);

        Ok(unsafe { std::mem::transmute::<_, JITFunction>(code) })
    }

    /// JITコンパイルして実行
    pub fn compile_and_execute(&mut self, bytecode: &ByteCode) -> Result<f64, String> {
        let jit_func = self.compile_bytecode(bytecode)?;

        // 実行
        let result = unsafe { jit_func() };
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_jit_simple() {
        let mut jit = JITCompiler::new().unwrap();

        let mut bytecode = ByteCode::new();
        // 2 + 3
        bytecode.emit(Instruction::LoadConst(Value::Number(2.0)));
        bytecode.emit(Instruction::LoadConst(Value::Number(3.0)));
        bytecode.emit(Instruction::Add);
        bytecode.emit(Instruction::Halt);

        let result = jit.compile_and_execute(&bytecode).unwrap();
        assert!((result - 5.0).abs() < 0.001);
    }
}
