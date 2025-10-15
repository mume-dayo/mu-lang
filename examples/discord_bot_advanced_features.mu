# Mumei言語での高度なDiscord Bot機能
# 使い方: mumei discord_bot_advanced_features.mu
# 機能: Embed、データ永続化、モデレーション、スケジュール

print("=== Mumei Advanced Discord Bot ===");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == none) {
    print("エラー: DISCORD_TOKENが設定されていません");
    throw "Missing DISCORD_TOKEN";
}

# Botを作成
discord_create_bot("!");

# データ保存先
let data_dir = "bot_data";
let user_data_file = path_join(data_dir, "users.json");
let reminder_file = path_join(data_dir, "reminders.json");
let banned_words_file = path_join(data_dir, "banned_words.json");

# ディレクトリ作成
if (not dir_exists(data_dir)) {
    dir_create(data_dir);
    print("データディレクトリを作成: " + data_dir);
}

# データ永続化のヘルパー関数
fun load_data(filepath, default_value) {
    if (file_exists(filepath)) {
        try {
            let content = file_read(filepath);
            return json_parse(content);
        } catch (e) {
            print("データ読み込みエラー: " + str(e));
            return default_value;
        }
    } else {
        return default_value;
    }
}

fun save_data(filepath, data) {
    try {
        let json_str = json_stringify(data);
        file_write(filepath, json_str);
        return true;
    } catch (e) {
        print("データ保存エラー: " + str(e));
        return false;
    }
}

# データロード
let user_data = load_data(user_data_file, {});
let reminders = load_data(reminder_file, []);
let banned_words = load_data(banned_words_file, ["badword1", "badword2"]);

print("データをロードしました");
print("  ユーザー数: " + str(len(dict_keys(user_data))));
print("  リマインダー数: " + str(len(reminders)));
print("  禁止ワード数: " + str(len(banned_words)));

# !statsコマンド - Embedを使った統計表示
discord_command("stats", lambda(ctx, *args) {
    let embed = discord_create_embed(
        "📊 サーバー統計",
        "現在のサーバーの統計情報",
        0x3498db  # 青色
    );

    # フィールドを追加
    embed = discord_embed_add_field(embed, "登録ユーザー数", str(len(dict_keys(user_data))), true);
    embed = discord_embed_add_field(embed, "リマインダー数", str(len(reminders)), true);
    embed = discord_embed_add_field(embed, "禁止ワード数", str(len(banned_words)), true);

    # フッターを設定
    embed = discord_embed_set_footer(embed, "Mumei Bot v1.0");

    # Embedを含む辞書を返す（discord.pyが自動的に処理）
    return {"embed": embed};
});

# !profileコマンド - ユーザープロフィール（Embed使用）
discord_command("profile", lambda(ctx, *args) {
    let user_id = str(ctx.author.id);
    let username = str(ctx.author.name);

    # ユーザーデータを取得または作成
    if (not dict_has(user_data, user_id)) {
        user_data[user_id] = {
            "name": username,
            "messages": 0,
            "commands": 0,
            "level": 1,
            "exp": 0
        };
    }

    let profile = user_data[user_id];
    profile["commands"] = profile["commands"] + 1;
    save_data(user_data_file, user_data);

    let embed = discord_create_embed(
        "👤 " + username + " のプロフィール",
        "ユーザー情報",
        0x9b59b6  # 紫色
    );

    embed = discord_embed_add_field(embed, "レベル", "Lv." + str(profile["level"]), true);
    embed = discord_embed_add_field(embed, "経験値", str(profile["exp"]) + " EXP", true);
    embed = discord_embed_add_field(embed, "メッセージ数", str(profile["messages"]) + "件", true);
    embed = discord_embed_add_field(embed, "コマンド実行数", str(profile["commands"]) + "回", true);

    embed = discord_embed_set_footer(embed, "User ID: " + user_id);

    return {"embed": embed};
});

# !levelupコマンド - レベルアップ（デモ用）
discord_command("levelup", lambda(ctx, *args) {
    let user_id = str(ctx.author.id);
    let username = str(ctx.author.name);

    if (not dict_has(user_data, user_id)) {
        return "先に !profile を実行してください";
    }

    let profile = user_data[user_id];
    profile["level"] = profile["level"] + 1;
    profile["exp"] = profile["exp"] + 100;
    save_data(user_data_file, user_data);

    let embed = discord_create_embed(
        "🎉 レベルアップ！",
        username + " さんがレベルアップしました！",
        0x2ecc71  # 緑色
    );

    embed = discord_embed_add_field(embed, "新しいレベル", "Lv." + str(profile["level"]), true);
    embed = discord_embed_add_field(embed, "経験値", str(profile["exp"]) + " EXP", true);

    return {"embed": embed};
});

# !addwordコマンド - 禁止ワード追加
discord_command("addword", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !addword <単語>";
    }

    let word = args[0];
    if (not list_contains(banned_words, word)) {
        append(banned_words, word);
        save_data(banned_words_file, banned_words);
        return "✅ 禁止ワードを追加しました: " + word;
    } else {
        return "⚠️ その単語は既に禁止リストにあります";
    }
});

# !removewordコマンド - 禁止ワード削除
discord_command("removeword", lambda(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !removeword <単語>";
    }

    let word = args[0];
    if (list_contains(banned_words, word)) {
        let new_list = [w for (w in banned_words) if (w != word)];
        banned_words = new_list;
        save_data(banned_words_file, banned_words);
        return "✅ 禁止ワードを削除しました: " + word;
    } else {
        return "⚠️ その単語は禁止リストにありません";
    }
});

# !wordsコマンド - 禁止ワード一覧
discord_command("words", lambda(ctx, *args) {
    if (len(banned_words) == 0) {
        return "禁止ワードはありません";
    }

    let embed = discord_create_embed(
        "🚫 禁止ワード一覧",
        "現在の禁止ワードリスト",
        0xe74c3c  # 赤色
    );

    let word_list = string_join(", ", banned_words);
    embed = discord_embed_add_field(embed, "単語", word_list, false);
    embed = discord_embed_set_footer(embed, "合計: " + str(len(banned_words)) + "語");

    return {"embed": embed};
});

# !remindコマンド - リマインダー追加
discord_command("remind", lambda(ctx, *args) {
    if (len(args) < 2) {
        return "使い方: !remind <秒数> <メッセージ>";
    }

    try {
        let seconds = int(args[0]);
        let message = string_join(" ", args[1:]);
        let user_id = str(ctx.author.id);

        let reminder = {
            "user_id": user_id,
            "message": message,
            "seconds": seconds,
            "timestamp": get_time()
        };

        append(reminders, reminder);
        save_data(reminder_file, reminders);

        return "⏰ " + str(seconds) + "秒後にリマインドします: " + message;
    } catch (e) {
        return "エラー: 秒数は数値で指定してください";
    }
});

# !remindersコマンド - リマインダー一覧
discord_command("reminders", lambda(ctx, *args) {
    if (len(reminders) == 0) {
        return "リマインダーはありません";
    }

    let embed = discord_create_embed(
        "⏰ リマインダー一覧",
        "設定されているリマインダー",
        0xf39c12  # オレンジ色
    );

    for (i in range(0, min(len(reminders), 5))) {
        let r = reminders[i];
        let field_name = str(i + 1) + ". " + r["message"];
        let field_value = str(r["seconds"]) + "秒後";
        embed = discord_embed_add_field(embed, field_name, field_value, false);
    }

    embed = discord_embed_set_footer(embed, "合計: " + str(len(reminders)) + "件");

    return {"embed": embed};
});

# !helpコマンド - ヘルプ（Embed使用）
discord_command("help", lambda(ctx, *args) {
    let embed = discord_create_embed(
        "📖 コマンド一覧",
        "Mumei Advanced Bot のヘルプ",
        0x3498db
    );

    embed = discord_embed_add_field(
        embed,
        "📊 統計・プロフィール",
        "!stats - サーバー統計\n!profile - 自分のプロフィール\n!levelup - レベルアップ（デモ）",
        false
    );

    embed = discord_embed_add_field(
        embed,
        "🚫 モデレーション",
        "!addword <単語> - 禁止ワード追加\n!removeword <単語> - 禁止ワード削除\n!words - 禁止ワード一覧",
        false
    );

    embed = discord_embed_add_field(
        embed,
        "⏰ リマインダー",
        "!remind <秒数> <メッセージ> - リマインダー追加\n!reminders - リマインダー一覧",
        false
    );

    embed = discord_embed_add_field(
        embed,
        "🎮 その他",
        "!serverinfo - サーバー情報\n!ping - Pong!",
        false
    );

    embed = discord_embed_set_footer(embed, "Mumei Advanced Bot | データは自動保存されます");
    embed = discord_embed_set_author(embed, "Mumei Bot");

    return {"embed": embed};
});

# !serverinfoコマンド - サーバー情報（Embed）
discord_command("serverinfo", lambda(ctx, *args) {
    let embed = discord_create_embed(
        "🏠 サーバー情報",
        "このサーバーの詳細情報",
        0x1abc9c
    );

    embed = discord_embed_add_field(embed, "サーバー名", str(ctx.guild.name), true);
    embed = discord_embed_add_field(embed, "メンバー数", str(ctx.guild.member_count) + "人", true);
    embed = discord_embed_add_field(embed, "作成日", "Discord Guild", false);

    embed = discord_embed_set_footer(embed, "Guild ID: " + str(ctx.guild.id));

    return {"embed": embed};
});

# !pingコマンド
discord_command("ping", lambda(ctx, *args) {
    "🏓 Pong!"
});

# メッセージイベント - モデレーション
discord_on_event("message", lambda(message) {
    let content = string_lower(str(message.content));

    # 禁止ワードチェック
    for (word in banned_words) {
        if (string_contains(content, string_lower(word))) {
            print("⚠️ 禁止ワード検出: " + word + " (ユーザー: " + str(message.author.name) + ")");
            # 実際のBotではメッセージを削除する処理を追加
            break;
        }
    }

    # ユーザーのメッセージ数をカウント
    let user_id = str(message.author.id);
    if (dict_has(user_data, user_id)) {
        user_data[user_id]["messages"] = user_data[user_id]["messages"] + 1;

        # 経験値加算
        user_data[user_id]["exp"] = user_data[user_id]["exp"] + 1;

        # 定期的に保存（10メッセージごと）
        if (user_data[user_id]["messages"] % 10 == 0) {
            save_data(user_data_file, user_data);
        }
    }
});

# Readyイベント
discord_on_event("ready", lambda() {
    print("✅ Advanced Bot が起動しました！");
    print("");
    print("機能:");
    print("  📊 統計・プロフィール管理");
    print("  🚫 モデレーション（禁止ワード）");
    print("  ⏰ リマインダー機能");
    print("  💾 データ永続化（JSON）");
    print("  🎨 リッチなEmbed表示");
    print("");
    print("!help でコマンド一覧を表示");
});

# Botを起動
print("Botを起動中...");
discord_run(token);
