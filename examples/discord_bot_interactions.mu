# Mumei言語でのDiscord Bot - インタラクション機能
# 使い方: mumei discord_bot_interactions.mu
# 機能: ボタン、セレクトメニュー、インタラクティブなUI

print("=== Mumei Discord Bot - Interactions ==");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == none) {
    print("エラー: DISCORD_TOKENが設定されていません");
    throw "Missing DISCORD_TOKEN";
}

# Botを作成
discord_create_bot("!");

# データ保存用の変数
let user_votes = {};
let quiz_answers = {};

# 例1: シンプルなボタン
discord_command_with_view("button", lambda(ctx, *args) {
    # ボタンを作成
    let btn1 = discord_create_button("いいね", "like_btn", 1, "👍", false);
    let btn2 = discord_create_button("悪い", "dislike_btn", 4, "👎", false);
    let btn3 = discord_create_button("ヘルプ", "help_btn", 2, "❓", false);

    # Viewを作成
    let view = discord_create_view([btn1, btn2, btn3]);

    # Embedを作成
    let embed = discord_create_embed(
        "📊 フィードバック",
        "このボットの評価をお願いします",
        0x3498db
    );

    return {"embed": embed, "view": view};
});

# いいねボタンのコールバック
discord_on_interaction("like_btn", lambda(interaction) {
    let user_id = str(interaction.user.id);
    user_votes[user_id] = "like";
    return "👍 いいねありがとうございます！";
});

# 悪いボタンのコールバック
discord_on_interaction("dislike_btn", lambda(interaction) {
    let user_id = str(interaction.user.id);
    user_votes[user_id] = "dislike";
    return "👎 フィードバックありがとうございます。改善に努めます。";
});

# ヘルプボタンのコールバック
discord_on_interaction("help_btn", lambda(interaction) {
    let embed = discord_create_embed(
        "❓ ヘルプ",
        "ボタンをクリックして評価してください",
        0x2ecc71
    );
    embed = discord_embed_add_field(embed, "いいね", "良い評価をします", true);
    embed = discord_embed_add_field(embed, "悪い", "悪い評価をします", true);
    return {"embed": embed};
});

# 例2: 投票システム
discord_command_with_view("vote", lambda(ctx, *args) {
    let btn_a = discord_create_button("選択肢A", "vote_a", 1, "🅰️", false);
    let btn_b = discord_create_button("選択肢B", "vote_b", 3, "🅱️", false);
    let btn_c = discord_create_button("選択肢C", "vote_c", 2, "🅲", false);
    let btn_results = discord_create_button("結果を見る", "vote_results", 2, "📊", false);

    let view = discord_create_view([btn_a, btn_b, btn_c, btn_results]);

    let embed = discord_create_embed(
        "🗳️ 投票",
        "好きな選択肢を選んでください",
        0x9b59b6
    );

    return {"embed": embed, "view": view};
});

# 投票ボタンのコールバック
discord_on_interaction("vote_a", lambda(interaction) {
    let user_id = str(interaction.user.id);
    user_votes[user_id] = "A";
    return "✅ 選択肢Aに投票しました";
});

discord_on_interaction("vote_b", lambda(interaction) {
    let user_id = str(interaction.user.id);
    user_votes[user_id] = "B";
    return "✅ 選択肢Bに投票しました";
});

discord_on_interaction("vote_c", lambda(interaction) {
    let user_id = str(interaction.user.id);
    user_votes[user_id] = "C";
    return "✅ 選択肢Cに投票しました";
});

discord_on_interaction("vote_results", lambda(interaction) {
    # 投票結果を集計
    let count_a = 0;
    let count_b = 0;
    let count_c = 0;

    for (user_id in dict_keys(user_votes)) {
        let vote = user_votes[user_id];
        if (vote == "A") {
            count_a = count_a + 1;
        } else if (vote == "B") {
            count_b = count_b + 1;
        } else if (vote == "C") {
            count_c = count_c + 1;
        }
    }

    let total = count_a + count_b + count_c;

    let embed = discord_create_embed(
        "📊 投票結果",
        "現在の投票状況",
        0xf39c12
    );

    embed = discord_embed_add_field(embed, "選択肢A", str(count_a) + "票", true);
    embed = discord_embed_add_field(embed, "選択肢B", str(count_b) + "票", true);
    embed = discord_embed_add_field(embed, "選択肢C", str(count_c) + "票", true);
    embed = discord_embed_set_footer(embed, "合計: " + str(total) + "票");

    return {"embed": embed};
});

# 例3: セレクトメニュー
discord_command_with_view("menu", lambda(ctx, *args) {
    # セレクトメニューのオプション
    let options = [
        {"label": "Python", "value": "python", "description": "Pythonを選択", "emoji": "🐍"},
        {"label": "JavaScript", "value": "javascript", "description": "JavaScriptを選択", "emoji": "📜"},
        {"label": "Rust", "value": "rust", "description": "Rustを選択", "emoji": "🦀"},
        {"label": "Go", "value": "go", "description": "Goを選択", "emoji": "🐹"},
        {"label": "Mumei", "value": "mumei", "description": "Mumei言語を選択", "emoji": "🎯"}
    ];

    let select = discord_create_select("lang_select", options, "プログラミング言語を選択...", 1, 1);
    let view = discord_create_view([select]);

    let embed = discord_create_embed(
        "💻 プログラミング言語選択",
        "好きなプログラミング言語を選んでください",
        0x1abc9c
    );

    return {"embed": embed, "view": view};
});

# セレクトメニューのコールバック
discord_on_interaction("lang_select", lambda(interaction, values) {
    let selected = values[0];
    let user_id = str(interaction.user.id);

    # 選択を保存
    if (not dict_has(user_votes, user_id)) {
        user_votes[user_id] = {};
    }
    user_votes[user_id]["language"] = selected;

    # 選択に応じたメッセージ
    let message = "";
    if (selected == "python") {
        message = "🐍 Pythonを選びました！動的型付けで柔軟な開発が可能です。";
    } else if (selected == "javascript") {
        message = "📜 JavaScriptを選びました！Web開発の標準言語です。";
    } else if (selected == "rust") {
        message = "🦀 Rustを選びました！安全で高速なシステムプログラミング言語です。";
    } else if (selected == "go") {
        message = "🐹 Goを選びました！シンプルで並行処理が得意です。";
    } else if (selected == "mumei") {
        message = "🎯 Mumei言語を選びました！このBotで使われている言語です！";
    }

    let embed = discord_create_embed(
        "✅ 選択完了",
        message,
        0x2ecc71
    );

    return {"embed": embed};
});

# 例4: クイズシステム
discord_command_with_view("quiz", lambda(ctx, *args) {
    let btn_1 = discord_create_button("1. Python", "quiz_1", 1);
    let btn_2 = discord_create_button("2. Java", "quiz_2", 1);
    let btn_3 = discord_create_button("3. C++", "quiz_3", 1);
    let btn_4 = discord_create_button("4. Ruby", "quiz_4", 1);

    let view = discord_create_view([btn_1, btn_2, btn_3, btn_4]);

    let embed = discord_create_embed(
        "❓ プログラミングクイズ",
        "このBotで使われているMumei言語は何言語ベースで作られている？",
        0xe74c3c
    );

    return {"embed": embed, "view": view};
});

discord_on_interaction("quiz_1", lambda(interaction) {
    let embed = discord_create_embed(
        "🎉 正解！",
        "Mumei言語はPythonベースで実装されています！",
        0x2ecc71
    );
    return {"embed": embed};
});

discord_on_interaction("quiz_2", lambda(interaction) {
    return "❌ 不正解です。もう一度考えてみてください。";
});

discord_on_interaction("quiz_3", lambda(interaction) {
    return "❌ 不正解です。もう一度考えてみてください。";
});

discord_on_interaction("quiz_4", lambda(interaction) {
    return "❌ 不正解です。もう一度考えてみてください。";
});

# 例5: 確認ダイアログ
discord_command_with_view("confirm", lambda(ctx, *args) {
    let btn_yes = discord_create_button("はい", "confirm_yes", 3, "✅", false);
    let btn_no = discord_create_button("いいえ", "confirm_no", 4, "❌", false);

    let view = discord_create_view([btn_yes, btn_no]);

    let embed = discord_create_embed(
        "⚠️ 確認",
        "この操作を実行してもよろしいですか？",
        0xf39c12
    );

    return {"embed": embed, "view": view};
});

discord_on_interaction("confirm_yes", lambda(interaction) {
    let embed = discord_create_embed(
        "✅ 実行完了",
        "操作が正常に実行されました",
        0x2ecc71
    );
    return {"embed": embed};
});

discord_on_interaction("confirm_no", lambda(interaction) {
    let embed = discord_create_embed(
        "❌ キャンセル",
        "操作がキャンセルされました",
        0xe74c3c
    );
    return {"embed": embed};
});

# 例6: ステータス切り替え
discord_command_with_view("status", lambda(ctx, *args) {
    let btn_online = discord_create_button("オンライン", "status_online", 3, "🟢", false);
    let btn_away = discord_create_button("離席中", "status_away", 2, "🟡", false);
    let btn_busy = discord_create_button("取り込み中", "status_busy", 4, "🔴", false);

    let view = discord_create_view([btn_online, btn_away, btn_busy]);

    let embed = discord_create_embed(
        "📊 ステータス設定",
        "現在のステータスを選択してください",
        0x3498db
    );

    return {"embed": embed, "view": view};
});

discord_on_interaction("status_online", lambda(interaction) {
    let user_id = str(interaction.user.id);
    if (not dict_has(user_votes, user_id)) {
        user_votes[user_id] = {};
    }
    user_votes[user_id]["status"] = "online";
    return "🟢 ステータスを「オンライン」に設定しました";
});

discord_on_interaction("status_away", lambda(interaction) {
    let user_id = str(interaction.user.id);
    if (not dict_has(user_votes, user_id)) {
        user_votes[user_id] = {};
    }
    user_votes[user_id]["status"] = "away";
    return "🟡 ステータスを「離席中」に設定しました";
});

discord_on_interaction("status_busy", lambda(interaction) {
    let user_id = str(interaction.user.id);
    if (not dict_has(user_votes, user_id)) {
        user_votes[user_id] = {};
    }
    user_votes[user_id]["status"] = "busy";
    return "🔴 ステータスを「取り込み中」に設定しました";
});

# !helpコマンド
discord_command("help", lambda(ctx, *args) {
    let embed = discord_create_embed(
        "📖 インタラクション機能デモ",
        "Mumei Bot のインタラクティブ機能",
        0x3498db
    );

    embed = discord_embed_add_field(
        embed,
        "🔘 ボタン",
        "!button - フィードバックボタン\n!vote - 投票システム\n!quiz - クイズ\n!confirm - 確認ダイアログ\n!status - ステータス設定",
        false
    );

    embed = discord_embed_add_field(
        embed,
        "📋 セレクトメニュー",
        "!menu - プログラミング言語選択",
        false
    );

    embed = discord_embed_set_footer(embed, "Mumei Bot | インタラクション機能");

    return {"embed": embed};
});

# !pingコマンド
discord_command("ping", lambda(ctx, *args) {
    "🏓 Pong! インタラクション機能が有効です"
});

# Readyイベント
discord_on_event("ready", lambda() {
    print("✅ Interaction Bot が起動しました！");
    print("");
    print("機能:");
    print("  🔘 ボタンインタラクション");
    print("  📋 セレクトメニュー");
    print("  🗳️ 投票システム");
    print("  ❓ クイズシステム");
    print("  ⚠️ 確認ダイアログ");
    print("  📊 ステータス管理");
    print("");
    print("!help でコマンド一覧を表示");
});

# Botを起動
print("Botを起動中...");
discord_run(token);
