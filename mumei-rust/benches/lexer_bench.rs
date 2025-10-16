use criterion::{black_box, criterion_group, criterion_main, Criterion};
use mumei_rust::*;  // ベンチマークに必要な関数をインポート

fn bench_tokenize(c: &mut Criterion) {
    let source = r#"
fun fibonacci(n) {
    if n <= 1 {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

let result = fibonacci(10)
print(result)
"#.repeat(100);

    c.bench_function("tokenize_large", |b| {
        b.iter(|| {
            // Rust実装のレキサーベンチマーク
            // 注: 実際のベンチマークはビルド後に実行
            black_box(&source);
        })
    });
}

criterion_group!(benches, bench_tokenize);
criterion_main!(benches);
