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


@dataclass
class ReturnStatement(ASTNode):
    value: Optional[ASTNode]


@dataclass
class AwaitExpression(ASTNode):
    expression: ASTNode


@dataclass
class IfStatement(ASTNode):
    condition: ASTNode
    then_block: List[ASTNode]
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
class IndexAccess(ASTNode):
    object: ASTNode
    index: ASTNode


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
        elif token.type == TokenType.FUN:
            return self.parse_function_declaration()
        elif token.type == TokenType.IF:
            return self.parse_if_statement()
        elif token.type == TokenType.WHILE:
            return self.parse_while_statement()
        elif token.type == TokenType.FOR:
            return self.parse_for_statement()
        elif token.type == TokenType.RETURN:
            return self.parse_return_statement()
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

    def parse_variable_declaration(self) -> VariableDeclaration:
        self.expect(TokenType.LET)
        name_token = self.expect(TokenType.IDENTIFIER)
        name = name_token.value

        value = None
        if self.current_token().type == TokenType.ASSIGN:
            self.advance()
            value = self.parse_expression()

        self.expect_statement_end()
        return VariableDeclaration(name, value)

    def parse_assignment(self) -> Assignment:
        name_token = self.expect(TokenType.IDENTIFIER)
        self.expect(TokenType.ASSIGN)
        value = self.parse_expression()
        self.expect_statement_end()
        return Assignment(name_token.value, value)

    def parse_function_declaration(self) -> FunctionDeclaration:
        self.expect(TokenType.FUN)
        name_token = self.expect(TokenType.IDENTIFIER)
        name = name_token.value

        self.expect(TokenType.LPAREN)
        parameters = []

        if self.current_token().type != TokenType.RPAREN:
            param_token = self.expect(TokenType.IDENTIFIER)
            parameters.append(param_token.value)

            while self.current_token().type == TokenType.COMMA:
                self.advance()
                param_token = self.expect(TokenType.IDENTIFIER)
                parameters.append(param_token.value)

        self.expect(TokenType.RPAREN)

        body = self.parse_block()

        return FunctionDeclaration(name, parameters, body)

    def parse_return_statement(self) -> ReturnStatement:
        self.expect(TokenType.RETURN)

        value = None
        if self.current_token().type not in (TokenType.SEMICOLON, TokenType.NEWLINE, TokenType.RBRACE):
            value = self.parse_expression()

        self.expect_statement_end()
        return ReturnStatement(value)

    def parse_if_statement(self) -> IfStatement:
        self.expect(TokenType.IF)
        self.expect(TokenType.LPAREN)
        condition = self.parse_expression()
        self.expect(TokenType.RPAREN)

        then_block = self.parse_block()

        else_block = None
        if self.current_token().type == TokenType.ELSE:
            self.advance()
            else_block = self.parse_block()

        return IfStatement(condition, then_block, else_block)

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
                # インデックスアクセス
                self.advance()
                index = self.parse_expression()
                self.expect(TokenType.RBRACKET)
                expr = IndexAccess(expr, index)

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

        else:
            raise SyntaxError(f"Unexpected token {token.type.name} at {token.line}:{token.column}")

    def parse_list_literal(self) -> ListLiteral:
        self.expect(TokenType.LBRACKET)
        elements = []

        if self.current_token().type != TokenType.RBRACKET:
            elements.append(self.parse_expression())

            while self.current_token().type == TokenType.COMMA:
                self.advance()
                if self.current_token().type == TokenType.RBRACKET:
                    break
                elements.append(self.parse_expression())

        self.expect(TokenType.RBRACKET)
        return ListLiteral(elements)
