/// コンパイル結果のキャッシュ
/// 同じコードを再コンパイルしないことで劇的な高速化を実現

use std::collections::HashMap;
use std::sync::Mutex;
use once_cell::sync::Lazy;
use crate::bytecode::ByteCode;

/// グローバルコンパイルキャッシュ
static COMPILE_CACHE: Lazy<Mutex<CompileCache>> = Lazy::new(|| {
    Mutex::new(CompileCache::new())
});

/// コンパイルキャッシュ
pub struct CompileCache {
    /// ソースコードのハッシュ → コンパイル済みバイトコード
    cache: HashMap<u64, ByteCode>,

    /// キャッシュヒット数
    hits: usize,

    /// キャッシュミス数
    misses: usize,
}

impl CompileCache {
    /// 新しいキャッシュを作成
    pub fn new() -> Self {
        CompileCache {
            cache: HashMap::new(),
            hits: 0,
            misses: 0,
        }
    }

    /// ソースコードをハッシュ化
    fn hash_source(source: &str) -> u64 {
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};

        let mut hasher = DefaultHasher::new();
        source.hash(&mut hasher);
        hasher.finish()
    }

    /// キャッシュから取得
    pub fn get(&mut self, source: &str) -> Option<ByteCode> {
        let hash = Self::hash_source(source);

        if let Some(bytecode) = self.cache.get(&hash) {
            self.hits += 1;
            Some(bytecode.clone())
        } else {
            self.misses += 1;
            None
        }
    }

    /// キャッシュに保存
    pub fn insert(&mut self, source: &str, bytecode: ByteCode) {
        let hash = Self::hash_source(source);
        self.cache.insert(hash, bytecode);
    }

    /// キャッシュ統計を取得
    pub fn stats(&self) -> (usize, usize, f64) {
        let total = self.hits + self.misses;
        let hit_rate = if total > 0 {
            self.hits as f64 / total as f64
        } else {
            0.0
        };
        (self.hits, self.misses, hit_rate)
    }

    /// キャッシュをクリア
    pub fn clear(&mut self) {
        self.cache.clear();
        self.hits = 0;
        self.misses = 0;
    }
}

/// グローバルキャッシュから取得
pub fn get_cached_bytecode(source: &str) -> Option<ByteCode> {
    COMPILE_CACHE.lock().unwrap().get(source)
}

/// グローバルキャッシュに保存
pub fn cache_bytecode(source: &str, bytecode: ByteCode) {
    COMPILE_CACHE.lock().unwrap().insert(source, bytecode);
}

/// キャッシュ統計を取得
pub fn get_cache_stats() -> (usize, usize, f64) {
    COMPILE_CACHE.lock().unwrap().stats()
}

/// キャッシュをクリア
pub fn clear_cache() {
    COMPILE_CACHE.lock().unwrap().clear();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cache() {
        let mut cache = CompileCache::new();

        let source = "2 + 3";
        let bytecode = ByteCode::new();

        // 最初はミス
        assert!(cache.get(source).is_none());

        // 保存
        cache.insert(source, bytecode.clone());

        // 次はヒット
        assert!(cache.get(source).is_some());

        let (hits, misses, _) = cache.stats();
        assert_eq!(hits, 1);
        assert_eq!(misses, 1);
    }
}
