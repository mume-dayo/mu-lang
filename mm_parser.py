"""
MM Language Parser
抽象構文木(AST)を生成するパーサー
"""

from dataclasses import dataclass
from typing import List, Optional, Any
from mm_lexer import Token, TokenType, Lexer


# AST Node Classes
@dataclass
class ASTNode:
    pass


@dataclass
class Program(ASTNode):
    statements: List[ASTNode]


@dataclass
class NumberLiteral(ASTNode):
    value: float


@dataclass
class StringLiteral(ASTNode):
    value: str


@dataclass
class BooleanLiteral(ASTNode):
    value: bool


@dataclass
class NoneLiteral(ASTNode):
    pass


@dataclass
class ListLiteral(ASTNode):
    elements: List[ASTNode]


@dataclass
class ListComprehension(ASTNode):
    expression: ASTNode  # 各要素に適用する式
    variable: str  # イテレーション変数
    iterable: ASTNode  # 反復対象
    condition: Optional[ASTNode] = None  # オプショナルなフィルター条件


@dataclass
class DictLiteral(ASTNode):
    pairs: List[tuple]  # [(key, value), ...]


@dataclass
class DictComprehension(ASTNode):
    key_expr: ASTNode  # キーの式
    value_expr: ASTNode  # 値の式
    variable: str  # イテレーション変数
    iterable: ASTNode  # 反復対象
    condition: Optional[ASTNode] = None  # オプショナルなフィルター条件


@dataclass
class Identifier(ASTNode):
    name: str


@dataclass
class BinaryOp(ASTNode):
    left: ASTNode
    operator: str
    right: ASTNode


@dataclass
class UnaryOp(ASTNode):
    operator: str
    operand: ASTNode


@dataclass
class Assignment(ASTNode):
    name: str
    value: ASTNode


@dataclass
class MultipleAssignment(ASTNode):
    targets: List[str]  # 変数名のリスト
    value: ASTNode  # 代入される値（リストまたはイテラブル）


@dataclass
class VariableDeclaration(ASTNode):
    name: str
    value: Optional[ASTNode]


@dataclass
class FunctionCall(ASTNode):
    name: str
    arguments: List[ASTNode]


@dataclass
class FunctionDeclaration(ASTNode):
    name: str
    parameters: List[str]
    body: List[ASTNode]
    is_async: bool = False
    variadic_param: Optional[str] = None  # *args のような可変長引数


@dataclass
class LambdaExpression(ASTNode):
    parameters: List[str]
    body: ASTNode  # ラムダは単一の式を返す


@dataclass
class ReturnStatement(ASTNode):
    value: Optional[ASTNode]


@dataclass
class YieldExpression(ASTNode):
    value: Optional[ASTNode]


@dataclass
class AwaitExpression(ASTNode):
    expression: ASTNode


@dataclass
class IfStatement(ASTNode):
    condition: ASTNode
    then_block: List[ASTNode]
    elif_branches: List[tuple]  # [(condition, body), ...]
    else_block: Optional[List[ASTNode]]


@dataclass
class WhileStatement(ASTNode):
    condition: ASTNode
    body: List[ASTNode]


@dataclass
class ForStatement(ASTNode):
    variable: str
    iterable: ASTNode
    body: List[ASTNode]


@dataclass
class TryStatement(ASTNode):
    try_block: List[ASTNode]
    catch_variable: Optional[str]
    catch_block: Optional[List[ASTNode]]
    finally_block: Optional[List[ASTNode]]


@dataclass
class ThrowStatement(ASTNode):
    expression: ASTNode


@dataclass
class BreakStatement(ASTNode):
    pass


@dataclass
class ContinueStatement(ASTNode):
    pass


@dataclass
class PassStatement(ASTNode):
    pass


@dataclass
class ImportStatement(ASTNode):
    module_path: str  # インポートするモジュールのパス
    alias: Optional[str] = None  # asでエイリアスを指定


@dataclass
class TernaryExpression(ASTNode):
    condition: ASTNode
    true_expr: ASTNode
    false_expr: ASTNode


@dataclass
class WalrusOperator(ASTNode):
    name: str
    value: ASTNode


@dataclass
class WithStatement(ASTNode):
    context_expr: ASTNode
    variable: Optional[str]
    body: List[ASTNode]


@dataclass
class MatchStatement(ASTNode):
    expression: ASTNode
    cases: List[tuple]  # [(pattern, body), ...]


@dataclass
class CasePattern(ASTNode):
    pattern: ASTNode
    is_default: bool = False



@dataclass
class IndexAccess(ASTNode):
    object: ASTNode
    index: ASTNode


@dataclass
class SliceAccess(ASTNode):
    object: ASTNode
    start: Optional[ASTNode]
    end: Optional[ASTNode]
    step: Optional[ASTNode]


@dataclass
class MemberAccess(ASTNode):
    object: ASTNode
    member: str


@dataclass
class ClassDeclaration(ASTNode):
    name: str
    methods: List[ASTNode]  # FunctionDeclarations
    parent: Optional[str] = None


@dataclass
class NewExpression(ASTNode):
    class_name: str
    arguments: List[ASTNode]


class Parser:
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0

    def current_token(self) -> Token:
        if self.pos >= len(self.tokens):
            return self.tokens[-1]  # EOF
        return self.tokens[self.pos]

    def peek_token(self, offset: int = 1) -> Token:
        pos = self.pos + offset
        if pos >= len(self.tokens):
            return self.tokens[-1]  # EOF
        return self.tokens[pos]

    def advance(self):
        if self.pos < len(self.tokens) - 1:
            self.pos += 1

    def expect(self, token_type: TokenType) -> Token:
        token = self.current_token()
        if token.type != token_type:
            raise SyntaxError(
                f"Expected {token_type.name}, got {token.type.name} at {token.line}:{token.column}"
            )
        self.advance()
        return token

    def skip_newlines(self):
        while self.current_token().type == TokenType.NEWLINE:
            self.advance()

    def parse(self) -> Program:
        statements = []
        self.skip_newlines()

        while self.current_token().type != TokenType.EOF:
            stmt = self.parse_statement()
            if stmt:
                statements.append(stmt)
            self.skip_newlines()

        return Program(statements)

    def parse_statement(self) -> Optional[ASTNode]:
        self.skip_newlines()
        token = self.current_token()

        if token.type == TokenType.LET:
            return self.parse_variable_declaration()
        elif token.type == TokenType.ASYNC:
            return self.parse_function_declaration(is_async=True)
        elif token.type == TokenType.FUN:
            return self.parse_function_declaration()
        elif token.type == TokenType.CLASS:
            return self.parse_class_declaration()
        elif token.type == TokenType.IF:
            return self.parse_if_statement()
        elif token.type == TokenType.WHILE:
            return self.parse_while_statement()
        elif token.type == TokenType.FOR:
            return self.parse_for_statement()
        elif token.type == TokenType.RETURN:
            return self.parse_return_statement()
        elif token.type == TokenType.YIELD:
            return self.parse_yield_expression()
        elif token.type == TokenType.BREAK:
            return self.parse_break_statement()
        elif token.type == TokenType.CONTINUE:
            return self.parse_continue_statement()
        elif token.type == TokenType.PASS:
            return self.parse_pass_statement()
        elif token.type == TokenType.TRY:
            return self.parse_try_statement()
        elif token.type == TokenType.THROW:
            return self.parse_throw_statement()
        elif token.type == TokenType.WITH:
            return self.parse_with_statement()
        elif token.type == TokenType.MATCH:
            return self.parse_match_statement()
        elif token.type == TokenType.IMPORT:
            return self.parse_import_statement()
        elif token.type == TokenType.IDENTIFIER:
            # 代入か関数呼び出し
            if self.peek_token().type == TokenType.ASSIGN:
                return self.parse_assignment()
            else:
                expr = self.parse_expression()
                self.expect_statement_end()
                return expr
        elif token.type == TokenType.SEMICOLON:
            self.advance()
            return None
        else:
            expr = self.parse_expression()
            self.expect_statement_end()
            return expr

    def expect_statement_end(self):
        token = self.current_token()
        if token.type in (TokenType.SEMICOLON, TokenType.NEWLINE):
            self.advance()
        elif token.type == TokenType.EOF:
            pass
        # ブロックの終わりの場合も許可
        elif token.type == TokenType.RBRACE:
            pass

    def parse_variable_declaration(self):
        self.expect(TokenType.LET)

        # 最初の識別子を読む
        first_name = self.expect(TokenType.IDENTIFIER).value

        # カンマがあれば複数代入
        if self.current_token().type == TokenType.COMMA:
            targets = [first_name]
            while self.current_token().type == TokenType.COMMA:
                self.advance()
                targets.append(self.expect(TokenType.IDENTIFIER).value)

            self.expect(TokenType.ASSIGN)
            value = self.parse_expression()
            self.expect_statement_end()
            return MultipleAssignment(targets, value)

        # 通常の変数宣言
        value = None
        if self.current_token().type == TokenType.ASSIGN:
            self.advance()
            value = self.parse_expression()

        self.expect_statement_end()
        return VariableDeclaration(first_name, value)

    def parse_assignment(self) -> Assignment:
        name_token = self.expect(TokenType.IDENTIFIER)
        self.expect(TokenType.ASSIGN)
        value = self.parse_expression()
        self.expect_statement_end()
        return Assignment(name_token.value, value)

    def parse_function_declaration(self, is_async: bool = False) -> FunctionDeclaration:
        # asyncキーワードがある場合はスキップ
        if is_async:
            self.expect(TokenType.ASYNC)

        self.expect(TokenType.FUN)
        name_token = self.expect(TokenType.IDENTIFIER)
        name = name_token.value

        self.expect(TokenType.LPAREN)
        parameters = []
        variadic_param = None

        if self.current_token().type != TokenType.RPAREN:
            # 最初のパラメータ
            if self.current_token().type == TokenType.MULTIPLY:
                # 可変長引数
                self.advance()
                variadic_param = self.expect(TokenType.IDENTIFIER).value
            else:
                param_token = self.expect(TokenType.IDENTIFIER)
                parameters.append(param_token.value)

            # 残りのパラメータ
            while self.current_token().type == TokenType.COMMA:
                self.advance()
                if self.current_token().type == TokenType.MULTIPLY:
                    # 可変長引数（最後のパラメータのみ）
                    self.advance()
                    variadic_param = self.expect(TokenType.IDENTIFIER).value
                    break  # 可変長引数は最後
                else:
                    param_token = self.expect(TokenType.IDENTIFIER)
                    parameters.append(param_token.value)

        self.expect(TokenType.RPAREN)

        body = self.parse_block()

        return FunctionDeclaration(name, parameters, body, is_async, variadic_param)

    def parse_class_declaration(self) -> ClassDeclaration:
        self.expect(TokenType.CLASS)
        name_token = self.expect(TokenType.IDENTIFIER)
        class_name = name_token.value

        # 継承のサポート（オプション）
        parent = None
        if self.current_token().type == TokenType.COLON:
            self.advance()
            parent_token = self.expect(TokenType.IDENTIFIER)
            parent = parent_token.value

        self.skip_newlines()
        self.expect(TokenType.LBRACE)
        self.skip_newlines()

        # メソッドをパース
        methods = []
        while self.current_token().type != TokenType.RBRACE:
            if self.current_token().type == TokenType.FUN:
                method = self.parse_function_declaration()
                methods.append(method)
            self.skip_newlines()

        self.expect(TokenType.RBRACE)
        return ClassDeclaration(class_name, methods, parent)

    def parse_return_statement(self) -> ReturnStatement:
        self.expect(TokenType.RETURN)

        value = None
        if self.current_token().type not in (TokenType.SEMICOLON, TokenType.NEWLINE, TokenType.RBRACE):
            value = self.parse_expression()

        self.expect_statement_end()
        return ReturnStatement(value)

    def parse_yield_expression(self) -> YieldExpression:
        self.expect(TokenType.YIELD)

        value = None
        if self.current_token().type not in (TokenType.SEMICOLON, TokenType.NEWLINE, TokenType.RBRACE):
            value = self.parse_expression()

        self.expect_statement_end()
        return YieldExpression(value)

    def parse_if_statement(self) -> IfStatement:
        self.expect(TokenType.IF)
        self.expect(TokenType.LPAREN)
        condition = self.parse_expression()
        self.expect(TokenType.RPAREN)

        then_block = self.parse_block()

        # elif branches
        elif_branches = []
        while self.current_token().type == TokenType.ELIF:
            self.advance()
            self.expect(TokenType.LPAREN)
            elif_condition = self.parse_expression()
            self.expect(TokenType.RPAREN)
            elif_body = self.parse_block()
            elif_branches.append((elif_condition, elif_body))

        # else block
        else_block = None
        if self.current_token().type == TokenType.ELSE:
            self.advance()
            else_block = self.parse_block()

        return IfStatement(condition, then_block, elif_branches, else_block)

    def parse_while_statement(self) -> WhileStatement:
        self.expect(TokenType.WHILE)
        self.expect(TokenType.LPAREN)
        condition = self.parse_expression()
        self.expect(TokenType.RPAREN)

        body = self.parse_block()

        return WhileStatement(condition, body)

    def parse_for_statement(self) -> ForStatement:
        self.expect(TokenType.FOR)
        self.expect(TokenType.LPAREN)
        var_token = self.expect(TokenType.IDENTIFIER)
        self.expect(TokenType.IN)
        iterable = self.parse_expression()
        self.expect(TokenType.RPAREN)

        body = self.parse_block()

        return ForStatement(var_token.value, iterable, body)

    def parse_try_statement(self) -> TryStatement:
        self.expect(TokenType.TRY)
        try_block = self.parse_block()

        catch_variable = None
        catch_block = None
        finally_block = None

        # catch節のパース
        if self.current_token().type == TokenType.CATCH:
            self.advance()
            self.expect(TokenType.LPAREN)
            catch_var_token = self.expect(TokenType.IDENTIFIER)
            catch_variable = catch_var_token.value
            self.expect(TokenType.RPAREN)
            catch_block = self.parse_block()

        # finally節のパース
        if self.current_token().type == TokenType.FINALLY:
            self.advance()
            finally_block = self.parse_block()

        # catchかfinallyのどちらかは必須
        if catch_block is None and finally_block is None:
            raise Exception("try statement must have either catch or finally block")

        return TryStatement(try_block, catch_variable, catch_block, finally_block)

    def parse_throw_statement(self) -> ThrowStatement:
        self.expect(TokenType.THROW)
        expression = self.parse_expression()
        self.expect_statement_end()
        return ThrowStatement(expression)

    def parse_block(self) -> List[ASTNode]:
        self.skip_newlines()
        self.expect(TokenType.LBRACE)
        self.skip_newlines()

        statements = []
        while self.current_token().type != TokenType.RBRACE:
            stmt = self.parse_statement()
            if stmt:
                statements.append(stmt)
            self.skip_newlines()

        self.expect(TokenType.RBRACE)
        return statements

    def parse_expression(self) -> ASTNode:
        return self.parse_ternary()

    def parse_ternary(self) -> ASTNode:
        # Parse walrus operator first
        expr = self.parse_walrus()

        # Check for ternary: expr if condition else expr
        if self.current_token().type == TokenType.IF:
            self.advance()
            condition = self.parse_walrus()
            self.expect(TokenType.ELSE)
            false_expr = self.parse_ternary()
            return TernaryExpression(condition, expr, false_expr)

        return expr

    def parse_walrus(self) -> ASTNode:
        # Check if this is an identifier followed by :=
        if self.current_token().type == TokenType.IDENTIFIER and self.peek_token().type == TokenType.WALRUS:
            name_token = self.current_token()
            self.advance()  # skip identifier
            self.advance()  # skip :=
            value = self.parse_walrus()
            return WalrusOperator(name_token.value, value)

        return self.parse_logical_or()

    def parse_logical_or(self) -> ASTNode:
        left = self.parse_logical_and()

        while self.current_token().type == TokenType.OR:
            self.advance()
            right = self.parse_logical_and()
            left = BinaryOp(left, 'or', right)

        return left

    def parse_logical_and(self) -> ASTNode:
        left = self.parse_equality()

        while self.current_token().type == TokenType.AND:
            self.advance()
            right = self.parse_equality()
            left = BinaryOp(left, 'and', right)

        return left

    def parse_equality(self) -> ASTNode:
        left = self.parse_comparison()

        while self.current_token().type in (TokenType.EQ, TokenType.NE):
            op = 'eq' if self.current_token().type == TokenType.EQ else 'ne'
            self.advance()
            right = self.parse_comparison()
            left = BinaryOp(left, op, right)

        return left

    def parse_comparison(self) -> ASTNode:
        left = self.parse_additive()

        while self.current_token().type in (TokenType.LT, TokenType.LE, TokenType.GT, TokenType.GE):
            token_type = self.current_token().type
            op_map = {
                TokenType.LT: 'lt',
                TokenType.LE: 'le',
                TokenType.GT: 'gt',
                TokenType.GE: 'ge',
            }
            op = op_map[token_type]
            self.advance()
            right = self.parse_additive()
            left = BinaryOp(left, op, right)

        return left

    def parse_additive(self) -> ASTNode:
        left = self.parse_multiplicative()

        while self.current_token().type in (TokenType.PLUS, TokenType.MINUS):
            op = 'add' if self.current_token().type == TokenType.PLUS else 'sub'
            self.advance()
            right = self.parse_multiplicative()
            left = BinaryOp(left, op, right)

        return left

    def parse_multiplicative(self) -> ASTNode:
        left = self.parse_unary()

        while self.current_token().type in (TokenType.MULTIPLY, TokenType.DIVIDE, TokenType.MODULO):
            token_type = self.current_token().type
            op_map = {
                TokenType.MULTIPLY: 'mul',
                TokenType.DIVIDE: 'div',
                TokenType.MODULO: 'mod',
            }
            op = op_map[token_type]
            self.advance()
            right = self.parse_unary()
            left = BinaryOp(left, op, right)

        return left

    def parse_unary(self) -> ASTNode:
        if self.current_token().type in (TokenType.MINUS, TokenType.NOT):
            op = 'neg' if self.current_token().type == TokenType.MINUS else 'not'
            self.advance()
            operand = self.parse_unary()
            return UnaryOp(op, operand)

        elif self.current_token().type == TokenType.AWAIT:
            self.advance()
            expression = self.parse_unary()
            return AwaitExpression(expression)

        return self.parse_postfix()

    def parse_postfix(self) -> ASTNode:
        expr = self.parse_primary()

        while True:
            if self.current_token().type == TokenType.LPAREN:
                # 関数呼び出し
                self.advance()
                arguments = []

                if self.current_token().type != TokenType.RPAREN:
                    arguments.append(self.parse_expression())

                    while self.current_token().type == TokenType.COMMA:
                        self.advance()
                        arguments.append(self.parse_expression())

                self.expect(TokenType.RPAREN)

                if isinstance(expr, Identifier):
                    expr = FunctionCall(expr.name, arguments)
                else:
                    raise SyntaxError("Invalid function call")

            elif self.current_token().type == TokenType.LBRACKET:
                # インデックスアクセスまたはスライスアクセス
                self.advance()

                # スライスかインデックスかを判断
                start = None
                end = None
                step = None

                # 最初の要素（start or index）
                if self.current_token().type != TokenType.COLON:
                    start = self.parse_expression()

                # コロンがあればスライス
                if self.current_token().type == TokenType.COLON:
                    self.advance()

                    # end
                    if self.current_token().type not in (TokenType.COLON, TokenType.RBRACKET):
                        end = self.parse_expression()

                    # step
                    if self.current_token().type == TokenType.COLON:
                        self.advance()
                        if self.current_token().type != TokenType.RBRACKET:
                            step = self.parse_expression()

                    self.expect(TokenType.RBRACKET)
                    expr = SliceAccess(expr, start, end, step)
                else:
                    # 通常のインデックスアクセス
                    self.expect(TokenType.RBRACKET)
                    expr = IndexAccess(expr, start)

            elif self.current_token().type == TokenType.DOT:
                # メンバーアクセス
                self.advance()
                member_token = self.expect(TokenType.IDENTIFIER)
                expr = MemberAccess(expr, member_token.value)

            else:
                break

        return expr

    def parse_primary(self) -> ASTNode:
        token = self.current_token()

        if token.type == TokenType.NUMBER:
            self.advance()
            return NumberLiteral(token.value)

        elif token.type == TokenType.STRING:
            self.advance()
            return StringLiteral(token.value)

        elif token.type == TokenType.TRUE:
            self.advance()
            return BooleanLiteral(True)

        elif token.type == TokenType.FALSE:
            self.advance()
            return BooleanLiteral(False)

        elif token.type == TokenType.NONE:
            self.advance()
            return NoneLiteral()

        elif token.type == TokenType.IDENTIFIER:
            self.advance()
            return Identifier(token.value)

        elif token.type == TokenType.LPAREN:
            self.advance()
            expr = self.parse_expression()
            self.expect(TokenType.RPAREN)
            return expr

        elif token.type == TokenType.LBRACKET:
            return self.parse_list_literal()

        elif token.type == TokenType.LBRACE:
            return self.parse_dict_literal()

        elif token.type == TokenType.NEW:
            return self.parse_new_expression()

        elif token.type == TokenType.LAMBDA:
            return self.parse_lambda_expression()

        else:
            raise SyntaxError(f"Unexpected token {token.type.name} at {token.line}:{token.column}")

    def parse_list_literal(self):
        self.expect(TokenType.LBRACKET)

        if self.current_token().type == TokenType.RBRACKET:
            self.advance()
            return ListLiteral([])

        # 最初の式をパース
        first_expr = self.parse_expression()

        # リスト内包表記かどうかをチェック
        if self.current_token().type == TokenType.FOR:
            self.advance()
            self.expect(TokenType.LPAREN)
            var_token = self.expect(TokenType.IDENTIFIER)
            self.expect(TokenType.IN)
            iterable = self.parse_expression()
            self.expect(TokenType.RPAREN)

            # オプショナルなif条件
            condition = None
            if self.current_token().type == TokenType.IF:
                self.advance()
                self.expect(TokenType.LPAREN)
                condition = self.parse_expression()
                self.expect(TokenType.RPAREN)

            self.expect(TokenType.RBRACKET)
            return ListComprehension(first_expr, var_token.value, iterable, condition)

        # 通常のリストリテラル
        elements = [first_expr]
        while self.current_token().type == TokenType.COMMA:
            self.advance()
            if self.current_token().type == TokenType.RBRACKET:
                break
            elements.append(self.parse_expression())

        self.expect(TokenType.RBRACKET)
        return ListLiteral(elements)

    def parse_dict_literal(self):
        self.expect(TokenType.LBRACE)

        if self.current_token().type == TokenType.RBRACE:
            self.advance()
            return DictLiteral([])

        # 最初のキーをパース
        key = self.parse_expression()
        self.expect(TokenType.COLON)
        value = self.parse_expression()

        # 辞書内包表記かどうかをチェック
        if self.current_token().type == TokenType.FOR:
            self.advance()
            self.expect(TokenType.LPAREN)
            var_token = self.expect(TokenType.IDENTIFIER)
            self.expect(TokenType.IN)
            iterable = self.parse_expression()
            self.expect(TokenType.RPAREN)

            # オプショナルなif条件
            condition = None
            if self.current_token().type == TokenType.IF:
                self.advance()
                self.expect(TokenType.LPAREN)
                condition = self.parse_expression()
                self.expect(TokenType.RPAREN)

            self.expect(TokenType.RBRACE)
            return DictComprehension(key, value, var_token.value, iterable, condition)

        # 通常の辞書リテラル
        pairs = [(key, value)]
        while self.current_token().type == TokenType.COMMA:
            self.advance()
            if self.current_token().type == TokenType.RBRACE:
                break
            key = self.parse_expression()
            self.expect(TokenType.COLON)
            value = self.parse_expression()
            pairs.append((key, value))

        self.expect(TokenType.RBRACE)
        return DictLiteral(pairs)

    def parse_new_expression(self) -> NewExpression:
        self.expect(TokenType.NEW)
        class_name_token = self.expect(TokenType.IDENTIFIER)
        class_name = class_name_token.value

        # コンストラクタ引数
        arguments = []
        if self.current_token().type == TokenType.LPAREN:
            self.advance()
            if self.current_token().type != TokenType.RPAREN:
                arguments.append(self.parse_expression())
                while self.current_token().type == TokenType.COMMA:
                    self.advance()
                    arguments.append(self.parse_expression())
            self.expect(TokenType.RPAREN)

        return NewExpression(class_name, arguments)

    def parse_break_statement(self) -> BreakStatement:
        self.expect(TokenType.BREAK)
        self.expect_statement_end()
        return BreakStatement()

    def parse_continue_statement(self) -> ContinueStatement:
        self.expect(TokenType.CONTINUE)
        self.expect_statement_end()
        return ContinueStatement()

    def parse_pass_statement(self) -> PassStatement:
        self.expect(TokenType.PASS)
        self.expect_statement_end()
        return PassStatement()

    def parse_with_statement(self) -> WithStatement:
        self.expect(TokenType.WITH)
        self.expect(TokenType.LPAREN)
        context_expr = self.parse_expression()

        variable = None
        if self.current_token().type == TokenType.AS:
            self.advance()
            var_token = self.expect(TokenType.IDENTIFIER)
            variable = var_token.value

        self.expect(TokenType.RPAREN)
        body = self.parse_block()

        return WithStatement(context_expr, variable, body)

    def parse_match_statement(self) -> MatchStatement:
        self.expect(TokenType.MATCH)
        self.expect(TokenType.LPAREN)
        expression = self.parse_expression()
        self.expect(TokenType.RPAREN)

        self.skip_newlines()
        self.expect(TokenType.LBRACE)
        self.skip_newlines()

        cases = []
        while self.current_token().type == TokenType.CASE:
            self.advance()

            # パターンをパース（簡易版）
            pattern = self.parse_expression()
            self.expect(TokenType.COLON)

            # ケースのボディをパース（次のcaseまたは}まで）
            body = []
            self.skip_newlines()
            while self.current_token().type not in (TokenType.CASE, TokenType.RBRACE):
                stmt = self.parse_statement()
                if stmt:
                    body.append(stmt)
                self.skip_newlines()

            cases.append((pattern, body))

        self.expect(TokenType.RBRACE)
        return MatchStatement(expression, cases)

    def parse_import_statement(self) -> ImportStatement:
        self.expect(TokenType.IMPORT)

        # モジュールパスを取得（文字列またはidentifier）
        module_path_token = self.current_token()
        if module_path_token.type == TokenType.STRING:
            module_path = module_path_token.value
            self.advance()
        elif module_path_token.type == TokenType.IDENTIFIER:
            module_path = module_path_token.value
            self.advance()
        else:
            raise Exception(f"Expected module path (string or identifier), got {module_path_token.type}")

        # as エイリアスのパース（オプション）
        alias = None
        if self.current_token().type == TokenType.AS:
            self.advance()
            alias_token = self.expect(TokenType.IDENTIFIER)
            alias = alias_token.value

        self.expect_statement_end()
        return ImportStatement(module_path, alias)

    def parse_lambda_expression(self) -> LambdaExpression:
        self.expect(TokenType.LAMBDA)
        self.expect(TokenType.LPAREN)

        # パラメータのパース
        parameters = []
        if self.current_token().type != TokenType.RPAREN:
            param_token = self.expect(TokenType.IDENTIFIER)
            parameters.append(param_token.value)

            while self.current_token().type == TokenType.COMMA:
                self.advance()
                param_token = self.expect(TokenType.IDENTIFIER)
                parameters.append(param_token.value)

        self.expect(TokenType.RPAREN)
        self.expect(TokenType.LBRACE)

        # ラムダ本体は単一の式
        body = self.parse_expression()

        self.expect(TokenType.RBRACE)
        return LambdaExpression(parameters, body)
