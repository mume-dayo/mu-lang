# Discord.py Advanced Features Demo
# このファイルは50以上のDiscord機能のデモンストレーションです

# ボットの作成
discord_create_bot("!")

# === 1. サーバー情報コマンド ===
fun cmd_server_info(ctx, *args) {
    let guild = ctx.guild
    let member_count = discord_get_member_count(guild)
    let guild_name = discord_get_guild_name(guild)
    let icon_url = discord_get_guild_icon(guild)

    let embed = discord_create_embed("サーバー情報", none, 0x3498db)
    discord_embed_add_field(embed, "サーバー名", guild_name, false)
    discord_embed_add_field(embed, "メンバー数", member_count, true)

    if (icon_url) {
        discord_embed_set_thumbnail(embed, icon_url)
    }

    # チャンネル一覧
    let channels = discord_list_channels(guild)
    let channel_count = len(channels)
    discord_embed_add_field(embed, "チャンネル数", channel_count, true)

    # ロール一覧
    let roles = discord_list_roles(guild)
    let role_count = len(roles)
    discord_embed_add_field(embed, "ロール数", role_count, true)

    return { "embed": embed }
}

discord_command("serverinfo", cmd_server_info)

# === 2. メンバー情報コマンド ===
fun cmd_user_info(ctx, *args) {
    let member = ctx.author
    let user_id = discord_get_user_id(member)
    let user_name = discord_get_user_name(member)
    let avatar_url = discord_get_user_avatar(member)

    let embed = discord_create_embed("ユーザー情報", none, 0x2ecc71)
    discord_embed_add_field(embed, "ユーザー名", user_name, true)
    discord_embed_add_field(embed, "ID", user_id, true)

    if (avatar_url) {
        discord_embed_set_thumbnail(embed, avatar_url)
    }

    return { "embed": embed }
}

discord_command("userinfo", cmd_user_info)

# === 3. チャンネル管理コマンド ===
fun cmd_create_channel(ctx, *args) {
    # 権限チェック（管理者のみ）
    if (not ctx.author.guild_permissions.administrator) {
        return "このコマンドは管理者のみ使用できます"
    }

    let guild = ctx.guild
    let channel_name = "新しいチャンネル"

    if (len(args) > 0) {
        channel_name = args[0]
    }

    # チャンネル作成（非同期）
    discord_create_text_channel(guild, channel_name, none, "Mumeiで作成されました")

    return "チャンネル「" + channel_name + "」を作成しました！"
}

discord_command("createchannel", cmd_create_channel)

# === 4. ロール管理コマンド ===
fun cmd_create_role(ctx, *args) {
    if (not ctx.author.guild_permissions.administrator) {
        return "このコマンドは管理者のみ使用できます"
    }

    let guild = ctx.guild
    let role_name = "新しいロール"
    let color = 0x3498db

    if (len(args) > 0) {
        role_name = args[0]
    }

    if (len(args) > 1) {
        color = args[1]
    }

    discord_create_role(guild, role_name, color, none, false)

    return "ロール「" + role_name + "」を作成しました！"
}

discord_command("createrole", cmd_create_role)

# === 5. メッセージ管理コマンド ===
fun cmd_purge(ctx, *args) {
    if (not ctx.author.guild_permissions.manage_messages) {
        return "メッセージ管理権限が必要です"
    }

    let limit = 10
    if (len(args) > 0) {
        limit = int(args[0])
    }

    discord_purge_messages(ctx.channel, limit)

    return limit + "件のメッセージを削除しました"
}

discord_command("purge", cmd_purge)

# === 6. リアクション追加コマンド ===
fun cmd_react(ctx, *args) {
    let emoji = "👍"

    if (len(args) > 0) {
        emoji = args[0]
    }

    # 前のメッセージを取得して反応を追加
    # （注：実際の実装では最新メッセージを取得）
    discord_add_reaction(ctx.message, emoji)

    return "リアクションを追加しました！"
}

discord_command("react", cmd_react)

# === 7. スレッド作成コマンド ===
fun cmd_thread(ctx, *args) {
    let thread_name = "新しいスレッド"

    if (len(args) > 0) {
        thread_name = args[0]
    }

    discord_create_thread(ctx.channel, thread_name, ctx.message)

    return "スレッド「" + thread_name + "」を作成しました！"
}

discord_command("thread", cmd_thread)

# === 8. モデレーションコマンド ===
fun cmd_timeout(ctx, *args) {
    if (not ctx.author.guild_permissions.moderate_members) {
        return "メンバー管理権限が必要です"
    }

    if (len(args) < 2) {
        return "使い方: !timeout @user <秒数>"
    }

    # 実際にはメンション処理が必要
    return "タイムアウトコマンドの例です（メンション処理は別途実装が必要）"
}

discord_command("timeout", cmd_timeout)

# === 9. カスタムEmbed付きコマンド ===
fun cmd_announce(ctx, *args) {
    if (len(args) == 0) {
        return "使い方: !announce <メッセージ>"
    }

    let message = ""
    for (arg in args) {
        message = message + arg + " "
    }

    let embed = discord_create_embed("📢 お知らせ", message, 0xe74c3c)
    discord_embed_set_footer(embed, "Mumei Bot", none)

    let author_name = discord_get_user_name(ctx.author)
    let author_avatar = discord_get_user_avatar(ctx.author)
    discord_embed_set_author(embed, author_name, author_avatar)

    return { "embed": embed }
}

discord_command("announce", cmd_announce)

# === 10. ヘルプコマンド ===
fun cmd_help(ctx, *args) {
    let embed = discord_create_embed("コマンド一覧", "Mumei Discord Bot", 0x9b59b6)

    discord_embed_add_field(embed, "!serverinfo", "サーバー情報を表示", false)
    discord_embed_add_field(embed, "!userinfo", "ユーザー情報を表示", false)
    discord_embed_add_field(embed, "!createchannel <名前>", "チャンネルを作成（管理者のみ）", false)
    discord_embed_add_field(embed, "!createrole <名前> <色>", "ロールを作成（管理者のみ）", false)
    discord_embed_add_field(embed, "!purge <数>", "メッセージを削除", false)
    discord_embed_add_field(embed, "!react <emoji>", "リアクションを追加", false)
    discord_embed_add_field(embed, "!thread <名前>", "スレッドを作成", false)
    discord_embed_add_field(embed, "!announce <メッセージ>", "お知らせを送信", false)

    discord_embed_set_footer(embed, "Powered by Mumei Language", none)

    return { "embed": embed }
}

discord_command("help", cmd_help)

# === イベントハンドラー ===
fun on_bot_ready() {
    print("Bot is ready!")
    print("Discord.py advanced features loaded")
}

discord_on_event("ready", on_bot_ready)

# ボット実行
# discord_run("YOUR_BOT_TOKEN_HERE")
