/// バイトコード命令セット
/// ASTをコンパイルした中間表現

use crate::value::Value;

/// バイトコード命令
#[derive(Debug, Clone)]
pub enum Instruction {
    // スタック操作
    LoadConst(Value),           // 定数をスタックにプッシュ
    LoadVar(String),            // 変数をロードしてスタックにプッシュ
    StoreVar(String),           // スタックトップの値を変数に保存
    Pop,                        // スタックトップを削除

    // 算術演算（スタックトップの2つの値を演算）
    Add,                        // +
    Subtract,                   // -
    Multiply,                   // *
    Divide,                     // /
    Modulo,                     // %
    Power,                      // **

    // 比較演算
    Less,                       // <
    Greater,                    // >
    LessEqual,                  // <=
    GreaterEqual,               // >=
    Equal,                      // ==
    NotEqual,                   // !=

    // 論理演算
    And,                        // and
    Or,                         // or
    Not,                        // not

    // 単項演算
    Negate,                     // -（単項）

    // 制御フロー
    Jump(usize),                // 無条件ジャンプ
    JumpIfFalse(usize),         // 条件付きジャンプ（falseの場合）
    JumpIfTrue(usize),          // 条件付きジャンプ（trueの場合）

    // 関数呼び出し
    Call(usize),                // 関数呼び出し（引数の数）
    Return,                     // 関数から戻る

    // コレクション
    MakeList(usize),            // リストを作成（要素数）
    MakeDict(usize),            // 辞書を作成（ペア数）
    IndexGet,                   // インデックスアクセス
    IndexSet,                   // インデックス代入

    // その他
    Print,                      // 出力
    Halt,                       // 停止
}

/// コンパイル済みバイトコード
#[derive(Debug, Clone)]
pub struct ByteCode {
    /// 命令列
    pub instructions: Vec<Instruction>,

    /// 定数プール
    pub constants: Vec<Value>,

    /// エントリーポイント
    pub entry_point: usize,
}

impl ByteCode {
    /// 新しいバイトコードを作成
    pub fn new() -> Self {
        ByteCode {
            instructions: Vec::new(),
            constants: Vec::new(),
            entry_point: 0,
        }
    }

    /// 命令を追加
    pub fn emit(&mut self, instruction: Instruction) -> usize {
        let index = self.instructions.len();
        self.instructions.push(instruction);
        index
    }

    /// 定数を追加
    pub fn add_constant(&mut self, value: Value) -> usize {
        // 既存の定数を検索
        for (i, constant) in self.constants.iter().enumerate() {
            if constant.equals(&value) {
                return i;
            }
        }

        // 新しい定数を追加
        let index = self.constants.len();
        self.constants.push(value);
        index
    }

    /// 命令のパッチ（ジャンプ先の更新）
    pub fn patch(&mut self, index: usize, instruction: Instruction) {
        self.instructions[index] = instruction;
    }

    /// 現在の命令インデックスを取得
    pub fn current_index(&self) -> usize {
        self.instructions.len()
    }

    /// バイトコードの逆アセンブル（デバッグ用）
    pub fn disassemble(&self) -> String {
        let mut result = String::from("=== Bytecode Disassembly ===\n");

        result.push_str(&format!("Entry point: {}\n", self.entry_point));
        result.push_str(&format!("Constants: {} items\n", self.constants.len()));
        result.push_str(&format!("Instructions: {} items\n\n", self.instructions.len()));

        for (i, instruction) in self.instructions.iter().enumerate() {
            result.push_str(&format!("{:04} {:?}\n", i, instruction));
        }

        result
    }
}

impl Default for ByteCode {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bytecode_creation() {
        let mut bytecode = ByteCode::new();

        // 2 + 3 のバイトコード
        bytecode.emit(Instruction::LoadConst(Value::Number(2.0)));
        bytecode.emit(Instruction::LoadConst(Value::Number(3.0)));
        bytecode.emit(Instruction::Add);
        bytecode.emit(Instruction::Halt);

        assert_eq!(bytecode.instructions.len(), 4);
    }

    #[test]
    fn test_constant_pool() {
        let mut bytecode = ByteCode::new();

        let idx1 = bytecode.add_constant(Value::Number(42.0));
        let idx2 = bytecode.add_constant(Value::Number(42.0)); // 同じ値
        let idx3 = bytecode.add_constant(Value::Number(100.0)); // 異なる値

        assert_eq!(idx1, idx2); // 同じ定数は再利用
        assert_ne!(idx1, idx3); // 異なる定数は別インデックス
    }
}
