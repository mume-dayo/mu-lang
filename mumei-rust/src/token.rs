/// トークンの種類
#[derive(Debug, Clone, PartialEq)]
pub enum TokenType {
    // リテラル
    Number,
    String,
    True,
    False,
    Null,

    // 識別子とキーワード
    Identifier,
    Let,
    Const,
    Fun,
    AsyncFun,
    Return,
    Yield,
    If,
    Elif,
    Else,
    While,
    For,
    In,
    Break,
    Continue,
    Pass,
    Try,
    Catch,
    Finally,
    Throw,
    Import,
    From,
    As,
    Class,
    Extends,
    New,
    This,
    Super,
    Static,
    Match,
    Case,
    Default,
    With,
    Await,
    Assert,
    Enum,
    Property,

    // 演算子
    Plus,           // +
    Minus,          // -
    Star,           // *
    Slash,          // /
    Percent,        // %
    Power,          // **
    FloorDiv,       // //

    Equal,          // ==
    NotEqual,       // !=
    Less,           // <
    Greater,        // >
    LessEqual,      // <=
    GreaterEqual,   // >=

    And,            // and
    Or,             // or
    Not,            // not

    BitwiseAnd,     // &
    BitwiseOr,      // |
    BitwiseXor,     // ^
    BitwiseNot,     // ~
    LeftShift,      // <<
    RightShift,     // >>

    // 代入
    Assign,         // =
    PlusAssign,     // +=
    MinusAssign,    // -=
    StarAssign,     // *=
    SlashAssign,    // /=
    PercentAssign,  // %=
    PowerAssign,    // **=
    FloorDivAssign, // //=
    Walrus,         // :=

    // 区切り文字
    LeftParen,      // (
    RightParen,     // )
    LeftBrace,      // {
    RightBrace,     // }
    LeftBracket,    // [
    RightBracket,   // ]
    Comma,          // ,
    Dot,            // .
    Colon,          // :
    Semicolon,      // ;
    Arrow,          // ->
    FatArrow,       // =>
    Question,       // ?
    At,             // @

    // 特殊
    Newline,
    Indent,
    Dedent,
    Eof,
}

/// トークン
#[derive(Debug, Clone)]
pub struct Token {
    pub token_type: TokenType,
    pub lexeme: String,
    pub line: usize,
    pub column: usize,
}

impl Token {
    pub fn new(token_type: TokenType, lexeme: String, line: usize, column: usize) -> Self {
        Token {
            token_type,
            lexeme,
            line,
            column,
        }
    }
}

/// キーワードをトークンタイプに変換
pub fn keyword_to_token_type(keyword: &str) -> Option<TokenType> {
    match keyword {
        "let" => Some(TokenType::Let),
        "const" => Some(TokenType::Const),
        "fun" => Some(TokenType::Fun),
        "async" => Some(TokenType::AsyncFun),
        "return" => Some(TokenType::Return),
        "yield" => Some(TokenType::Yield),
        "if" => Some(TokenType::If),
        "elif" => Some(TokenType::Elif),
        "else" => Some(TokenType::Else),
        "while" => Some(TokenType::While),
        "for" => Some(TokenType::For),
        "in" => Some(TokenType::In),
        "break" => Some(TokenType::Break),
        "continue" => Some(TokenType::Continue),
        "pass" => Some(TokenType::Pass),
        "try" => Some(TokenType::Try),
        "catch" => Some(TokenType::Catch),
        "finally" => Some(TokenType::Finally),
        "throw" => Some(TokenType::Throw),
        "import" => Some(TokenType::Import),
        "from" => Some(TokenType::From),
        "as" => Some(TokenType::As),
        "class" => Some(TokenType::Class),
        "extends" => Some(TokenType::Extends),
        "new" => Some(TokenType::New),
        "this" => Some(TokenType::This),
        "super" => Some(TokenType::Super),
        "static" => Some(TokenType::Static),
        "match" => Some(TokenType::Match),
        "case" => Some(TokenType::Case),
        "default" => Some(TokenType::Default),
        "with" => Some(TokenType::With),
        "await" => Some(TokenType::Await),
        "true" => Some(TokenType::True),
        "false" => Some(TokenType::False),
        "null" => Some(TokenType::Null),
        "and" => Some(TokenType::And),
        "or" => Some(TokenType::Or),
        "not" => Some(TokenType::Not),
        "assert" => Some(TokenType::Assert),
        "enum" => Some(TokenType::Enum),
        "property" => Some(TokenType::Property),
        _ => None,
    }
}
