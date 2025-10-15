"""
MM Language Interpreter
ASTを実行するインタプリタ
"""

import os
from typing import Any, Dict, List, Optional
from mm_parser import *
from mm_typechecker import global_type_checker

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

# ファイルI/O機能をインポート
try:
    from mm_file import setup_file_builtins
    FILE_AVAILABLE = True
except ImportError:
    FILE_AVAILABLE = False

# 標準ライブラリをインポート
try:
    from mm_stdlib import setup_stdlib_builtins
    STDLIB_AVAILABLE = True
except ImportError:
    STDLIB_AVAILABLE = False

# デバッガーをインポート
try:
    from mm_debug import setup_debug_builtins
    DEBUG_AVAILABLE = True
except ImportError:
    DEBUG_AVAILABLE = False


class ReturnValue(Exception):
    """return文の実装用"""
    def __init__(self, value):
        self.value = value


class YieldValue(Exception):
    """yield文の実装用"""
    def __init__(self, value):
        self.value = value


class BreakException(Exception):
    """break文の実装用"""
    pass


class ContinueException(Exception):
    """continue文の実装用"""
    pass


class MMException(Exception):
    """Mumei言語の例外"""
    def __init__(self, message):
        self.message = message
        super().__init__(message)


class MMFunction:
    """ユーザー定義関数"""
    def __init__(self, name: str, parameters: List[str], body: List[ASTNode], closure: Dict[str, Any], variadic_param: Optional[str] = None, is_async: bool = False, is_generator: bool = False):
        self.name = name
        self.parameters = parameters
        self.body = body
        self.closure = closure
        self.variadic_param = variadic_param  # 可変長引数名
        self.is_async = is_async  # 非同期関数かどうか
        self.is_generator = is_generator  # ジェネレーターかどうか
        self.is_property = False  # プロパティかどうか
        self.setter = None  # setter関数（プロパティの場合）

    def __repr__(self):
        if self.is_property:
            return f"<property {self.name}>"
        if self.is_generator:
            return f"<generator function {self.name}>"
        return f"<async function {self.name}>" if self.is_async else f"<function {self.name}>"


class MMGenerator:
    """ジェネレーターオブジェクト（遅延評価版）"""
    def __init__(self, function: MMFunction, args: List[Any], interpreter):
        self.function = function
        self.args = args
        self.interpreter = interpreter
        self.exhausted = False
        self.env = None  # ジェネレーター専用の環境
        self.execution_stack = []  # 実行スタック: [(statements, index, loop_state), ...]

    def __iter__(self):
        return self

    def __next__(self):
        if self.exhausted:
            raise StopIteration

        # 初回実行時に環境をセットアップ
        if self.env is None:
            self.env = Environment(parent=self.function.closure)

            # 引数をバインド
            for i, param in enumerate(self.function.parameters):
                if i < len(self.args):
                    self.env.define(param, self.args[i])
                else:
                    self.env.define(param, None)

            # 可変長引数を処理
            if self.function.variadic_param:
                variadic_args = self.args[len(self.function.parameters):]
                self.env.define(self.function.variadic_param, variadic_args)

            # 関数本体を実行スタックに追加
            self.execution_stack.append({
                'statements': self.function.body,
                'index': 0,
                'type': 'block'
            })

        # 現在の環境を保存して切り替え
        old_env = self.interpreter.current_env
        self.interpreter.current_env = self.env

        try:
            return self._execute_until_yield()
        except ReturnValue:
            # returnで終了
            self.exhausted = True
            raise StopIteration
        finally:
            self.interpreter.current_env = old_env

    def _execute_until_yield(self):
        """yieldが見つかるまで文を実行し続ける"""
        while self.execution_stack:
            frame = self.execution_stack[-1]
            statements = frame['statements']
            index = frame['index']

            # 現在のフレームの文をすべて実行した場合
            if index >= len(statements):
                self.execution_stack.pop()

                # ループフレームの場合は次のイテレーションへ
                if frame['type'] == 'for_loop':
                    loop_info = frame['loop_info']
                    try:
                        # 次のアイテムを取得
                        next_item = next(loop_info['iterator'])
                        self.env.set(loop_info['variable'], next_item)
                        # インデックスをリセットしてループを再開
                        frame['index'] = 0
                        self.execution_stack.append(frame)
                    except StopIteration:
                        # ループ終了
                        pass
                elif frame['type'] == 'while_loop':
                    loop_info = frame['loop_info']
                    # 条件を再評価
                    if self.interpreter.is_truthy(self.interpreter.evaluate(loop_info['condition'])):
                        # インデックスをリセットしてループを再開
                        frame['index'] = 0
                        self.execution_stack.append(frame)
                continue

            # 次の文を実行
            stmt = statements[index]
            frame['index'] += 1

            try:
                # ループ文の特別処理
                if isinstance(stmt, ForStatement):
                    iterable = self.interpreter.evaluate(stmt.iterable)
                    if not isinstance(iterable, (list, str, set, MMGenerator)):
                        raise TypeError("for loop requires an iterable")

                    iterator = iter(iterable)
                    try:
                        first_item = next(iterator)
                        self.env.define(stmt.variable, first_item)

                        # forループフレームを追加
                        self.execution_stack.append({
                            'statements': stmt.body,
                            'index': 0,
                            'type': 'for_loop',
                            'loop_info': {
                                'iterator': iterator,
                                'variable': stmt.variable
                            }
                        })
                    except StopIteration:
                        # 空のイテラブル
                        pass

                elif isinstance(stmt, WhileStatement):
                    # 条件を評価
                    if self.interpreter.is_truthy(self.interpreter.evaluate(stmt.condition)):
                        # whileループフレームを追加
                        self.execution_stack.append({
                            'statements': stmt.body,
                            'index': 0,
                            'type': 'while_loop',
                            'loop_info': {
                                'condition': stmt.condition
                            }
                        })

                elif isinstance(stmt, IfStatement):
                    condition = self.interpreter.evaluate(stmt.condition)
                    if self.interpreter.is_truthy(condition):
                        self.execution_stack.append({
                            'statements': stmt.then_block,
                            'index': 0,
                            'type': 'block'
                        })
                    else:
                        # elif branches
                        executed = False
                        for elif_condition, elif_body in stmt.elif_branches:
                            if self.interpreter.is_truthy(self.interpreter.evaluate(elif_condition)):
                                self.execution_stack.append({
                                    'statements': elif_body,
                                    'index': 0,
                                    'type': 'block'
                                })
                                executed = True
                                break

                        # else block
                        if not executed and stmt.else_block:
                            self.execution_stack.append({
                                'statements': stmt.else_block,
                                'index': 0,
                                'type': 'block'
                            })

                elif isinstance(stmt, YieldExpression):
                    value = self.interpreter.evaluate(stmt.value) if stmt.value else None
                    return value

                else:
                    # 通常の文を実行
                    self.interpreter.evaluate(stmt)

            except YieldValue as yv:
                # yieldが実行された
                return yv.value
            except BreakException:
                # ループを抜ける
                while self.execution_stack and self.execution_stack[-1]['type'] not in ('for_loop', 'while_loop'):
                    self.execution_stack.pop()
                if self.execution_stack:
                    self.execution_stack.pop()
            except ContinueException:
                # 現在のループイテレーションをスキップ
                while self.execution_stack and self.execution_stack[-1]['type'] not in ('for_loop', 'while_loop'):
                    self.execution_stack.pop()
                if self.execution_stack:
                    # ループフレームのインデックスを最後に設定して次のイテレーションへ
                    loop_frame = self.execution_stack[-1]
                    loop_frame['index'] = len(loop_frame['statements'])

        # すべての文を実行完了
        self.exhausted = True
        raise StopIteration

    def __repr__(self):
        return f"<generator {self.function.name}>"


class MMClass:
    """ユーザー定義クラス"""
    def __init__(self, name: str, methods: Dict[str, MMFunction], parent: Optional['MMClass'] = None):
        self.name = name
        self.methods = methods
        self.parent = parent

    def __repr__(self):
        return f"<class {self.name}>"


class MMInstance:
    """クラスのインスタンス"""
    def __init__(self, mm_class: MMClass):
        self.mm_class = mm_class
        self.fields = {}  # インスタンス変数

    def get(self, name: str):
        # まずインスタンス変数を確認（プロパティが存在する場合はスキップ）
        if name in self.mm_class.methods:
            method = self.mm_class.methods[name]
            # プロパティの場合は値を返す（getterは呼び出さない - 後でインタープリタで処理）
            if isinstance(method, MMFunction) and method.is_property:
                return method
            return method

        # インスタンス変数を確認
        if name in self.fields:
            return self.fields[name]

        # 親クラスを確認
        if self.mm_class.parent:
            if name in self.mm_class.parent.methods:
                return self.mm_class.parent.methods[name]
        raise AttributeError(f"'{self.mm_class.name}' object has no attribute '{name}'")

    def set(self, name: str, value: Any, interpreter=None):
        # プロパティのsetterがある場合はそれを呼ぶ
        if name in self.mm_class.methods:
            method = self.mm_class.methods[name]
            if isinstance(method, MMFunction) and method.is_property and method.setter:
                # setterを呼び出す
                if interpreter:
                    interpreter.call_mm_function(method.setter, [value], self)
                    return
        # 通常のフィールド代入
        self.fields[name] = value

    def __repr__(self):
        return f"<{self.mm_class.name} instance>"


class MMEnum:
    """列挙型"""
    def __init__(self, name: str, values: List[str]):
        self.name = name
        self.values = {}
        # 各値をインデックスで格納
        for i, value in enumerate(values):
            self.values[value] = i

    def __getattribute__(self, name):
        # Pythonの特殊属性はそのまま返す
        if name.startswith('__') and name.endswith('__'):
            return object.__getattribute__(self, name)
        if name in ('name', 'values'):
            return object.__getattribute__(self, name)

        values = object.__getattribute__(self, 'values')
        if name in values:
            return values[name]
        raise AttributeError(f"Enum '{object.__getattribute__(self, 'name')}' has no value '{name}'")

    def __repr__(self):
        return f"<enum {self.name}>"


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
        self.module_cache = {}  # モジュールキャッシュ

        # 組み込み関数
        self.setup_builtins()

    def has_yield(self, body: List[ASTNode]) -> bool:
        """関数本体にyieldが含まれているかチェック"""
        for stmt in body:
            if isinstance(stmt, YieldExpression):
                return True
            # ネストした構造内もチェック
            if isinstance(stmt, IfStatement):
                if self.has_yield(stmt.then_block):
                    return True
                for _, elif_body in stmt.elif_branches:
                    if self.has_yield(elif_body):
                        return True
                if stmt.else_block and self.has_yield(stmt.else_block):
                    return True
            elif isinstance(stmt, WhileStatement):
                if self.has_yield(stmt.body):
                    return True
            elif isinstance(stmt, ForStatement):
                if self.has_yield(stmt.body):
                    return True
            elif isinstance(stmt, TryStatement):
                if self.has_yield(stmt.try_block):
                    return True
                if stmt.catch_block and self.has_yield(stmt.catch_block):
                    return True
                if stmt.finally_block and self.has_yield(stmt.finally_block):
                    return True
        return False

    def setup_builtins(self):
        """組み込み関数の設定"""
        def builtin_print(*args):
            print(*args)
            return None

        def builtin_input(prompt=""):
            return input(prompt)

        def builtin_len(obj):
            if isinstance(obj, (list, str, set)):
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
                dict: "dict",
                set: "set",
                type(None): "none",
                MMFunction: "function",
                MMClass: "class",
                MMInstance: "instance",
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

        # set関連の関数
        def builtin_set(iterable=None):
            """セットを作成"""
            if iterable is None:
                return set()
            return set(iterable)

        def builtin_set_add(s, item):
            """セットに要素を追加"""
            if not isinstance(s, set):
                raise TypeError("set_add() requires a set")
            s.add(item)
            return None

        def builtin_set_remove(s, item):
            """セットから要素を削除"""
            if not isinstance(s, set):
                raise TypeError("set_remove() requires a set")
            s.remove(item)
            return None

        def builtin_set_discard(s, item):
            """セットから要素を削除（存在しなくてもエラーにならない）"""
            if not isinstance(s, set):
                raise TypeError("set_discard() requires a set")
            s.discard(item)
            return None

        def builtin_set_has(s, item):
            """セットに要素が含まれているかチェック"""
            if not isinstance(s, set):
                raise TypeError("set_has() requires a set")
            return item in s

        def builtin_set_union(s1, s2):
            """2つのセットの和集合"""
            if not isinstance(s1, set) or not isinstance(s2, set):
                raise TypeError("set_union() requires two sets")
            return s1 | s2

        def builtin_set_intersection(s1, s2):
            """2つのセットの積集合"""
            if not isinstance(s1, set) or not isinstance(s2, set):
                raise TypeError("set_intersection() requires two sets")
            return s1 & s2

        def builtin_set_difference(s1, s2):
            """2つのセットの差集合"""
            if not isinstance(s1, set) or not isinstance(s2, set):
                raise TypeError("set_difference() requires two sets")
            return s1 - s2

        def builtin_set_to_list(s):
            """セットをリストに変換"""
            if not isinstance(s, set):
                raise TypeError("set_to_list() requires a set")
            return list(s)

        def builtin_property(func):
            """プロパティデコレーター"""
            if isinstance(func, MMFunction):
                func.is_property = True
                # setterメソッドを追加する機能を提供
                def setter_decorator(setter_func):
                    if isinstance(setter_func, MMFunction):
                        func.setter = setter_func
                    return func
                # プロパティオブジェクトにsetterメソッドを追加
                func.setter_decorator = setter_decorator
            return func

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

        # set（集合）関連
        self.global_env.define('set', builtin_set)
        self.global_env.define('set_add', builtin_set_add)
        self.global_env.define('set_remove', builtin_set_remove)
        self.global_env.define('set_discard', builtin_set_discard)
        self.global_env.define('set_has', builtin_set_has)
        self.global_env.define('set_union', builtin_set_union)
        self.global_env.define('set_intersection', builtin_set_intersection)
        self.global_env.define('set_difference', builtin_set_difference)
        self.global_env.define('set_to_list', builtin_set_to_list)

        # プロパティ関連
        self.global_env.define('property', builtin_property)

        # Discord機能を追加（利用可能な場合）
        if DISCORD_AVAILABLE:
            setup_discord_builtins(self.global_env)

        # 非同期機能を追加（利用可能な場合）
        if ASYNC_AVAILABLE:
            setup_async_builtins(self.global_env)

        # HTTP機能を追加
        if HTTP_AVAILABLE:
            setup_http_builtins(self.global_env)

        # ファイルI/O機能を追加
        if FILE_AVAILABLE:
            setup_file_builtins(self.global_env)

        # 標準ライブラリを追加
        if STDLIB_AVAILABLE:
            setup_stdlib_builtins(self.global_env)

        # デバッガーを追加
        if DEBUG_AVAILABLE:
            setup_debug_builtins(self.global_env)

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

        elif isinstance(node, ListComprehension):
            # リスト内包表記の評価
            iterable = self.evaluate(node.iterable)
            if not isinstance(iterable, (list, str)):
                raise TypeError("List comprehension requires an iterable")

            result = []
            for item in iterable:
                # イテレーション変数を定義
                self.current_env.define(node.variable, item)

                # 条件がある場合はチェック
                if node.condition:
                    if not self.is_truthy(self.evaluate(node.condition)):
                        continue

                # 式を評価してリストに追加
                result.append(self.evaluate(node.expression))

            return result

        elif isinstance(node, DictLiteral):
            result_dict = {}
            for key_node, value_node in node.pairs:
                key = self.evaluate(key_node)
                value = self.evaluate(value_node)
                # キーは文字列または数値のみ許可
                if isinstance(key, (str, int, float)):
                    result_dict[key] = value
                else:
                    raise TypeError(f"Dictionary key must be string or number, got {type(key).__name__}")
            return result_dict

        elif isinstance(node, DictComprehension):
            # 辞書内包表記の評価
            iterable = self.evaluate(node.iterable)
            if not isinstance(iterable, (list, str)):
                raise TypeError("Dictionary comprehension requires an iterable")

            result_dict = {}
            for item in iterable:
                # イテレーション変数を定義
                self.current_env.define(node.variable, item)

                # 条件がある場合はチェック
                if node.condition:
                    if not self.is_truthy(self.evaluate(node.condition)):
                        continue

                # キーと値を評価
                key = self.evaluate(node.key_expr)
                value = self.evaluate(node.value_expr)

                # キーは文字列または数値のみ許可
                if isinstance(key, (str, int, float)):
                    result_dict[key] = value
                else:
                    raise TypeError(f"Dictionary key must be string or number, got {type(key).__name__}")

            return result_dict

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

        elif isinstance(node, MemberAssignment):
            obj = self.evaluate(node.object)
            value = self.evaluate(node.value)
            if isinstance(obj, MMInstance):
                obj.set(node.member, value, self)
            else:
                raise TypeError(f"Cannot set member on {type(obj).__name__}")
            return None

        elif isinstance(node, MultipleAssignment):
            # 複数代入の評価
            value = self.evaluate(node.value)

            # 値がリストまたはイテラブルであることを確認
            if not isinstance(value, (list, str)):
                raise TypeError("Cannot unpack non-iterable")

            # 要素数のチェック
            if len(value) != len(node.targets):
                raise ValueError(f"Cannot unpack {len(value)} values into {len(node.targets)} variables")

            # 各変数に値を代入
            for target, val in zip(node.targets, value):
                self.current_env.define(target, val)

            return None

        elif isinstance(node, FunctionDeclaration):
            # 関数本体にyieldが含まれているかチェック
            is_generator = self.has_yield(node.body)

            func = MMFunction(
                node.name,
                node.parameters,
                node.body,
                self.current_env,
                node.variadic_param,
                node.is_async,
                is_generator
            )

            # 型アノテーションを保存
            if node.param_types:
                func.param_types = node.param_types
            if node.return_type:
                func.return_type = node.return_type

            # デコレーターを適用
            if node.decorators:
                for decorator_spec in reversed(node.decorators):  # 下から順に適用
                    if isinstance(decorator_spec, tuple):
                        dec_type = decorator_spec[0]
                        if dec_type == 'name':
                            # 通常のデコレーター
                            decorator_name = decorator_spec[1]
                            decorator = self.current_env.get(decorator_name)
                            if isinstance(decorator, MMFunction):
                                func = self.call_mm_function(decorator, [func])
                            elif callable(decorator):
                                func = decorator(func)
                            else:
                                raise TypeError(f"'{decorator_name}' is not a decorator (not callable)")
                        elif dec_type == 'call':
                            # 引数付きデコレーター @decorator(args)
                            decorator_name = decorator_spec[1]
                            decorator_args_nodes = decorator_spec[2]
                            # 引数を評価
                            decorator_args = [self.evaluate(arg) for arg in decorator_args_nodes]

                            decorator = self.current_env.get(decorator_name)
                            if isinstance(decorator, MMFunction):
                                # デコレーターファクトリーを呼び出して実際のデコレーターを取得
                                actual_decorator = self.call_mm_function(decorator, decorator_args)
                                # 実際のデコレーターを適用
                                if isinstance(actual_decorator, MMFunction):
                                    func = self.call_mm_function(actual_decorator, [func])
                                elif callable(actual_decorator):
                                    func = actual_decorator(func)
                                else:
                                    raise TypeError(f"Decorator factory '{decorator_name}' did not return a callable")
                            elif callable(decorator):
                                # Python組み込みデコレーターファクトリー
                                actual_decorator = decorator(*decorator_args)
                                func = actual_decorator(func)
                            else:
                                raise TypeError(f"'{decorator_name}' is not a decorator (not callable)")
                    else:
                        # 後方互換性のため、文字列の場合も処理
                        decorator_name = decorator_spec
                        decorator = self.current_env.get(decorator_name)
                        if isinstance(decorator, MMFunction):
                            func = self.call_mm_function(decorator, [func])
                        elif callable(decorator):
                            func = decorator(func)
                        else:
                            raise TypeError(f"'{decorator_name}' is not a decorator (not callable)")

            self.current_env.define(node.name, func)
            return None

        elif isinstance(node, FunctionCall):
            return self.evaluate_function_call(node)

        elif isinstance(node, MemberAccessFunctionCall):
            # オブジェクトのメソッド呼び出し（例: mod.func()）
            obj = self.evaluate(node.object)

            # 引数を評価
            args = [self.evaluate(arg) for arg in node.arguments]

            # Moduleオブジェクトの場合
            if hasattr(obj, 'env'):
                func = obj.env.get(node.member)
                if callable(func) and not isinstance(func, MMFunction):
                    return func(*args)
                elif isinstance(func, MMFunction):
                    # ユーザー定義関数の呼び出し
                    return self.call_mm_function(func, args)
                else:
                    raise TypeError(f"'{node.member}' is not callable")

            # MMInstanceの場合（クラスのメソッド呼び出し）
            elif isinstance(obj, MMInstance):
                method = obj.get(node.member)
                if isinstance(method, MMFunction):
                    # プロパティの場合は引数なしで呼ぶ
                    if method.is_property:
                        return self.call_mm_function(method, [], obj)
                    else:
                        return self.call_mm_function(method, args, obj)
                else:
                    raise TypeError(f"'{node.member}' is not a method")

            else:
                raise AttributeError(f"Cannot call method '{node.member}' on {type(obj).__name__}")

        elif isinstance(node, ReturnStatement):
            value = self.evaluate(node.value) if node.value else None
            raise ReturnValue(value)

        elif isinstance(node, YieldExpression):
            value = self.evaluate(node.value) if node.value else None
            raise YieldValue(value)

        elif isinstance(node, IfStatement):
            condition = self.evaluate(node.condition)
            if self.is_truthy(condition):
                return self.evaluate_block(node.then_block)

            # Check elif branches
            for elif_condition, elif_body in node.elif_branches:
                if self.is_truthy(self.evaluate(elif_condition)):
                    return self.evaluate_block(elif_body)

            # Check else block
            if node.else_block:
                return self.evaluate_block(node.else_block)
            return None

        elif isinstance(node, WhileStatement):
            result = None
            while self.is_truthy(self.evaluate(node.condition)):
                try:
                    result = self.evaluate_block(node.body)
                except BreakException:
                    break
                except ContinueException:
                    continue
            return result

        elif isinstance(node, ForStatement):
            iterable = self.evaluate(node.iterable)
            if not isinstance(iterable, (list, str, set, MMGenerator)):
                raise TypeError("for loop requires an iterable (list, string, set, or generator)")

            result = None
            for item in iterable:
                self.current_env.define(node.variable, item)
                try:
                    result = self.evaluate_block(node.body)
                except BreakException:
                    break
                except ContinueException:
                    continue
            return result

        elif isinstance(node, TryStatement):
            return self.evaluate_try_statement(node)

        elif isinstance(node, ThrowStatement):
            message = self.evaluate(node.expression)
            raise MMException(str(message))

        elif isinstance(node, ClassDeclaration):
            # クラス定義を評価
            methods = {}
            for method_node in node.methods:
                if isinstance(method_node, FunctionDeclaration):
                    func = MMFunction(
                        method_node.name,
                        method_node.parameters,
                        method_node.body,
                        self.current_env
                    )
                    methods[method_node.name] = func

            # 親クラスの取得
            parent = None
            if node.parent:
                parent = self.current_env.get(node.parent)
                if not isinstance(parent, MMClass):
                    raise TypeError(f"'{node.parent}' is not a class")

            mm_class = MMClass(node.name, methods, parent)
            self.current_env.define(node.name, mm_class)
            return None

        elif isinstance(node, EnumDeclaration):
            # 列挙型の定義
            mm_enum = MMEnum(node.name, node.values)
            self.current_env.define(node.name, mm_enum)
            return None

        elif isinstance(node, NewExpression):
            # new ClassName() でインスタンスを作成
            mm_class = self.current_env.get(node.class_name)
            if not isinstance(mm_class, MMClass):
                raise TypeError(f"'{node.class_name}' is not a class")

            instance = MMInstance(mm_class)

            # コンストラクタ（__init__メソッド）を呼び出し
            if '__init__' in mm_class.methods:
                constructor = mm_class.methods['__init__']
                args = [self.evaluate(arg) for arg in node.arguments]

                # selfを追加してコンストラクタを呼び出し
                if len(args) + 1 != len(constructor.parameters):
                    raise TypeError(
                        f"__init__() takes {len(constructor.parameters)} arguments but {len(args) + 1} were given"
                    )

                func_env = Environment(constructor.closure)
                func_env.define('self', instance)
                for param, arg in zip(constructor.parameters[1:], args):
                    func_env.define(param, arg)

                prev_env = self.current_env
                self.current_env = func_env
                try:
                    self.evaluate_block(constructor.body)
                except ReturnValue:
                    pass  # コンストラクタからのreturnは無視
                finally:
                    self.current_env = prev_env

            return instance

        elif isinstance(node, MemberAccess):
            # オブジェクトのメンバーアクセス
            obj = self.evaluate(node.object)

            if isinstance(obj, MMInstance):
                # まずメソッドを確認
                if node.member in obj.mm_class.methods:
                    method = obj.mm_class.methods[node.member]
                    # プロパティの場合は自動的にgetterを呼び出す
                    if isinstance(method, MMFunction) and method.is_property:
                        return self.call_mm_function(method, [], obj)
                    return method
                # 次にフィールドを確認
                elif node.member in obj.fields:
                    return obj.fields[node.member]
                else:
                    raise AttributeError(f"'{obj.mm_class.name}' object has no attribute '{node.member}'")
            elif isinstance(obj, MMEnum):
                # Enumの値アクセス
                if node.member in obj.values:
                    return obj.values[node.member]
                raise AttributeError(f"Enum '{obj.name}' has no value '{node.member}'")
            elif isinstance(obj, dict):
                # 辞書のキーアクセス
                if node.member in obj:
                    return obj[node.member]
                raise KeyError(f"Key '{node.member}' not found in dictionary")
            elif hasattr(obj, 'env'):
                # Moduleオブジェクト
                return obj.env.get(node.member)
            else:
                raise AttributeError(f"'{type(obj).__name__}' object has no attribute '{node.member}'")

        elif isinstance(node, IndexAccess):
            obj = self.evaluate(node.object)
            index = self.evaluate(node.index)

            if isinstance(obj, (list, str)):
                if not isinstance(index, int):
                    raise TypeError("Index must be an integer")
                return obj[index]
            elif isinstance(obj, dict):
                # 辞書のキーアクセス
                if index in obj:
                    return obj[index]
                raise KeyError(f"Key '{index}' not found in dictionary")
            else:
                raise TypeError(f"Cannot index {type(obj).__name__}")

        elif isinstance(node, SliceAccess):
            obj = self.evaluate(node.object)

            if not isinstance(obj, (list, str)):
                raise TypeError("Slicing requires a list or string")

            # スライスのstart, end, stepを評価
            start = self.evaluate(node.start) if node.start else None
            end = self.evaluate(node.end) if node.end else None
            step = self.evaluate(node.step) if node.step else None

            # 型チェック
            if start is not None and not isinstance(start, int):
                raise TypeError("Slice indices must be integers")
            if end is not None and not isinstance(end, int):
                raise TypeError("Slice indices must be integers")
            if step is not None and not isinstance(step, int):
                raise TypeError("Slice step must be an integer")

            # Pythonのスライス機能を使用
            return obj[start:end:step]

        elif isinstance(node, BreakStatement):
            raise BreakException()

        elif isinstance(node, ContinueStatement):
            raise ContinueException()

        elif isinstance(node, PassStatement):
            return None

        elif isinstance(node, AssertStatement):
            condition = self.evaluate(node.condition)
            if not self.is_truthy(condition):
                if node.message:
                    message = str(self.evaluate(node.message))
                    raise AssertionError(f"Assertion failed: {message}")
                else:
                    raise AssertionError("Assertion failed")
            return None

        elif isinstance(node, ImportStatement):
            return self.evaluate_import(node)

        elif isinstance(node, TernaryExpression):
            condition = self.evaluate(node.condition)
            if self.is_truthy(condition):
                return self.evaluate(node.true_expr)
            else:
                return self.evaluate(node.false_expr)

        elif isinstance(node, WalrusOperator):
            value = self.evaluate(node.value)
            # Check if variable exists, if not define it, otherwise set it
            if self.current_env.exists(node.name):
                self.current_env.set(node.name, value)
            else:
                self.current_env.define(node.name, value)
            return value

        elif isinstance(node, WithStatement):
            # 簡易版のwith文実装
            context_obj = self.evaluate(node.context_expr)

            # 変数に束縛する場合
            if node.variable:
                self.current_env.define(node.variable, context_obj)

            # ブロックを実行
            try:
                result = self.evaluate_block(node.body)
            finally:
                # リソースのクリーンアップ（close()メソッドがあれば呼ぶ）
                if isinstance(context_obj, MMInstance) and 'close' in context_obj.mm_class.methods:
                    close_method = context_obj.get('close')
                    if isinstance(close_method, MMFunction):
                        func_env = Environment(close_method.closure)
                        func_env.define('self', context_obj)
                        prev_env = self.current_env
                        self.current_env = func_env
                        try:
                            self.evaluate_block(close_method.body)
                        except ReturnValue:
                            pass
                        finally:
                            self.current_env = prev_env

            return result

        elif isinstance(node, MatchStatement):
            match_value = self.evaluate(node.expression)

            for pattern, body in node.cases:
                # 簡易版パターンマッチング（値の等価性のみ）
                pattern_value = self.evaluate(pattern)

                # _は全てにマッチ（デフォルトケース）
                if isinstance(pattern, Identifier) and pattern.name == '_':
                    return self.evaluate_block(body)

                # 値の等価性チェック
                if match_value == pattern_value:
                    return self.evaluate_block(body)

            return None

        elif isinstance(node, LambdaExpression):
            # ラムダ式は無名関数として扱う
            return MMFunction(
                "<lambda>",
                node.parameters,
                [ReturnStatement(node.body)],  # 式を自動的にreturn文に変換
                self.current_env,
                None,  # variadic_param
                False,  # is_async
                False   # is_generator (ラムダは単一式なのでジェネレーターになれない)
            )

        elif isinstance(node, AwaitExpression):
            # await式の評価
            task = self.evaluate(node.expression)

            # mm_asyncモジュールのAsyncTaskかチェック
            try:
                from mm_async import AsyncTask
                if isinstance(task, AsyncTask):
                    return task.wait()
            except ImportError:
                pass

            # AsyncTaskでない場合はそのまま返す（通常の値）
            return task

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

    def call_mm_function(self, func: MMFunction, args: List[Any], instance=None) -> Any:
        """MMFunction呼び出しの共通処理"""

        # 型チェック（オプショナル - 型アノテーションがある場合のみ）
        if hasattr(func, 'param_types') and func.param_types:
            type_error = global_type_checker.check_function_call(func, args, func.param_types)
            if type_error:
                print(f"Type warning: {type_error}")  # 警告のみで実行は続行

        # 可変長引数がある場合
        if func.variadic_param:
            # 通常のパラメータ数をチェック
            if len(args) < len(func.parameters):
                raise TypeError(
                    f"{func.name}() takes at least {len(func.parameters)} arguments but {len(args)} were given"
                )

            # 新しい環境を作成
            func_env = Environment(func.closure)

            # 通常のパラメータをバインド
            for param, arg in zip(func.parameters, args):
                func_env.define(param, arg)

            # 残りの引数を可変長引数としてバインド
            remaining_args = args[len(func.parameters):]
            func_env.define(func.variadic_param, remaining_args)
        else:
            # 可変長引数なし
            # インスタンスメソッドの場合、selfを除いた引数数をチェック
            expected_args = len(func.parameters)
            if instance and expected_args > 0:
                expected_args -= 1  # selfを除く

            if len(args) != expected_args:
                raise TypeError(
                    f"{func.name}() takes {expected_args} arguments but {len(args)} were given"
                )

            # 新しい環境を作成
            func_env = Environment(func.closure)

            # インスタンスメソッドの場合はselfを最初にバインド
            if instance:
                func_env.define('self', instance)
                # 残りのパラメータをバインド
                for param, arg in zip(func.parameters[1:], args):
                    func_env.define(param, arg)
            else:
                # パラメータをバインド
                for param, arg in zip(func.parameters, args):
                    func_env.define(param, arg)

        # ジェネレーター関数の場合はMMGeneratorを返す
        if func.is_generator:
            return MMGenerator(func, args, self)

        # async関数の場合はAsyncTaskを返す
        if func.is_async:
            try:
                from mm_async import AsyncTask

                # 非同期で実行する関数を定義
                def async_wrapper():
                    prev_env = self.current_env
                    self.current_env = func_env
                    try:
                        self.evaluate_block(func.body)
                        return None
                    except ReturnValue as ret:
                        return ret.value
                    finally:
                        self.current_env = prev_env

                # AsyncTaskを作成して開始
                task = AsyncTask(async_wrapper)
                task.start()
                return task
            except ImportError:
                raise RuntimeError("mm_async module is required for async functions")

        # 通常の関数実行
        prev_env = self.current_env
        self.current_env = func_env

        try:
            self.evaluate_block(func.body)
            result = None
        except ReturnValue as ret:
            result = ret.value
        finally:
            self.current_env = prev_env

        # 戻り値の型チェック
        if hasattr(func, 'return_type') and func.return_type and result is not None:
            type_error = global_type_checker.check_return_value(result, func.return_type)
            if type_error:
                print(f"Type warning: {type_error}")  # 警告のみ

        return result

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
            return self.call_mm_function(func, args)

        else:
            raise TypeError(f"'{node.name}' is not a function")

    def is_truthy(self, value: Any) -> bool:
        """真偽値判定"""
        if value is None or value is False:
            return False
        if value == 0 or value == "" or value == []:
            return False
        return True

    def evaluate_try_statement(self, node: TryStatement) -> Any:
        """try-catch-finally文の評価"""
        exception_caught = None
        result = None

        try:
            # tryブロックを実行
            result = self.evaluate_block(node.try_block)
        except MMException as e:
            # Mumei言語の例外をキャッチ
            exception_caught = e
            if node.catch_block:
                # catch変数に例外メッセージをバインド
                catch_env = Environment(self.current_env)
                catch_env.define(node.catch_variable, str(e.message))

                prev_env = self.current_env
                self.current_env = catch_env
                try:
                    result = self.evaluate_block(node.catch_block)
                finally:
                    self.current_env = prev_env
            else:
                # catchブロックがない場合は再スロー
                raise
        except Exception as e:
            # Python標準例外もキャッチ
            exception_caught = e
            if node.catch_block:
                # catch変数に例外メッセージをバインド
                catch_env = Environment(self.current_env)
                catch_env.define(node.catch_variable, str(e))

                prev_env = self.current_env
                self.current_env = catch_env
                try:
                    result = self.evaluate_block(node.catch_block)
                finally:
                    self.current_env = prev_env
            else:
                # catchブロックがない場合は再スロー
                raise
        finally:
            # finallyブロックを実行（必ず実行される）
            if node.finally_block:
                self.evaluate_block(node.finally_block)

        return result

    def evaluate_import(self, node: ImportStatement):
        """importステートメントの評価"""
        module_path = node.module_path

        # .muファイルとして扱う
        if not module_path.endswith('.mu'):
            module_path += '.mu'

        # モジュールがキャッシュされているかチェック
        if module_path in self.module_cache:
            module_env = self.module_cache[module_path]
        else:
            # モジュールファイルを読み込み
            try:
                with open(module_path, 'r', encoding='utf-8') as f:
                    module_source = f.read()
            except FileNotFoundError:
                raise Exception(f"Module '{module_path}' not found")

            # モジュール用の新しい環境を作成
            module_env = Environment(parent=self.global_env)

            # モジュールを実行
            from mm_lexer import Lexer
            from mm_parser import Parser

            lexer = Lexer(module_source)
            tokens = lexer.tokenize()

            parser = Parser(tokens)
            ast = parser.parse()

            # 現在の環境を保存
            old_env = self.current_env
            self.current_env = module_env

            try:
                self.evaluate(ast)
            finally:
                self.current_env = old_env

            # モジュールをキャッシュ
            self.module_cache[module_path] = module_env

        # モジュールの内容を現在の環境にインポート
        module_name = node.alias if node.alias else module_path.replace('.mu', '').replace('/', '_').replace('.', '_')

        # モジュールオブジェクトを作成（モジュールの変数にアクセスできるオブジェクト）
        class Module:
            def __init__(self, env):
                self.env = env

            def __getattribute__(self, name):
                # Pythonの特殊属性はそのまま返す
                if name.startswith('__') and name.endswith('__'):
                    return object.__getattribute__(self, name)
                if name == 'env':
                    return object.__getattribute__(self, 'env')
                env = object.__getattribute__(self, 'env')
                try:
                    return env.get(name)
                except NameError:
                    raise AttributeError(f"module has no attribute '{name}'")

        module_obj = Module(module_env)
        self.current_env.define(module_name, module_obj)

        return None

    def run(self, source: str):
        """ソースコードを実行"""
        from mm_lexer import Lexer
        from mm_parser import Parser

        lexer = Lexer(source)
        tokens = lexer.tokenize()

        parser = Parser(tokens)
        ast = parser.parse()

        self.evaluate(ast)
