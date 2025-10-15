"""
MM Language Type Checker
型アノテーションを検証する型チェッカー
"""

from typing import Dict, Any, Optional


class TypeChecker:
    """型チェッカー"""

    def __init__(self):
        # 型名とPython型のマッピング
        self.type_map = {
            'int': int,
            'float': float,
            'str': str,
            'string': str,
            'bool': bool,
            'list': list,
            'dict': dict,
            'set': set,
            'none': type(None),
            'any': object,  # anyは全ての型を許可
        }

    def check_type(self, value: Any, type_name: str) -> bool:
        """値が指定された型と一致するかチェック"""
        if type_name == 'any':
            return True

        if type_name not in self.type_map:
            # 未知の型は警告するがチェックをスキップ
            return True

        expected_type = self.type_map[type_name]
        return isinstance(value, expected_type)

    def check_function_call(self, func, args: list, param_types: Dict[str, str]) -> Optional[str]:
        """関数呼び出しの引数の型をチェック"""
        if not param_types:
            return None  # 型アノテーションがない場合はチェックしない

        # MMFunctionの場合
        if hasattr(func, 'parameters'):
            parameters = func.parameters
            for i, (param, arg) in enumerate(zip(parameters, args)):
                if param in param_types:
                    type_name = param_types[param]
                    if not self.check_type(arg, type_name):
                        return f"Argument '{param}' expects type '{type_name}', got {type(arg).__name__}"

        return None  # 型チェックOK

    def check_return_value(self, value: Any, return_type: str) -> Optional[str]:
        """戻り値の型をチェック"""
        if not return_type:
            return None  # 型アノテーションがない場合はチェックしない

        if not self.check_type(value, return_type):
            return f"Return value expects type '{return_type}', got {type(value).__name__}"

        return None  # 型チェックOK


# グローバルな型チェッカーインスタンス
global_type_checker = TypeChecker()
