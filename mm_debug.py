"""
Mumei Debugger Module
Simple debugging utilities for Mumei language
"""

import sys

# デバッグモードのグローバルフラグ
_DEBUG_MODE = False
_BREAKPOINTS = set()
_STEP_MODE = False


def debug_enable():
    """デバッグモードを有効化"""
    global _DEBUG_MODE
    _DEBUG_MODE = True
    return None


def debug_disable():
    """デバッグモードを無効化"""
    global _DEBUG_MODE
    _DEBUG_MODE = False
    return None


def debug_print(*args):
    """デバッグ出力（デバッグモード時のみ表示）"""
    if _DEBUG_MODE:
        print("[DEBUG]", *args, file=sys.stderr)
    return None


def debug_trace(message):
    """トレース出力"""
    if _DEBUG_MODE:
        print(f"[TRACE] {message}", file=sys.stderr)
    return None


def debug_vars(env_dict):
    """現在の変数を表示"""
    if _DEBUG_MODE:
        print("[VARIABLES]", file=sys.stderr)
        for name, value in env_dict.items():
            print(f"  {name} = {repr(value)}", file=sys.stderr)
    return None


def debug_stack_trace():
    """スタックトレースを表示"""
    import traceback
    traceback.print_stack(file=sys.stderr)
    return None


def debug_breakpoint(name=""):
    """ブレークポイント（デバッグモード時に一時停止）"""
    if _DEBUG_MODE:
        print(f"[BREAKPOINT] {name}", file=sys.stderr)
        print("Press Enter to continue...", file=sys.stderr)
        input()
    return None


def debug_assert(condition, message="Assertion failed"):
    """アサーション（条件が偽の場合にエラー）"""
    if not condition:
        raise AssertionError(message)
    return None


def debug_timer_start(name="timer"):
    """タイマー開始"""
    import time
    global _TIMERS
    if '_TIMERS' not in globals():
        globals()['_TIMERS'] = {}
    globals()['_TIMERS'][name] = time.time()
    return None


def debug_timer_end(name="timer"):
    """タイマー終了（経過時間を表示）"""
    import time
    if '_TIMERS' not in globals() or name not in globals()['_TIMERS']:
        print(f"[TIMER] Timer '{name}' not started", file=sys.stderr)
        return None

    start_time = globals()['_TIMERS'][name]
    elapsed = time.time() - start_time
    print(f"[TIMER] {name}: {elapsed:.6f} seconds", file=sys.stderr)
    del globals()['_TIMERS'][name]
    return elapsed


def debug_profile(func):
    """関数のプロファイリング（実行時間計測）"""
    def wrapper(*args, **kwargs):
        import time
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        if _DEBUG_MODE:
            func_name = getattr(func, 'name', str(func))
            print(f"[PROFILE] {func_name}: {elapsed:.6f} seconds", file=sys.stderr)
        return result
    return wrapper


def debug_memory():
    """メモリ使用量を表示"""
    try:
        import psutil
        import os
        process = psutil.Process(os.getpid())
        mem_info = process.memory_info()
        print(f"[MEMORY] RSS: {mem_info.rss / 1024 / 1024:.2f} MB", file=sys.stderr)
        print(f"[MEMORY] VMS: {mem_info.vms / 1024 / 1024:.2f} MB", file=sys.stderr)
    except ImportError:
        print("[MEMORY] psutil not installed. Install with: pip install psutil", file=sys.stderr)
    return None


def debug_inspect(obj):
    """オブジェクトの詳細情報を表示"""
    print(f"[INSPECT] Type: {type(obj).__name__}", file=sys.stderr)
    print(f"[INSPECT] Value: {repr(obj)}", file=sys.stderr)
    print(f"[INSPECT] Attributes:", file=sys.stderr)
    for attr in dir(obj):
        if not attr.startswith('_'):
            try:
                value = getattr(obj, attr)
                print(f"  {attr}: {repr(value)}", file=sys.stderr)
            except:
                pass
    return None


def setup_debug_builtins(env):
    """Setup debug functions in the global environment"""
    env.define('debug_enable', debug_enable)
    env.define('debug_disable', debug_disable)
    env.define('debug_print', debug_print)
    env.define('debug_trace', debug_trace)
    env.define('debug_vars', debug_vars)
    env.define('debug_stack_trace', debug_stack_trace)
    env.define('debug_breakpoint', debug_breakpoint)
    env.define('debug_assert', debug_assert)
    env.define('debug_timer_start', debug_timer_start)
    env.define('debug_timer_end', debug_timer_end)
    env.define('debug_memory', debug_memory)
    env.define('debug_inspect', debug_inspect)


# Export functions for Mumei interpreter
DEBUG_FUNCTIONS = {
    'debug_enable': debug_enable,
    'debug_disable': debug_disable,
    'debug_print': debug_print,
    'debug_trace': debug_trace,
    'debug_vars': debug_vars,
    'debug_stack_trace': debug_stack_trace,
    'debug_breakpoint': debug_breakpoint,
    'debug_assert': debug_assert,
    'debug_timer_start': debug_timer_start,
    'debug_timer_end': debug_timer_end,
    'debug_memory': debug_memory,
    'debug_inspect': debug_inspect,
}
