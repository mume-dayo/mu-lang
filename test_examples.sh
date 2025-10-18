#!/bin/bash
# 全exampleファイルのテスト

cd "$(dirname "$0")"

echo "======================================================================"
echo "Mumei Language - 全機能テスト"
echo "======================================================================"

SUCCESS=0
FAILED=0
SKIPPED=0

# スキップするパターン
SKIP_PATTERNS="discord_ http_ async_ import_ generator_ with_"

for file in examples/*.mu; do
    filename=$(basename "$file")

    echo ""
    echo "======================================================================"
    echo "テスト: $filename"
    echo "======================================================================"

    # スキップ判定
    SHOULD_SKIP=false
    for pattern in $SKIP_PATTERNS; do
        if [[ $filename == $pattern* ]]; then
            SHOULD_SKIP=true
            break
        fi
    done

    if $SHOULD_SKIP; then
        echo "⏭️  スキップ (外部依存または未実装機能)"
        ((SKIPPED++))
        continue
    fi

    echo "実行中..."
    if ./mumei "$file" 2>&1; then
        echo "✅ 成功"
        ((SUCCESS++))
    else
        echo "❌ 失敗"
        ((FAILED++))
    fi
done

echo ""
echo "======================================================================"
echo "テスト結果サマリー"
echo "======================================================================"
echo "✅ 成功: $SUCCESS"
echo "❌ 失敗: $FAILED"
echo "⏭️  スキップ: $SKIPPED"
echo "======================================================================"
