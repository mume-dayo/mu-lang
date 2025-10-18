/// 値の型システム
/// Mumei言語の実行時の値を表現

use std::collections::HashMap;
use std::fmt;
use std::rc::Rc;
use std::cell::RefCell;
use crate::ast::ASTNode;
use crate::environment::Environment;

/// Mumei言語の値
#[derive(Debug, Clone)]
pub enum Value {
    /// 数値（f64）
    Number(f64),

    /// 文字列
    String(String),

    /// 真偽値
    Boolean(bool),

    /// Null
    Null,

    /// リスト
    List(Rc<RefCell<Vec<Value>>>),

    /// 辞書
    Dictionary(Rc<RefCell<HashMap<String, Value>>>),

    /// 関数
    Function {
        name: String,
        parameters: Vec<String>,
        body: Vec<ASTNode>,
        closure: Rc<Environment>,
        is_async: bool,
    },

    /// ネイティブ関数（Rustで実装された組み込み関数）
    NativeFunction {
        name: String,
        arity: usize,
        function: fn(Vec<Value>) -> Result<Value, String>,
    },

    /// クラス
    Class {
        name: String,
        methods: HashMap<String, Value>,
        parent: Option<Box<Value>>,
    },

    /// インスタンス
    Instance {
        class_name: String,
        fields: Rc<RefCell<HashMap<String, Value>>>,
    },
}

impl Value {
    /// 値を真偽値として評価
    pub fn is_truthy(&self) -> bool {
        match self {
            Value::Null => false,
            Value::Boolean(b) => *b,
            Value::Number(n) => *n != 0.0,
            Value::String(s) => !s.is_empty(),
            Value::List(list) => !list.borrow().is_empty(),
            Value::Dictionary(dict) => !dict.borrow().is_empty(),
            _ => true,
        }
    }

    /// 値の型名を取得
    pub fn type_name(&self) -> &str {
        match self {
            Value::Number(_) => "number",
            Value::String(_) => "string",
            Value::Boolean(_) => "boolean",
            Value::Null => "null",
            Value::List(_) => "list",
            Value::Dictionary(_) => "dictionary",
            Value::Function { .. } => "function",
            Value::NativeFunction { .. } => "native_function",
            Value::Class { .. } => "class",
            Value::Instance { .. } => "instance",
        }
    }

    /// 数値として取得
    pub fn as_number(&self) -> Result<f64, String> {
        match self {
            Value::Number(n) => Ok(*n),
            _ => Err(format!("Expected number, got {}", self.type_name())),
        }
    }

    /// 文字列として取得
    pub fn as_string(&self) -> Result<String, String> {
        match self {
            Value::String(s) => Ok(s.clone()),
            _ => Err(format!("Expected string, got {}", self.type_name())),
        }
    }

    /// 真偽値として取得
    pub fn as_boolean(&self) -> Result<bool, String> {
        match self {
            Value::Boolean(b) => Ok(*b),
            _ => Err(format!("Expected boolean, got {}", self.type_name())),
        }
    }

    /// リストとして取得
    pub fn as_list(&self) -> Result<Rc<RefCell<Vec<Value>>>, String> {
        match self {
            Value::List(list) => Ok(list.clone()),
            _ => Err(format!("Expected list, got {}", self.type_name())),
        }
    }

    /// 辞書として取得
    pub fn as_dict(&self) -> Result<Rc<RefCell<HashMap<String, Value>>>, String> {
        match self {
            Value::Dictionary(dict) => Ok(dict.clone()),
            _ => Err(format!("Expected dictionary, got {}", self.type_name())),
        }
    }

    /// 等価性チェック
    pub fn equals(&self, other: &Value) -> bool {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => (a - b).abs() < f64::EPSILON,
            (Value::String(a), Value::String(b)) => a == b,
            (Value::Boolean(a), Value::Boolean(b)) => a == b,
            (Value::Null, Value::Null) => true,
            (Value::List(a), Value::List(b)) => {
                let a_vec = a.borrow();
                let b_vec = b.borrow();
                if a_vec.len() != b_vec.len() {
                    return false;
                }
                a_vec.iter().zip(b_vec.iter()).all(|(x, y)| x.equals(y))
            }
            _ => false,
        }
    }

    /// 値を文字列に変換（toString相当）
    pub fn to_string(&self) -> String {
        match self {
            Value::Number(n) => {
                if n.fract() == 0.0 {
                    format!("{}", *n as i64)
                } else {
                    format!("{}", n)
                }
            }
            Value::String(s) => s.clone(),
            Value::Boolean(b) => b.to_string(),
            Value::Null => "null".to_string(),
            Value::List(list) => {
                let items: Vec<String> = list
                    .borrow()
                    .iter()
                    .map(|v| v.to_string())
                    .collect();
                format!("[{}]", items.join(", "))
            }
            Value::Dictionary(dict) => {
                let items: Vec<String> = dict
                    .borrow()
                    .iter()
                    .map(|(k, v)| format!("{}: {}", k, v.to_string()))
                    .collect();
                format!("{{{}}}", items.join(", "))
            }
            Value::Function { name, parameters, .. } => {
                format!("<function {}({})>", name, parameters.join(", "))
            }
            Value::NativeFunction { name, .. } => {
                format!("<native function {}>", name)
            }
            Value::Class { name, .. } => {
                format!("<class {}>", name)
            }
            Value::Instance { class_name, .. } => {
                format!("<{} instance>", class_name)
            }
        }
    }

    /// リストに要素を追加
    pub fn list_append(&self, value: Value) -> Result<(), String> {
        match self {
            Value::List(list) => {
                list.borrow_mut().push(value);
                Ok(())
            }
            _ => Err(format!("Cannot append to {}", self.type_name())),
        }
    }

    /// リストから要素を取得
    pub fn list_get(&self, index: usize) -> Result<Value, String> {
        match self {
            Value::List(list) => {
                let borrowed = list.borrow();
                borrowed
                    .get(index)
                    .cloned()
                    .ok_or_else(|| format!("Index {} out of range", index))
            }
            _ => Err(format!("Cannot index {}", self.type_name())),
        }
    }

    /// リストの長さを取得
    pub fn list_len(&self) -> Result<usize, String> {
        match self {
            Value::List(list) => Ok(list.borrow().len()),
            _ => Err(format!("{} has no length", self.type_name())),
        }
    }

    /// 辞書に値を設定
    pub fn dict_set(&self, key: String, value: Value) -> Result<(), String> {
        match self {
            Value::Dictionary(dict) => {
                dict.borrow_mut().insert(key, value);
                Ok(())
            }
            _ => Err(format!("Cannot set property on {}", self.type_name())),
        }
    }

    /// 辞書から値を取得
    pub fn dict_get(&self, key: &str) -> Result<Value, String> {
        match self {
            Value::Dictionary(dict) => {
                dict.borrow()
                    .get(key)
                    .cloned()
                    .ok_or_else(|| format!("Key '{}' not found", key))
            }
            _ => Err(format!("Cannot get property from {}", self.type_name())),
        }
    }
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_string())
    }
}

impl PartialEq for Value {
    fn eq(&self, other: &Self) -> bool {
        self.equals(other)
    }
}

// 算術演算のヘルパー
impl Value {
    /// 加算
    pub fn add(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Number(a + b)),
            (Value::String(a), Value::String(b)) => Ok(Value::String(format!("{}{}", a, b))),
            (Value::String(a), b) => Ok(Value::String(format!("{}{}", a, b.to_string()))),
            (a, Value::String(b)) => Ok(Value::String(format!("{}{}", a.to_string(), b))),
            _ => Err(format!(
                "Cannot add {} and {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// 減算
    pub fn subtract(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Number(a - b)),
            _ => Err(format!(
                "Cannot subtract {} from {}",
                other.type_name(),
                self.type_name()
            )),
        }
    }

    /// 乗算
    pub fn multiply(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Number(a * b)),
            (Value::String(s), Value::Number(n)) | (Value::Number(n), Value::String(s)) => {
                if *n >= 0.0 && n.fract() == 0.0 {
                    Ok(Value::String(s.repeat(*n as usize)))
                } else {
                    Err("String multiplication requires non-negative integer".to_string())
                }
            }
            _ => Err(format!(
                "Cannot multiply {} and {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// 除算
    pub fn divide(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => {
                if *b == 0.0 {
                    Err("Division by zero".to_string())
                } else {
                    Ok(Value::Number(a / b))
                }
            }
            _ => Err(format!(
                "Cannot divide {} by {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// 剰余
    pub fn modulo(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => {
                if *b == 0.0 {
                    Err("Modulo by zero".to_string())
                } else {
                    Ok(Value::Number(a % b))
                }
            }
            _ => Err(format!(
                "Cannot modulo {} by {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// べき乗
    pub fn power(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Number(a.powf(*b))),
            _ => Err(format!(
                "Cannot raise {} to power of {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// 比較: <
    pub fn less_than(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Boolean(a < b)),
            (Value::String(a), Value::String(b)) => Ok(Value::Boolean(a < b)),
            _ => Err(format!(
                "Cannot compare {} and {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }

    /// 比較: >
    pub fn greater_than(&self, other: &Value) -> Result<Value, String> {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => Ok(Value::Boolean(a > b)),
            (Value::String(a), Value::String(b)) => Ok(Value::Boolean(a > b)),
            _ => Err(format!(
                "Cannot compare {} and {}",
                self.type_name(),
                other.type_name()
            )),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_value_types() {
        let num = Value::Number(42.0);
        assert_eq!(num.type_name(), "number");
        assert_eq!(num.to_string(), "42");

        let str_val = Value::String("hello".to_string());
        assert_eq!(str_val.type_name(), "string");
        assert_eq!(str_val.to_string(), "hello");
    }

    #[test]
    fn test_arithmetic() {
        let a = Value::Number(10.0);
        let b = Value::Number(3.0);

        assert_eq!(a.add(&b).unwrap(), Value::Number(13.0));
        assert_eq!(a.subtract(&b).unwrap(), Value::Number(7.0));
        assert_eq!(a.multiply(&b).unwrap(), Value::Number(30.0));
        assert_eq!(a.divide(&b).unwrap(), Value::Number(10.0 / 3.0));
    }

    #[test]
    fn test_string_concat() {
        let a = Value::String("Hello, ".to_string());
        let b = Value::String("World!".to_string());

        assert_eq!(
            a.add(&b).unwrap(),
            Value::String("Hello, World!".to_string())
        );
    }

    #[test]
    fn test_truthiness() {
        assert!(Value::Boolean(true).is_truthy());
        assert!(!Value::Boolean(false).is_truthy());
        assert!(!Value::Null.is_truthy());
        assert!(Value::Number(1.0).is_truthy());
        assert!(!Value::Number(0.0).is_truthy());
    }

    #[test]
    fn test_equality() {
        assert!(Value::Number(42.0).equals(&Value::Number(42.0)));
        assert!(!Value::Number(42.0).equals(&Value::Number(43.0)));

        assert!(Value::String("hello".to_string()).equals(&Value::String("hello".to_string())));
        assert!(!Value::String("hello".to_string()).equals(&Value::String("world".to_string())));
    }
}
