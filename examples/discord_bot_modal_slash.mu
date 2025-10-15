# Mumei言語でのDiscord Bot - ModalとSlashコマンド
# 使い方: mumei discord_bot_modal_slash.mu
# 機能: Modalダイアログ、スラッシュコマンド

print("=== Mumei Discord Bot - Modal & Slash Commands ==");
print("");

# 環境変数からトークンを取得
let token = env("DISCORD_TOKEN");

if (token == none) {
    print("エラー: DISCORD_TOKENが設定されていません");
    throw "Missing DISCORD_TOKEN";
}

# Botを作成
discord_create_bot("!");

# 例1: Modalダイアログを使ったフィードバックフォーム
print("機能1: フィードバックModal");

# Modalを開くボタンを作成
discord_on_interaction("feedback_button", lambda(interaction) {
    # テキスト入力フィールドを作成
    let name_input = discord_create_text_input("お名前", "feedback_name", "short", true, "名前を入力", 50);
    let email_input = discord_create_text_input("メールアドレス", "feedback_email", "short", false, "example@example.com", 100);
    let feedback_input = discord_create_text_input("フィードバック", "feedback_text", "paragraph", true, "ご意見をお聞かせください", 1000);

    # Modalを作成
    let modal = discord_create_modal("フィードバックフォーム", "feedback_modal", [name_input, email_input, feedback_input]);

    # Modalを表示
    discord_show_modal(interaction, modal);
    return none;
});

# Modal送信のコールバック
discord_on_modal_submit("feedback_modal", lambda(interaction, values) {
    let name = dict_get(values, "feedback_name");
    let email = dict_get(values, "feedback_email");
    let feedback = dict_get(values, "feedback_text");

    # Embedで結果を表示
    let embed = discord_create_embed(
        "✅ フィードバック受信",
        "ご意見ありがとうございます！",
        0x2ecc71
    );

    embed = discord_embed_add_field(embed, "お名前", name, true);
    if (email != none and email != "") {
        embed = discord_embed_add_field(embed, "メール", email, true);
    }
    embed = discord_embed_add_field(embed, "フィードバック", feedback, false);

    return {"embed": embed};
});

# フィードバックボタンを含むコマンド
discord_command_with_view("feedback", lambda(ctx, *args) {
    let button = discord_create_button("フィードバックを送信", "feedback_button", 3, "📝", false);
    let view = discord_create_view([button]);

    let embed = discord_create_embed(
        "📝 フィードバック",
        "ボタンを押してフィードバックを送信してください",
        0x3498db
    );

    return {"embed": embed, "view": view};
});

# 例2: 問い合わせフォームModal
print("機能2: 問い合わせModal");

discord_on_interaction("inquiry_button", lambda(interaction) {
    let subject_input = discord_create_text_input("件名", "inquiry_subject", "short", true, "問い合わせ内容", 100);
    let category_input = discord_create_text_input("カテゴリ", "inquiry_category", "short", true, "バグ/要望/質問", 20);
    let details_input = discord_create_text_input("詳細", "inquiry_details", "paragraph", true, "詳しく教えてください", 2000);

    let modal = discord_create_modal("問い合わせフォーム", "inquiry_modal", [subject_input, category_input, details_input]);

    discord_show_modal(interaction, modal);
    return none;
});

discord_on_modal_submit("inquiry_modal", lambda(interaction, values) {
    let subject = dict_get(values, "inquiry_subject");
    let category = dict_get(values, "inquiry_category");
    let details = dict_get(values, "inquiry_details");

    let embed = discord_create_embed(
        "📬 問い合わせ受付",
        "お問い合わせありがとうございます",
        0x9b59b6
    );

    embed = discord_embed_add_field(embed, "件名", subject, false);
    embed = discord_embed_add_field(embed, "カテゴリ", category, true);
    embed = discord_embed_add_field(embed, "詳細", details, false);
    embed = discord_embed_set_footer(embed, "担当者が確認次第ご連絡いたします");

    return {"embed": embed};
});

discord_command_with_view("inquiry", lambda(ctx, *args) {
    let button = discord_create_button("問い合わせる", "inquiry_button", 1, "📬", false);
    let view = discord_create_view([button]);

    return {"content": "問い合わせボタンをクリックしてください", "view": view};
});

# 例3: スラッシュコマンド - /ping
print("機能3: スラッシュコマンド");

discord_create_slash_command("ping", "Botの応答速度をチェック", lambda(interaction) {
    let embed = discord_create_embed(
        "🏓 Pong!",
        "Botは正常に動作しています",
        0x2ecc71
    );

    return {"embed": embed};
});

# 例4: スラッシュコマンド - /info
discord_create_slash_command("info", "Botの情報を表示", lambda(interaction) {
    let embed = discord_create_embed(
        "ℹ️ Bot情報",
        "Mumei言語で作られたDiscord Bot",
        0x3498db
    );

    embed = discord_embed_add_field(embed, "言語", "Mumei", true);
    embed = discord_embed_add_field(embed, "バージョン", "1.0.0", true);
    embed = discord_embed_add_field(embed, "機能", "Modal, Slash Commands, Interactions", false);

    return {"embed": embed};
});

# 例5: スラッシュコマンド - /stats
discord_create_slash_command("stats", "サーバー統計を表示", lambda(interaction) {
    let embed = discord_create_embed(
        "📊 サーバー統計",
        "現在のサーバー情報",
        0xf39c12
    );

    embed = discord_embed_add_field(embed, "コマンド", "5個", true);
    embed = discord_embed_add_field(embed, "機能", "Modal & Slash", true);

    return {"embed": embed};
});

# スラッシュコマンドを同期
discord_sync_commands();

# 通常のコマンド
discord_command("help", lambda(ctx, *args) {
    let embed = discord_create_embed(
        "📖 コマンド一覧",
        "利用可能なコマンドとスラッシュコマンド",
        0x3498db
    );

    embed = discord_embed_add_field(
        embed,
        "通常コマンド (! prefix)",
        "!feedback - フィードバックフォーム\n!inquiry - 問い合わせフォーム\n!help - このヘルプ",
        false
    );

    embed = discord_embed_add_field(
        embed,
        "スラッシュコマンド (/)",
        "/ping - 応答速度チェック\n/info - Bot情報\n/stats - サーバー統計",
        false
    );

    embed = discord_embed_set_footer(embed, "Mumei Bot | Modal & Slash Commands");

    return {"embed": embed};
});

# Readyイベント
discord_on_event("ready", lambda() {
    print("✅ Modal & Slash Commands Bot が起動しました！");
    print("");
    print("機能:");
    print("  📝 Modalフォーム（フィードバック、問い合わせ）");
    print("  ⚡ スラッシュコマンド（/ping, /info, /stats）");
    print("  🔘 インタラクティブボタン");
    print("");
    print("!help でコマンド一覧を表示");
});

# Botを起動
print("Botを起動中...");
discord_run(token);
