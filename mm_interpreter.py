"""
MM Language Interpreter
ASTを実行するインタプリタ
"""

import os
from typing import Any, Dict, List, Optional
from mm_parser import *

# Discord機能をインポート（オプショナル）
try:
    from mm_discord import setup_discord_builtins
    DISCORD_AVAILABLE = True
except ImportError:
    DISCORD_AVAILABLE = False

# 非同期機能をインポート（オプショナル）
try:
    from mm_async import setup_async_builtins
    ASYNC_AVAILABLE = True
except ImportError:
    ASYNC_AVAILABLE = False

# HTTP機能をインポート
try:
    from mm_http import setup_http_builtins
    HTTP_AVAILABLE = True
except ImportError:
    HTTP_AVAILABLE = False


class ReturnValue(Exception):
    """return文の実装用"""
    def __init__(self, value):
        self.value = value


class MMFunction:
    """ユーザー定義関数"""
    def __init__(self, name: str, parameters: List[str], body: List[ASTNode], closure: Dict[str, Any]):
        self.name = name
        self.parameters = parameters
        self.body = body
        self.closure = closure

    def __repr__(self):
        return f"<function {self.name}>"


class Environment:
    """変数スコープの管理"""
    def __init__(self, parent: Optional['Environment'] = None):
        self.variables: Dict[str, Any] = {}
        self.parent = parent

    def define(self, name: str, value: Any):
        self.variables[name] = value

    def get(self, name: str) -> Any:
        if name in self.variables:
            return self.variables[name]
        elif self.parent:
            return self.parent.get(name)
        else:
            raise NameError(f"Variable '{name}' is not defined")

    def set(self, name: str, value: Any):
        if name in self.variables:
            self.variables[name] = value
        elif self.parent:
            self.parent.set(name, value)
        else:
            raise NameError(f"Variable '{name}' is not defined")

    def exists(self, name: str) -> bool:
        if name in self.variables:
            return True
        elif self.parent:
            return self.parent.exists(name)
        else:
            return False


class Interpreter:
    def __init__(self):
        self.global_env = Environment()
        self.current_env = self.global_env

        # 組み込み関数
        self.setup_builtins()

    def setup_builtins(self):
        """組み込み関数の設定"""
        def builtin_print(*args):
            print(*args)
            return None

        def builtin_input(prompt=""):
            return input(prompt)

        def builtin_len(obj):
            if isinstance(obj, (list, str)):
                return len(obj)
            else:
                raise TypeError(f"len() not supported for {type(obj).__name__}")

        def builtin_type(obj):
            type_names = {
                int: "int",
                float: "float",
                str: "string",
                bool: "bool",
                list: "list",
                type(None): "none",
                MMFunction: "function",
            }
            return type_names.get(type(obj), "unknown")

        def builtin_str(obj):
            return str(obj)

        def builtin_int(obj):
            return int(obj)

        def builtin_float(obj):
            return float(obj)

        def builtin_range(*args):
            return list(range(*args))

        def builtin_append(lst, item):
            if not isinstance(lst, list):
                raise TypeError("append() requires a list")
            lst.append(item)
            return None

        def builtin_pop(lst, index=-1):
            if not isinstance(lst, list):
                raise TypeError("pop() requires a list")
            return lst.pop(index)

        def builtin_env(key, default=None):
            """環境変数を取得"""
            value = os.environ.get(str(key))
            if value is None:
                return default
            return value

        def builtin_env_set(key, value):
            """環境変数を設定"""
            os.environ[str(key)] = str(value)
            return None

        def builtin_env_has(key):
            """環境変数が存在するかチェック"""
            return str(key) in os.environ

        def builtin_env_list():
            """全ての環境変数をリストで取得"""
            return list(os.environ.keys())

        self.global_env.define('print', builtin_print)
        self.global_env.define('input', builtin_input)
        self.global_env.define('len', builtin_len)
        self.global_env.define('type', builtin_type)
        self.global_env.define('str', builtin_str)
        self.global_env.define('int', builtin_int)
        self.global_env.define('float', builtin_float)
        self.global_env.define('range', builtin_range)
        self.global_env.define('append', builtin_append)
        self.global_env.define('pop', builtin_pop)

        # 環境変数関連
        self.global_env.define('env', builtin_env)
        self.global_env.define('env_set', builtin_env_set)
        self.global_env.define('env_has', builtin_env_has)
        self.global_env.define('env_list', builtin_env_list)

        # Discord機能を追加（利用可能な場合）
        if DISCORD_AVAILABLE:
            setup_discord_builtins(self.global_env)

        # 非同期機能を追加（利用可能な場合）
        if ASYNC_AVAILABLE:
            setup_async_builtins(self.global_env)

        # HTTP機能を追加
        if HTTP_AVAILABLE:
            setup_http_builtins(self.global_env)

    def evaluate(self, node: ASTNode) -> Any:
        """ASTノードを評価"""
        if isinstance(node, Program):
            result = None
            for statement in node.statements:
                result = self.evaluate(statement)
            return result

        elif isinstance(node, NumberLiteral):
            return node.value

        elif isinstance(node, StringLiteral):
            return node.value

        elif isinstance(node, BooleanLiteral):
            return node.value

        elif isinstance(node, NoneLiteral):
            return None

        elif isinstance(node, ListLiteral):
            return [self.evaluate(elem) for elem in node.elements]

        elif isinstance(node, Identifier):
            return self.current_env.get(node.name)

        elif isinstance(node, BinaryOp):
            return self.evaluate_binary_op(node)

        elif isinstance(node, UnaryOp):
            return self.evaluate_unary_op(node)

        elif isinstance(node, VariableDeclaration):
            value = self.evaluate(node.value) if node.value else None
            self.current_env.define(node.name, value)
            return None

        elif isinstance(node, Assignment):
            value = self.evaluate(node.value)
            self.current_env.set(node.name, value)
            return None

        elif isinstance(node, FunctionDeclaration):
            func = MMFunction(
                node.name,
                node.parameters,
                node.body,
                self.current_env
            )
            self.current_env.define(node.name, func)
            return None

        elif isinstance(node, FunctionCall):
            return self.evaluate_function_call(node)

        elif isinstance(node, ReturnStatement):
            value = self.evaluate(node.value) if node.value else None
            raise ReturnValue(value)

        elif isinstance(node, IfStatement):
            condition = self.evaluate(node.condition)
            if self.is_truthy(condition):
                return self.evaluate_block(node.then_block)
            elif node.else_block:
                return self.evaluate_block(node.else_block)
            return None

        elif isinstance(node, WhileStatement):
            result = None
            while self.is_truthy(self.evaluate(node.condition)):
                result = self.evaluate_block(node.body)
            return result

        elif isinstance(node, ForStatement):
            iterable = self.evaluate(node.iterable)
            if not isinstance(iterable, (list, str)):
                raise TypeError("for loop requires an iterable (list or string)")

            result = None
            for item in iterable:
                self.current_env.define(node.variable, item)
                result = self.evaluate_block(node.body)
            return result

        elif isinstance(node, IndexAccess):
            obj = self.evaluate(node.object)
            index = self.evaluate(node.index)

            if isinstance(obj, (list, str)):
                if not isinstance(index, int):
                    raise TypeError("Index must be an integer")
                return obj[index]
            else:
                raise TypeError(f"Cannot index {type(obj).__name__}")

        else:
            raise NotImplementedError(f"Evaluation not implemented for {type(node).__name__}")

    def evaluate_block(self, statements: List[ASTNode]) -> Any:
        """ブロック内の文を評価"""
        result = None
        for stmt in statements:
            result = self.evaluate(stmt)
        return result

    def evaluate_binary_op(self, node: BinaryOp) -> Any:
        """二項演算子の評価"""
        left = self.evaluate(node.left)
        right = self.evaluate(node.right)

        if node.operator == 'add':
            return left + right
        elif node.operator == 'sub':
            return left - right
        elif node.operator == 'mul':
            return left * right
        elif node.operator == 'div':
            if right == 0:
                raise ZeroDivisionError("Division by zero")
            return left / right
        elif node.operator == 'mod':
            return left % right
        elif node.operator == 'eq':
            return left == right
        elif node.operator == 'ne':
            return left != right
        elif node.operator == 'lt':
            return left < right
        elif node.operator == 'le':
            return left <= right
        elif node.operator == 'gt':
            return left > right
        elif node.operator == 'ge':
            return left >= right
        elif node.operator == 'and':
            return left and right
        elif node.operator == 'or':
            return left or right
        else:
            raise NotImplementedError(f"Binary operator '{node.operator}' not implemented")

    def evaluate_unary_op(self, node: UnaryOp) -> Any:
        """単項演算子の評価"""
        operand = self.evaluate(node.operand)

        if node.operator == 'neg':
            return -operand
        elif node.operator == 'not':
            return not self.is_truthy(operand)
        else:
            raise NotImplementedError(f"Unary operator '{node.operator}' not implemented")

    def evaluate_function_call(self, node: FunctionCall) -> Any:
        """関数呼び出しの評価"""
        func = self.current_env.get(node.name)

        # 引数を評価
        args = [self.evaluate(arg) for arg in node.arguments]

        # 組み込み関数
        if callable(func) and not isinstance(func, MMFunction):
            return func(*args)

        # ユーザー定義関数
        elif isinstance(func, MMFunction):
            if len(args) != len(func.parameters):
                raise TypeError(
                    f"{func.name}() takes {len(func.parameters)} arguments but {len(args)} were given"
                )

            # 新しい環境を作成(クロージャを親とする)
            func_env = Environment(func.closure)

            # パラメータをバインド
            for param, arg in zip(func.parameters, args):
                func_env.define(param, arg)

            # 関数本体を実行
            prev_env = self.current_env
            self.current_env = func_env

            try:
                self.evaluate_block(func.body)
                result = None
            except ReturnValue as ret:
                result = ret.value
            finally:
                self.current_env = prev_env

            return result

        else:
            raise TypeError(f"'{node.name}' is not a function")

    def is_truthy(self, value: Any) -> bool:
        """真偽値判定"""
        if value is None or value is False:
            return False
        if value == 0 or value == "" or value == []:
            return False
        return True

    def run(self, source: str):
        """ソースコードを実行"""
        from mm_lexer import Lexer
        from mm_parser import Parser

        lexer = Lexer(source)
        tokens = lexer.tokenize()

        parser = Parser(tokens)
        ast = parser.parse()

        self.evaluate(ast)
