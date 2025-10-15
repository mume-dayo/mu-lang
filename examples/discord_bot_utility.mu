# Mumei言語での実用的なDiscord Bot
# 使い方: mumei discord_bot_utility.mu
# 機能: 投票、リマインダー、クイズ、統計など

print("=== Mumei Utility Discord Bot ===");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == none) {
    print("エラー: DISCORD_TOKENが設定されていません");
    throw "Missing DISCORD_TOKEN";
}

# Botを作成
discord_create_bot("!");

# グローバル変数（簡易的なストレージ）
let polls = {};  # 投票データ
let quiz_scores = {};  # クイズスコア
let server_stats = {
    "messages": 0,
    "commands": 0
};

# ユーティリティ関数
fun create_progress_bar(current, total, length) {
    let percentage = current / total;
    let filled = int(percentage * length);
    let empty = length - filled;

    let bar = "[";
    for (i in range(0, filled)) {
        bar = bar + "█";
    }
    for (i in range(0, empty)) {
        bar = bar + "░";
    }
    bar = bar + "] " + str(int(percentage * 100)) + "%";
    bar
}

# !pollコマンド - 投票を作成
discord_command("poll", lambda(ctx, *args) {
    if (len(args) < 2) {
        return "使い方: !poll <質問> <選択肢1> <選択肢2> ...";
    }

    let question = args[0];
    let options = args[1:];

    # 投票データを初期化
    let poll_id = str(len(dict_keys(polls)));
    let poll_data = {
        "question": question,
        "options": options,
        "votes": {}
    };

    # 各選択肢の投票数を0に初期化
    for (opt in options) {
        poll_data["votes"][opt] = 0;
    }

    polls[poll_id] = poll_data;

    let result = "📊 投票開始！ (ID: " + poll_id + ")\n";
    result = result + "質問: " + question + "\n\n";
    result = result + "選択肢:\n";
    for (i in range(0, len(options))) {
        result = result + str(i + 1) + ". " + options[i] + "\n";
    }
    result = result + "\n投票するには: !vote " + poll_id + " <番号>";
    result
});

# !voteコマンド - 投票する
discord_command("vote", lambda(ctx, *args) {
    if (len(args) != 2) {
        return "使い方: !vote <投票ID> <選択肢番号>";
    }

    let poll_id = args[0];
    let choice_num = int(args[1]);

    if (not dict_has(polls, poll_id)) {
        return "エラー: 投票ID " + poll_id + " が見つかりません";
    }

    let poll = polls[poll_id];
    let options = poll["options"];

    if (choice_num < 1 or choice_num > len(options)) {
        return "エラー: 無効な選択肢番号です";
    }

    let choice = options[choice_num - 1];
    poll["votes"][choice] = poll["votes"][choice] + 1;

    "✅ 投票しました: " + choice
});

# !pollresultコマンド - 投票結果を表示
discord_command("pollresult", lambda(ctx, *args) {
    if (len(args) != 1) {
        return "使い方: !pollresult <投票ID>";
    }

    let poll_id = args[0];

    if (not dict_has(polls, poll_id)) {
        return "エラー: 投票ID " + poll_id + " が見つかりません";
    }

    let poll = polls[poll_id];
    let question = poll["question"];
    let votes = poll["votes"];

    # 総投票数を計算
    let total = 0;
    for (opt in poll["options"]) {
        total = total + votes[opt];
    }

    let result = "📊 投票結果 (ID: " + poll_id + ")\n";
    result = result + "質問: " + question + "\n";
    result = result + "総投票数: " + str(total) + "\n\n";

    for (opt in poll["options"]) {
        let count = votes[opt];
        let bar = create_progress_bar(count, total if total > 0 else 1, 10);
        result = result + opt + ": " + str(count) + "票 " + bar + "\n";
    }

    result
});

# !rollコマンド - サイコロを振る
discord_command("roll", lambda(ctx, *args) {
    let sides = 6;
    if (len(args) > 0) {
        try {
            sides = int(args[0]);
            if (sides < 2) {
                return "エラー: サイコロは2面以上必要です";
            }
        } catch (e) {
            return "エラー: 数値を指定してください";
        }
    }

    let result = random_randint(1, sides);
    "🎲 サイコロの結果: " + str(result) + " (1-" + str(sides) + ")"
});

# !flipコマンド - コイントス
discord_command("flip", lambda(ctx, *args) {
    let result = random_choice(["表", "裏"]);
    "🪙 コイントスの結果: " + result
});

# !quizコマンド - クイズ問題
discord_command("quiz", lambda(ctx, *args) {
    let questions = [
        {"q": "日本の首都は？", "a": "東京", "opts": ["東京", "大阪", "京都", "名古屋"]},
        {"q": "1 + 1 は？", "a": "2", "opts": ["1", "2", "3", "4"]},
        {"q": "地球は何番目の惑星？", "a": "3", "opts": ["1", "2", "3", "4"]}
    ];

    let idx = random_randint(0, len(questions) - 1);
    let quiz = questions[idx];

    let result = "❓ クイズ:\n" + quiz["q"] + "\n\n選択肢:\n";
    for (i in range(0, len(quiz["opts"]))) {
        result = result + str(i + 1) + ". " + quiz["opts"][i] + "\n";
    }
    result = result + "\n答えるには: !answer <番号>";
    result
});

# !statsコマンド - サーバー統計
discord_command("stats", lambda(ctx, *args) {
    let result = "📈 サーバー統計:\n";
    result = result + "メッセージ数: " + str(server_stats["messages"]) + "\n";
    result = result + "コマンド実行数: " + str(server_stats["commands"]) + "\n";
    result
});

# !reverseコマンド - 文字列を反転
discord_command("reverse", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !reverse <テキスト>";
    }

    let text = string_join(" ", args);
    let reversed = string_reverse(text);
    "🔄 反転結果: " + reversed
});

# !countコマンド - 文字数カウント
discord_command("count", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !count <テキスト>";
    }

    let text = string_join(" ", args);
    let char_count = len(text);
    let word_count = len(args);

    "📝 カウント結果:\n文字数: " + str(char_count) + "\n単語数: " + str(word_count)
});

# !chooseコマンド - ランダム選択
discord_command("choose", lambda(ctx, *args) {
    if (len(args) < 2) {
        return "使い方: !choose <選択肢1> <選択肢2> ...";
    }

    let choice = random_choice(args);
    "🎯 選択結果: " + choice
});

# !repeatコマンド - テキストを繰り返す
discord_command("repeat", lambda(ctx, *args) {
    if (len(args) < 2) {
        return "使い方: !repeat <回数> <テキスト>";
    }

    try {
        let times = int(args[0]);
        if (times < 1 or times > 10) {
            return "エラー: 回数は1-10の範囲で指定してください";
        }

        let text = string_join(" ", args[1:]);
        let result = "";
        for (i in range(0, times)) {
            result = result + text + "\n";
        }
        result
    } catch (e) {
        "エラー: 最初の引数は数値である必要があります"
    }
});

# !pingコマンド
discord_command("ping", lambda(ctx, *args) {
    server_stats["commands"] = server_stats["commands"] + 1;
    "🏓 Pong!"
});

# !helpコマンド
discord_command("help", lambda(ctx, *args) {
    let help_text = "📖 コマンド一覧:\n\n";
    help_text = help_text + "🗳️ 投票:\n";
    help_text = help_text + "  !poll <質問> <選択肢...> - 投票作成\n";
    help_text = help_text + "  !vote <ID> <番号> - 投票\n";
    help_text = help_text + "  !pollresult <ID> - 結果表示\n\n";
    help_text = help_text + "🎲 ランダム:\n";
    help_text = help_text + "  !roll [面数] - サイコロ\n";
    help_text = help_text + "  !flip - コイントス\n";
    help_text = help_text + "  !choose <選択肢...> - ランダム選択\n\n";
    help_text = help_text + "🔤 テキスト:\n";
    help_text = help_text + "  !reverse <テキスト> - 反転\n";
    help_text = help_text + "  !count <テキスト> - 文字数カウント\n";
    help_text = help_text + "  !repeat <回数> <テキスト> - 繰り返し\n\n";
    help_text = help_text + "📊 その他:\n";
    help_text = help_text + "  !stats - サーバー統計\n";
    help_text = help_text + "  !quiz - クイズ\n";
    help_text = help_text + "  !ping - 疎通確認";
    help_text
});

# イベントハンドラ
discord_on_event("ready", lambda() {
    print("✅ Utility Bot が起動しました！");
    print("!help でコマンド一覧を表示");
});

# Botを起動
print("Botを起動中...");
discord_run(token);
