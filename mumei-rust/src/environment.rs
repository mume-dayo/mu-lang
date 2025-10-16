/// 環境（スコープ）管理
/// Mumei言語の変数スコープと環境を管理

use std::collections::HashMap;
use std::rc::Rc;
use std::cell::RefCell;
use crate::value::Value;

/// 環境（スコープ）
/// 変数の定義と参照を管理
#[derive(Debug, Clone)]
pub struct Environment {
    /// 現在のスコープの変数マップ
    values: Rc<RefCell<HashMap<String, Value>>>,

    /// 親スコープへの参照
    parent: Option<Rc<Environment>>,

    /// 定数（const）の名前を追跡
    constants: Rc<RefCell<Vec<String>>>,
}

impl Environment {
    /// 新しいグローバル環境を作成
    pub fn new() -> Self {
        Environment {
            values: Rc::new(RefCell::new(HashMap::new())),
            parent: None,
            constants: Rc::new(RefCell::new(Vec::new())),
        }
    }

    /// 親環境を持つ新しい環境を作成（スコープのネスト用）
    pub fn with_parent(parent: Rc<Environment>) -> Self {
        Environment {
            values: Rc::new(RefCell::new(HashMap::new())),
            parent: Some(parent),
            constants: Rc::new(RefCell::new(Vec::new())),
        }
    }

    /// 変数を定義（let）
    pub fn define(&self, name: String, value: Value) -> Result<(), String> {
        self.values.borrow_mut().insert(name, value);
        Ok(())
    }

    /// 定数を定義（const）
    pub fn define_const(&self, name: String, value: Value) -> Result<(), String> {
        // 定数リストに追加
        self.constants.borrow_mut().push(name.clone());

        // 値を定義
        self.values.borrow_mut().insert(name, value);
        Ok(())
    }

    /// 変数が定数かチェック
    pub fn is_constant(&self, name: &str) -> bool {
        // 現在のスコープで定数かチェック
        if self.constants.borrow().contains(&name.to_string()) {
            return true;
        }

        // 親スコープでチェック
        if let Some(ref parent) = self.parent {
            return parent.is_constant(name);
        }

        false
    }

    /// 変数に値を代入
    pub fn assign(&self, name: &str, value: Value) -> Result<(), String> {
        // 定数への代入を防ぐ
        if self.is_constant(name) {
            return Err(format!("Cannot assign to constant '{}'", name));
        }

        // 現在のスコープに変数が存在するかチェック
        if self.values.borrow().contains_key(name) {
            self.values.borrow_mut().insert(name.to_string(), value);
            return Ok(());
        }

        // 親スコープで変数を探す
        if let Some(ref parent) = self.parent {
            return parent.assign(name, value);
        }

        Err(format!("Variable '{}' is not defined", name))
    }

    /// 変数の値を取得
    pub fn get(&self, name: &str) -> Result<Value, String> {
        // 現在のスコープで探す
        if let Some(value) = self.values.borrow().get(name) {
            return Ok(value.clone());
        }

        // 親スコープで探す
        if let Some(ref parent) = self.parent {
            return parent.get(name);
        }

        Err(format!("Variable '{}' is not defined", name))
    }

    /// 変数が定義されているかチェック
    pub fn has(&self, name: &str) -> bool {
        // 現在のスコープにあるか
        if self.values.borrow().contains_key(name) {
            return true;
        }

        // 親スコープにあるか
        if let Some(ref parent) = self.parent {
            return parent.has(name);
        }

        false
    }

    /// 現在のスコープのみで変数が定義されているかチェック（親を見ない）
    pub fn has_local(&self, name: &str) -> bool {
        self.values.borrow().contains_key(name)
    }

    /// 変数を削除（デバッグ用）
    pub fn remove(&self, name: &str) -> Result<(), String> {
        // 定数は削除できない
        if self.is_constant(name) {
            return Err(format!("Cannot delete constant '{}'", name));
        }

        if self.values.borrow_mut().remove(name).is_some() {
            Ok(())
        } else {
            Err(format!("Variable '{}' is not defined", name))
        }
    }

    /// 現在のスコープの全変数名を取得
    pub fn get_all_names(&self) -> Vec<String> {
        self.values.borrow().keys().cloned().collect()
    }

    /// デバッグ用: 環境の内容を文字列で取得
    pub fn debug_string(&self) -> String {
        let mut result = String::from("Environment {\n");

        for (name, value) in self.values.borrow().iter() {
            let is_const = if self.constants.borrow().contains(name) {
                " (const)"
            } else {
                ""
            };
            result.push_str(&format!("  {}{}: {}\n", name, is_const, value.to_string()));
        }

        if let Some(ref parent) = self.parent {
            result.push_str("  parent: ");
            result.push_str(&parent.debug_string());
        }

        result.push_str("}");
        result
    }
}

impl Default for Environment {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_define_and_get() {
        let env = Environment::new();

        env.define("x".to_string(), Value::Number(42.0)).unwrap();

        let value = env.get("x").unwrap();
        assert_eq!(value, Value::Number(42.0));
    }

    #[test]
    fn test_assign() {
        let env = Environment::new();

        env.define("x".to_string(), Value::Number(10.0)).unwrap();
        env.assign("x", Value::Number(20.0)).unwrap();

        let value = env.get("x").unwrap();
        assert_eq!(value, Value::Number(20.0));
    }

    #[test]
    fn test_const() {
        let env = Environment::new();

        env.define_const("PI".to_string(), Value::Number(3.14159)).unwrap();

        // 定数の値は取得できる
        let value = env.get("PI").unwrap();
        assert_eq!(value, Value::Number(3.14159));

        // 定数への代入はエラー
        let result = env.assign("PI", Value::Number(3.0));
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Cannot assign to constant"));
    }

    #[test]
    fn test_nested_scope() {
        let parent_env = Rc::new(Environment::new());
        parent_env.define("x".to_string(), Value::Number(10.0)).unwrap();

        let child_env = Environment::with_parent(parent_env.clone());
        child_env.define("y".to_string(), Value::Number(20.0)).unwrap();

        // 子スコープから親の変数を参照できる
        let x = child_env.get("x").unwrap();
        assert_eq!(x, Value::Number(10.0));

        // 子スコープの変数も取得できる
        let y = child_env.get("y").unwrap();
        assert_eq!(y, Value::Number(20.0));

        // 親スコープからは子の変数は見えない
        assert!(parent_env.get("y").is_err());
    }

    #[test]
    fn test_shadowing() {
        let parent_env = Rc::new(Environment::new());
        parent_env.define("x".to_string(), Value::Number(10.0)).unwrap();

        let child_env = Environment::with_parent(parent_env.clone());
        child_env.define("x".to_string(), Value::Number(20.0)).unwrap();

        // 子スコープでは子の値が優先される
        let x = child_env.get("x").unwrap();
        assert_eq!(x, Value::Number(20.0));

        // 親スコープの値は変わらない
        let x_parent = parent_env.get("x").unwrap();
        assert_eq!(x_parent, Value::Number(10.0));
    }

    #[test]
    fn test_assign_in_parent() {
        let parent_env = Rc::new(Environment::new());
        parent_env.define("x".to_string(), Value::Number(10.0)).unwrap();

        let child_env = Environment::with_parent(parent_env.clone());

        // 子スコープから親の変数に代入
        child_env.assign("x", Value::Number(30.0)).unwrap();

        // 親スコープの値が変わる
        let x = parent_env.get("x").unwrap();
        assert_eq!(x, Value::Number(30.0));
    }

    #[test]
    fn test_undefined_variable() {
        let env = Environment::new();

        let result = env.get("undefined");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("is not defined"));
    }

    #[test]
    fn test_has_variable() {
        let env = Environment::new();
        env.define("x".to_string(), Value::Number(10.0)).unwrap();

        assert!(env.has("x"));
        assert!(!env.has("y"));
    }

    #[test]
    fn test_has_local() {
        let parent_env = Rc::new(Environment::new());
        parent_env.define("x".to_string(), Value::Number(10.0)).unwrap();

        let child_env = Environment::with_parent(parent_env);
        child_env.define("y".to_string(), Value::Number(20.0)).unwrap();

        // has_localは現在のスコープのみチェック
        assert!(child_env.has_local("y"));
        assert!(!child_env.has_local("x"));

        // hasは親スコープも含む
        assert!(child_env.has("x"));
        assert!(child_env.has("y"));
    }
}
