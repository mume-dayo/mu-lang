# Discord Bot 常時監視メカニズムの実装

## 概要

mm_discord.pyの `bot.run()` と同じ動作をRust版で実現するため、**常時監視ループ（Keep-Alive）**を実装しました。

## 実装前の問題

### 問題点

```mumei
# 古い実装
d.run(token, 32767);  # Gatewayに接続

# プログラムがここで終了！
# Gatewayはバックグラウンドで動いているが、メインスレッドが終わるとプログラム全体が終了
```

**なぜ問題だったか:**
- `gateway_connect()` は `tokio::spawn()` でバックグラウンドタスクとして起動
- メインスレッドがすぐに終了してしまう
- Botが動作する前にプログラムが終わる

## 実装方法

### Rust側の実装（gateway.rs）

```rust
// gateway.rs - line 192-209
#[pyfunction]
pub fn gateway_connect(token: String, intents: u32) -> PyResult<()> {
    // Save token for later use
    {
        let mut client = GATEWAY_CLIENT.lock().unwrap();
        *client = Some(token.clone());
    }

    // Start gateway in background
    tokio::spawn(async move {
        let mut gateway = Gateway::new(token, intents);
        if let Err(e) = gateway.connect().await {
            eprintln!("Gateway error: {}", e);
        }
    });

    Ok(())
}
```

**ポイント:**
- `tokio::spawn()` で非同期タスクを起動
- タスクはバックグラウンドで動作
- メインスレッドはすぐに戻る

### Mumei側の実装（d_rust_full.mu）

#### Before（問題あり）

```mumei
fun run(token, intents) {
    gateway_connect(token, intents);
    print("✅ Gateway connected!");
    # ここで関数が終了し、プログラムも終了
}
```

#### After（改善版）

```mumei
fun run(token, intents) {
    gateway_connect(token, intents);

    print("✅ Gateway connected!");
    print("🔄 Bot is running... (Press Ctrl+C to stop)");

    # mm_discord.pyのbot.run()と同じように常時監視
    _keep_alive();  # ← 無限ループでブロック
}

fun _keep_alive() {
    print("💤 Entering event loop (keeping bot alive)...");

    # 無限ループでBotを稼働し続ける
    # mm_discord.pyの_bot.run()も内部的にasyncioイベントループを回している
    while (True) {
        sleep(1);  # 1秒ごとにチェック（CPU負荷を抑える）
    }
}
```

## mm_discord.pyとの比較

### Python版の内部動作

```python
# mm_discord.py
def discord_run(token):
    _bot.run(token)  # ← ここでブロック

# discord.pyの内部
class Bot:
    def run(self, token):
        asyncio.run(self.start(token))  # ← asyncioイベントループ開始
        # ↑ ここでブロックされ、Ctrl+Cまで戻らない
```

**discord.pyの `bot.run()` の動作:**
1. `asyncio.run()` を呼び出す
2. イベントループを開始
3. WebSocket接続を確立
4. イベントを待機し、コールバックを実行
5. **Ctrl+Cが押されるまでブロック**

### Rust版の動作

```mumei
# d_rust_full.mu
d.run(token, 32767);  # ← ここでブロック

# 内部動作
fun run(token, intents) {
    gateway_connect(token, intents);  # WebSocket接続（バックグラウンド）
    _keep_alive();  # ← while (True) { sleep(1); }
    # ↑ ここでブロックされ、Ctrl+Cまで戻らない
}
```

**d_rust_full.muの動作:**
1. `gateway_connect()` でWebSocket接続（バックグラウンド）
2. `_keep_alive()` で無限ループ開始
3. バックグラウンドでイベント受信・処理
4. **Ctrl+Cが押されるまでブロック**

## アーキテクチャ

### マルチスレッド構成

```
┌─────────────────────────────────────────┐
│  Main Thread (Mumei)                    │
│  ┌───────────────────────────────────┐  │
│  │ d.run(token, intents)             │  │
│  │   ↓                               │  │
│  │ gateway_connect()                 │  │
│  │   ↓                               │  │
│  │ _keep_alive()                     │  │
│  │   ↓                               │  │
│  │ while (True) { sleep(1); }        │  │
│  │   ↑ ループし続ける                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Background Thread (Tokio)              │
│  ┌───────────────────────────────────┐  │
│  │ tokio::spawn(async {              │  │
│  │   Gateway::connect().await        │  │
│  │   ↓                               │  │
│  │   WebSocket接続                    │  │
│  │   ↓                               │  │
│  │   while let Some(msg) = read() {  │  │
│  │     handle_message(msg);          │  │
│  │     trigger_callbacks();          │  │
│  │   }                               │  │
│  │ })                                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**役割分担:**
- **Main Thread**: プログラムを維持（`while (True)`ループ）
- **Background Thread**: WebSocket接続・イベント処理

## CPU負荷の最適化

### なぜ `sleep(1)` を入れるか？

```mumei
while (True) {
    sleep(1);  # ← これがないとCPU 100%使用！
}
```

**理由:**
- `while (True) {}` だけだとCPUを100%使い切る
- `sleep(1)` で1秒待機することで、CPU使用率を大幅に削減
- イベント処理はバックグラウンドスレッドで行われるため、メインスレッドは待機だけでOK

**CPU使用率:**
- `while (True) {}` のみ: **100%**
- `while (True) { sleep(1); }`: **< 1%**

## 使用例

### シンプルな例

```mumei
import "d_rust_full.mu" as d;

d.create_bot("!");

d.on_ready(lambda() {
    print("Bot起動！");
});

# この1行だけで常時監視が始まる
d.run(env("DISCORD_TOKEN"), 32767);

# ↑ ここでブロックされるため、以降のコードは実行されない
print("これは実行されない");
```

### Python版との互換性

```python
# Python版（discord.py）
import discord
from discord.ext import commands

bot = commands.Bot(command_prefix="!", intents=discord.Intents.default())

@bot.event
async def on_ready():
    print("Bot起動！")

bot.run(token)  # ← ブロッキング
print("これは実行されない")
```

```mumei
# Rust版（d_rust_full.mu）
import "d_rust_full.mu" as d;

d.create_bot("!");

d.on_ready(lambda() {
    print("Bot起動！");
});

d.run(token, 32767);  # ← ブロッキング
print("これは実行されない");
```

**完全に同じ動作！**

## まとめ

### 実装のポイント

1. **`_keep_alive()` 関数を追加**
   - 無限ループでメインスレッドを維持
   - `sleep(1)` でCPU負荷を抑制

2. **`d.run()` 内で `_keep_alive()` を呼び出す**
   - mm_discord.pyの `bot.run()` と同じブロッキング動作
   - プログラムが終了しない

3. **Gatewayはバックグラウンドで動作**
   - `tokio::spawn()` で別スレッドで実行
   - イベント受信・処理は並行して行われる

### 利点

✅ **mm_discord.pyと完全互換**
✅ **シンプルな使い方**（`d.run()` だけでOK）
✅ **低CPU使用率**（< 1%）
✅ **マルチスレッド対応**
✅ **Ctrl+Cで正常終了**

### 改善前後の比較

| 項目 | Before | After |
|------|--------|-------|
| プログラムの動作 | すぐ終了 | 常時稼働 |
| ユーザーコード | `while (True)` が必要 | 不要 |
| mm_discord.py互換 | ❌ | ✅ |
| CPU使用率 | N/A | < 1% |

これで、**d_rust_full.mu** は **mm_discord.py** と全く同じ使い勝手になりました！🎉
