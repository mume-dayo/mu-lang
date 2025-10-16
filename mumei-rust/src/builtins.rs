/// 組み込み関数
/// Mumei言語の標準ライブラリ（組み込み関数）

use crate::value::Value;
use crate::environment::Environment;
use std::rc::Rc;

/// 組み込み関数を環境に登録
pub fn setup_builtins(env: &Environment) {
    // 基本的な入出力
    env.define("print".to_string(), Value::NativeFunction {
        name: "print".to_string(),
        arity: 1,
        function: builtin_print,
    }).unwrap();

    env.define("println".to_string(), Value::NativeFunction {
        name: "println".to_string(),
        arity: 1,
        function: builtin_println,
    }).unwrap();

    env.define("input".to_string(), Value::NativeFunction {
        name: "input".to_string(),
        arity: 0,
        function: builtin_input,
    }).unwrap();

    // 型変換
    env.define("str".to_string(), Value::NativeFunction {
        name: "str".to_string(),
        arity: 1,
        function: builtin_str,
    }).unwrap();

    env.define("num".to_string(), Value::NativeFunction {
        name: "num".to_string(),
        arity: 1,
        function: builtin_num,
    }).unwrap();

    env.define("bool".to_string(), Value::NativeFunction {
        name: "bool".to_string(),
        arity: 1,
        function: builtin_bool,
    }).unwrap();

    // 型チェック
    env.define("type".to_string(), Value::NativeFunction {
        name: "type".to_string(),
        arity: 1,
        function: builtin_type,
    }).unwrap();

    // コレクション操作
    env.define("len".to_string(), Value::NativeFunction {
        name: "len".to_string(),
        arity: 1,
        function: builtin_len,
    }).unwrap();

    env.define("push".to_string(), Value::NativeFunction {
        name: "push".to_string(),
        arity: 2,
        function: builtin_push,
    }).unwrap();

    env.define("pop".to_string(), Value::NativeFunction {
        name: "pop".to_string(),
        arity: 1,
        function: builtin_pop,
    }).unwrap();

    env.define("keys".to_string(), Value::NativeFunction {
        name: "keys".to_string(),
        arity: 1,
        function: builtin_keys,
    }).unwrap();

    env.define("values".to_string(), Value::NativeFunction {
        name: "values".to_string(),
        arity: 1,
        function: builtin_values,
    }).unwrap();

    // 数学関数
    env.define("abs".to_string(), Value::NativeFunction {
        name: "abs".to_string(),
        arity: 1,
        function: builtin_abs,
    }).unwrap();

    env.define("floor".to_string(), Value::NativeFunction {
        name: "floor".to_string(),
        arity: 1,
        function: builtin_floor,
    }).unwrap();

    env.define("ceil".to_string(), Value::NativeFunction {
        name: "ceil".to_string(),
        arity: 1,
        function: builtin_ceil,
    }).unwrap();

    env.define("round".to_string(), Value::NativeFunction {
        name: "round".to_string(),
        arity: 1,
        function: builtin_round,
    }).unwrap();

    env.define("sqrt".to_string(), Value::NativeFunction {
        name: "sqrt".to_string(),
        arity: 1,
        function: builtin_sqrt,
    }).unwrap();

    env.define("min".to_string(), Value::NativeFunction {
        name: "min".to_string(),
        arity: 2,
        function: builtin_min,
    }).unwrap();

    env.define("max".to_string(), Value::NativeFunction {
        name: "max".to_string(),
        arity: 2,
        function: builtin_max,
    }).unwrap();

    // 文字列操作
    env.define("upper".to_string(), Value::NativeFunction {
        name: "upper".to_string(),
        arity: 1,
        function: builtin_upper,
    }).unwrap();

    env.define("lower".to_string(), Value::NativeFunction {
        name: "lower".to_string(),
        arity: 1,
        function: builtin_lower,
    }).unwrap();

    env.define("split".to_string(), Value::NativeFunction {
        name: "split".to_string(),
        arity: 2,
        function: builtin_split,
    }).unwrap();

    env.define("join".to_string(), Value::NativeFunction {
        name: "join".to_string(),
        arity: 2,
        function: builtin_join,
    }).unwrap();

    // ユーティリティ
    env.define("range".to_string(), Value::NativeFunction {
        name: "range".to_string(),
        arity: 2,
        function: builtin_range,
    }).unwrap();

    env.define("assert".to_string(), Value::NativeFunction {
        name: "assert".to_string(),
        arity: 2,
        function: builtin_assert,
    }).unwrap();

    // 定数
    env.define_const("PI".to_string(), Value::Number(std::f64::consts::PI)).unwrap();
    env.define_const("E".to_string(), Value::Number(std::f64::consts::E)).unwrap();
}

// ============================================
// 組み込み関数の実装
// ============================================

/// print(value) - 値を出力（改行なし）
fn builtin_print(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("print() takes 1 argument, got {}", args.len()));
    }
    print!("{}", args[0].to_string());
    Ok(Value::Null)
}

/// println(value) - 値を出力（改行あり）
fn builtin_println(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("println() takes 1 argument, got {}", args.len()));
    }
    println!("{}", args[0].to_string());
    Ok(Value::Null)
}

/// input() - 標準入力から1行読み込む
fn builtin_input(_args: Vec<Value>) -> Result<Value, String> {
    use std::io::{self, BufRead};
    let stdin = io::stdin();
    let mut line = String::new();
    stdin.lock().read_line(&mut line)
        .map_err(|e| format!("Input error: {}", e))?;

    // 末尾の改行を削除
    if line.ends_with('\n') {
        line.pop();
        if line.ends_with('\r') {
            line.pop();
        }
    }

    Ok(Value::String(line))
}

/// str(value) - 値を文字列に変換
fn builtin_str(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("str() takes 1 argument, got {}", args.len()));
    }
    Ok(Value::String(args[0].to_string()))
}

/// num(value) - 値を数値に変換
fn builtin_num(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("num() takes 1 argument, got {}", args.len()));
    }

    match &args[0] {
        Value::Number(n) => Ok(Value::Number(*n)),
        Value::String(s) => {
            s.parse::<f64>()
                .map(Value::Number)
                .map_err(|_| format!("Cannot convert '{}' to number", s))
        }
        Value::Boolean(b) => Ok(Value::Number(if *b { 1.0 } else { 0.0 })),
        _ => Err(format!("Cannot convert {} to number", args[0].type_name())),
    }
}

/// bool(value) - 値を真偽値に変換
fn builtin_bool(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("bool() takes 1 argument, got {}", args.len()));
    }
    Ok(Value::Boolean(args[0].is_truthy()))
}

/// type(value) - 値の型名を取得
fn builtin_type(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("type() takes 1 argument, got {}", args.len()));
    }
    Ok(Value::String(args[0].type_name().to_string()))
}

/// len(collection) - コレクションの長さを取得
fn builtin_len(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("len() takes 1 argument, got {}", args.len()));
    }

    match &args[0] {
        Value::String(s) => Ok(Value::Number(s.chars().count() as f64)),
        Value::List(list) => Ok(Value::Number(list.borrow().len() as f64)),
        Value::Dictionary(dict) => Ok(Value::Number(dict.borrow().len() as f64)),
        _ => Err(format!("{} has no length", args[0].type_name())),
    }
}

/// push(list, value) - リストに要素を追加
fn builtin_push(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("push() takes 2 arguments, got {}", args.len()));
    }

    match &args[0] {
        Value::List(list) => {
            list.borrow_mut().push(args[1].clone());
            Ok(Value::Null)
        }
        _ => Err(format!("Cannot push to {}", args[0].type_name())),
    }
}

/// pop(list) - リストから最後の要素を削除して返す
fn builtin_pop(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("pop() takes 1 argument, got {}", args.len()));
    }

    match &args[0] {
        Value::List(list) => {
            list.borrow_mut()
                .pop()
                .ok_or_else(|| "Cannot pop from empty list".to_string())
        }
        _ => Err(format!("Cannot pop from {}", args[0].type_name())),
    }
}

/// keys(dict) - 辞書のキー一覧を取得
fn builtin_keys(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("keys() takes 1 argument, got {}", args.len()));
    }

    match &args[0] {
        Value::Dictionary(dict) => {
            let keys: Vec<Value> = dict.borrow()
                .keys()
                .map(|k| Value::String(k.clone()))
                .collect();
            Ok(Value::List(Rc::new(std::cell::RefCell::new(keys))))
        }
        _ => Err(format!("Cannot get keys from {}", args[0].type_name())),
    }
}

/// values(dict) - 辞書の値一覧を取得
fn builtin_values(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("values() takes 1 argument, got {}", args.len()));
    }

    match &args[0] {
        Value::Dictionary(dict) => {
            let values: Vec<Value> = dict.borrow()
                .values()
                .cloned()
                .collect();
            Ok(Value::List(Rc::new(std::cell::RefCell::new(values))))
        }
        _ => Err(format!("Cannot get values from {}", args[0].type_name())),
    }
}

/// abs(number) - 絶対値
fn builtin_abs(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("abs() takes 1 argument, got {}", args.len()));
    }
    let n = args[0].as_number()?;
    Ok(Value::Number(n.abs()))
}

/// floor(number) - 切り捨て
fn builtin_floor(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("floor() takes 1 argument, got {}", args.len()));
    }
    let n = args[0].as_number()?;
    Ok(Value::Number(n.floor()))
}

/// ceil(number) - 切り上げ
fn builtin_ceil(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("ceil() takes 1 argument, got {}", args.len()));
    }
    let n = args[0].as_number()?;
    Ok(Value::Number(n.ceil()))
}

/// round(number) - 四捨五入
fn builtin_round(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("round() takes 1 argument, got {}", args.len()));
    }
    let n = args[0].as_number()?;
    Ok(Value::Number(n.round()))
}

/// sqrt(number) - 平方根
fn builtin_sqrt(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("sqrt() takes 1 argument, got {}", args.len()));
    }
    let n = args[0].as_number()?;
    if n < 0.0 {
        return Err("Cannot take square root of negative number".to_string());
    }
    Ok(Value::Number(n.sqrt()))
}

/// min(a, b) - 最小値
fn builtin_min(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("min() takes 2 arguments, got {}", args.len()));
    }
    let a = args[0].as_number()?;
    let b = args[1].as_number()?;
    Ok(Value::Number(a.min(b)))
}

/// max(a, b) - 最大値
fn builtin_max(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("max() takes 2 arguments, got {}", args.len()));
    }
    let a = args[0].as_number()?;
    let b = args[1].as_number()?;
    Ok(Value::Number(a.max(b)))
}

/// upper(string) - 大文字に変換
fn builtin_upper(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("upper() takes 1 argument, got {}", args.len()));
    }
    let s = args[0].as_string()?;
    Ok(Value::String(s.to_uppercase()))
}

/// lower(string) - 小文字に変換
fn builtin_lower(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 1 {
        return Err(format!("lower() takes 1 argument, got {}", args.len()));
    }
    let s = args[0].as_string()?;
    Ok(Value::String(s.to_lowercase()))
}

/// split(string, delimiter) - 文字列を分割
fn builtin_split(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("split() takes 2 arguments, got {}", args.len()));
    }
    let s = args[0].as_string()?;
    let delimiter = args[1].as_string()?;

    let parts: Vec<Value> = s
        .split(&delimiter)
        .map(|part| Value::String(part.to_string()))
        .collect();

    Ok(Value::List(Rc::new(std::cell::RefCell::new(parts))))
}

/// join(list, separator) - リストを文字列に結合
fn builtin_join(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("join() takes 2 arguments, got {}", args.len()));
    }

    let list = args[0].as_list()?;
    let separator = args[1].as_string()?;

    let strings: Vec<String> = list.borrow()
        .iter()
        .map(|v| v.to_string())
        .collect();

    Ok(Value::String(strings.join(&separator)))
}

/// range(start, end) - 範囲のリストを生成
fn builtin_range(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("range() takes 2 arguments, got {}", args.len()));
    }

    let start = args[0].as_number()? as i64;
    let end = args[1].as_number()? as i64;

    let values: Vec<Value> = (start..end)
        .map(|i| Value::Number(i as f64))
        .collect();

    Ok(Value::List(Rc::new(std::cell::RefCell::new(values))))
}

/// assert(condition, message) - アサーション
fn builtin_assert(args: Vec<Value>) -> Result<Value, String> {
    if args.len() != 2 {
        return Err(format!("assert() takes 2 arguments, got {}", args.len()));
    }

    if !args[0].is_truthy() {
        let message = args[1].to_string();
        return Err(format!("Assertion failed: {}", message));
    }

    Ok(Value::Null)
}
