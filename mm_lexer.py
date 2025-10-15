"""
MM Language Lexer (Tokenizer)
トークンに分割するレキサー
"""

import re
from enum import Enum, auto
from dataclasses import dataclass
from typing import List, Optional


class TokenType(Enum):
    # リテラル
    NUMBER = auto()
    STRING = auto()
    TRUE = auto()
    FALSE = auto()
    NONE = auto()

    # 識別子
    IDENTIFIER = auto()

    # キーワード
    LET = auto()
    FUN = auto()
    LAMBDA = auto()
    IF = auto()
    ELIF = auto()
    ELSE = auto()
    WHILE = auto()
    FOR = auto()
    IN = auto()
    RETURN = auto()
    BREAK = auto()
    CONTINUE = auto()
    PASS = auto()
    ASYNC = auto()
    AWAIT = auto()
    YIELD = auto()
    TRY = auto()
    CATCH = auto()
    FINALLY = auto()
    THROW = auto()
    CLASS = auto()
    NEW = auto()
    WITH = auto()
    AS = auto()
    MATCH = auto()
    CASE = auto()

    # 演算子
    PLUS = auto()
    MINUS = auto()
    MULTIPLY = auto()
    DIVIDE = auto()
    MODULO = auto()
    ASSIGN = auto()
    WALRUS = auto()  # :=
    EQ = auto()
    NE = auto()
    LT = auto()
    LE = auto()
    GT = auto()
    GE = auto()
    AND = auto()
    OR = auto()
    NOT = auto()

    # デリミタ
    LPAREN = auto()
    RPAREN = auto()
    LBRACE = auto()
    RBRACE = auto()
    LBRACKET = auto()
    RBRACKET = auto()
    COMMA = auto()
    SEMICOLON = auto()
    COLON = auto()
    DOT = auto()

    # その他
    EOF = auto()
    NEWLINE = auto()


@dataclass
class Token:
    type: TokenType
    value: any
    line: int
    column: int

    def __repr__(self):
        return f"Token({self.type.name}, {self.value!r}, {self.line}:{self.column})"


class Lexer:
    def __init__(self, source: str):
        self.source = source
        self.pos = 0
        self.line = 1
        self.column = 1
        self.tokens: List[Token] = []

        # キーワード
        self.keywords = {
            'let': TokenType.LET,
            'fun': TokenType.FUN,
            'lambda': TokenType.LAMBDA,
            'if': TokenType.IF,
            'elif': TokenType.ELIF,
            'else': TokenType.ELSE,
            'while': TokenType.WHILE,
            'for': TokenType.FOR,
            'in': TokenType.IN,
            'return': TokenType.RETURN,
            'break': TokenType.BREAK,
            'continue': TokenType.CONTINUE,
            'pass': TokenType.PASS,
            'async': TokenType.ASYNC,
            'await': TokenType.AWAIT,
            'yield': TokenType.YIELD,
            'try': TokenType.TRY,
            'catch': TokenType.CATCH,
            'finally': TokenType.FINALLY,
            'throw': TokenType.THROW,
            'class': TokenType.CLASS,
            'new': TokenType.NEW,
            'with': TokenType.WITH,
            'as': TokenType.AS,
            'match': TokenType.MATCH,
            'case': TokenType.CASE,
            'true': TokenType.TRUE,
            'false': TokenType.FALSE,
            'none': TokenType.NONE,
            'and': TokenType.AND,
            'or': TokenType.OR,
            'not': TokenType.NOT,
        }

    def current_char(self) -> Optional[str]:
        if self.pos >= len(self.source):
            return None
        return self.source[self.pos]

    def peek_char(self, offset: int = 1) -> Optional[str]:
        pos = self.pos + offset
        if pos >= len(self.source):
            return None
        return self.source[pos]

    def advance(self):
        if self.pos < len(self.source):
            if self.source[self.pos] == '\n':
                self.line += 1
                self.column = 1
            else:
                self.column += 1
            self.pos += 1

    def skip_whitespace(self):
        while self.current_char() and self.current_char() in ' \t\r':
            self.advance()

    def skip_comment(self):
        # 単一行コメント: # または //
        if self.current_char() == '#':
            while self.current_char() and self.current_char() != '\n':
                self.advance()
        elif self.current_char() == '/' and self.peek_char() == '/':
            while self.current_char() and self.current_char() != '\n':
                self.advance()

    def read_number(self) -> Token:
        start_line = self.line
        start_column = self.column
        num_str = ''

        while self.current_char() and (self.current_char().isdigit() or self.current_char() == '.'):
            num_str += self.current_char()
            self.advance()

        if '.' in num_str:
            return Token(TokenType.NUMBER, float(num_str), start_line, start_column)
        else:
            return Token(TokenType.NUMBER, int(num_str), start_line, start_column)

    def read_string(self) -> Token:
        start_line = self.line
        start_column = self.column
        quote = self.current_char()
        self.advance()  # 開始クォートをスキップ

        string_val = ''
        while self.current_char() and self.current_char() != quote:
            if self.current_char() == '\\':
                self.advance()
                if self.current_char() == 'n':
                    string_val += '\n'
                elif self.current_char() == 't':
                    string_val += '\t'
                elif self.current_char() == '\\':
                    string_val += '\\'
                elif self.current_char() == quote:
                    string_val += quote
                else:
                    string_val += self.current_char()
                self.advance()
            else:
                string_val += self.current_char()
                self.advance()

        if self.current_char() == quote:
            self.advance()  # 終了クォートをスキップ
        else:
            raise SyntaxError(f"Unterminated string at {start_line}:{start_column}")

        return Token(TokenType.STRING, string_val, start_line, start_column)

    def read_identifier(self) -> Token:
        start_line = self.line
        start_column = self.column
        identifier = ''

        while self.current_char() and (self.current_char().isalnum() or self.current_char() == '_'):
            identifier += self.current_char()
            self.advance()

        token_type = self.keywords.get(identifier, TokenType.IDENTIFIER)
        value = identifier if token_type == TokenType.IDENTIFIER else None

        return Token(token_type, value, start_line, start_column)

    def tokenize(self) -> List[Token]:
        while self.current_char():
            self.skip_whitespace()

            if not self.current_char():
                break

            # コメント
            if self.current_char() == '#' or (self.current_char() == '/' and self.peek_char() == '/'):
                self.skip_comment()
                continue

            # 改行
            if self.current_char() == '\n':
                line = self.line
                col = self.column
                self.advance()
                self.tokens.append(Token(TokenType.NEWLINE, None, line, col))
                continue

            # 数値
            if self.current_char().isdigit():
                self.tokens.append(self.read_number())
                continue

            # 文字列
            if self.current_char() in '"\'':
                self.tokens.append(self.read_string())
                continue

            # 識別子・キーワード
            if self.current_char().isalpha() or self.current_char() == '_':
                self.tokens.append(self.read_identifier())
                continue

            # 演算子とデリミタ
            line = self.line
            col = self.column
            char = self.current_char()

            if char == '+':
                self.advance()
                self.tokens.append(Token(TokenType.PLUS, None, line, col))
            elif char == '-':
                self.advance()
                self.tokens.append(Token(TokenType.MINUS, None, line, col))
            elif char == '*':
                self.advance()
                self.tokens.append(Token(TokenType.MULTIPLY, None, line, col))
            elif char == '/':
                self.advance()
                self.tokens.append(Token(TokenType.DIVIDE, None, line, col))
            elif char == '%':
                self.advance()
                self.tokens.append(Token(TokenType.MODULO, None, line, col))
            elif char == '=':
                self.advance()
                if self.current_char() == '=':
                    self.advance()
                    self.tokens.append(Token(TokenType.EQ, None, line, col))
                else:
                    self.tokens.append(Token(TokenType.ASSIGN, None, line, col))
            elif char == '!':
                self.advance()
                if self.current_char() == '=':
                    self.advance()
                    self.tokens.append(Token(TokenType.NE, None, line, col))
                else:
                    raise SyntaxError(f"Unexpected character '!' at {line}:{col}")
            elif char == '<':
                self.advance()
                if self.current_char() == '=':
                    self.advance()
                    self.tokens.append(Token(TokenType.LE, None, line, col))
                else:
                    self.tokens.append(Token(TokenType.LT, None, line, col))
            elif char == '>':
                self.advance()
                if self.current_char() == '=':
                    self.advance()
                    self.tokens.append(Token(TokenType.GE, None, line, col))
                else:
                    self.tokens.append(Token(TokenType.GT, None, line, col))
            elif char == '(':
                self.advance()
                self.tokens.append(Token(TokenType.LPAREN, None, line, col))
            elif char == ')':
                self.advance()
                self.tokens.append(Token(TokenType.RPAREN, None, line, col))
            elif char == '{':
                self.advance()
                self.tokens.append(Token(TokenType.LBRACE, None, line, col))
            elif char == '}':
                self.advance()
                self.tokens.append(Token(TokenType.RBRACE, None, line, col))
            elif char == '[':
                self.advance()
                self.tokens.append(Token(TokenType.LBRACKET, None, line, col))
            elif char == ']':
                self.advance()
                self.tokens.append(Token(TokenType.RBRACKET, None, line, col))
            elif char == ',':
                self.advance()
                self.tokens.append(Token(TokenType.COMMA, None, line, col))
            elif char == ';':
                self.advance()
                self.tokens.append(Token(TokenType.SEMICOLON, None, line, col))
            elif char == ':':
                self.advance()
                if self.current_char() == '=':
                    self.advance()
                    self.tokens.append(Token(TokenType.WALRUS, None, line, col))
                else:
                    self.tokens.append(Token(TokenType.COLON, None, line, col))
            elif char == '.':
                self.advance()
                self.tokens.append(Token(TokenType.DOT, None, line, col))
            else:
                raise SyntaxError(f"Unexpected character '{char}' at {line}:{col}")

        self.tokens.append(Token(TokenType.EOF, None, self.line, self.column))
        return self.tokens
