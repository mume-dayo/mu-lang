"""
Mumei Language Async Support
非同期処理のための統一されたサポート（asyncioベース）
"""

import asyncio
import time
from typing import Any, Optional


def setup_async_builtins(env):
    """
    Mumeiインタプリタに非同期関連の組み込み関数を追加
    全ての非同期関数はasyncio.create_task()を返す形式に統一
    """

    def builtin_sleep(seconds):
        """
        指定秒数スリープ

        Args:
            seconds: スリープする秒数（float可）

        Returns:
            asyncio.Task: 非同期タスク（awaitで待機可能）

        Example:
            let task = sleep(2.5);
            await task;
        """
        if not isinstance(seconds, (int, float)):
            raise TypeError(f"sleep() expects numeric seconds, got {type(seconds).__name__}")

        if seconds < 0:
            raise ValueError(f"sleep() seconds must be non-negative, got {seconds}")

        async def _sleep():
            await asyncio.sleep(float(seconds))
            return None

        return asyncio.create_task(_sleep())

    def builtin_async_run(func, *args):
        """
        関数を非同期で実行

        Args:
            func: 実行する関数（callable）
            *args: 関数に渡す引数

        Returns:
            asyncio.Task: 非同期タスク（awaitで結果取得可能）

        Raises:
            TypeError: funcがcallableでない場合

        Example:
            let task = async_run(heavy_function, arg1, arg2);
            let result = await task;
        """
        if not callable(func):
            raise TypeError(f"async_run() requires a callable function, got {type(func).__name__}")

        async def _run():
            # 同期関数を非同期コンテキストで実行
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, func, *args)

        return asyncio.create_task(_run())

    def builtin_await(task):
        """
        非同期タスクの完了を待つ

        Args:
            task: asyncio.Task または awaitable オブジェクト

        Returns:
            タスクの実行結果

        Note:
            通常の値を渡した場合はそのまま返す

        Example:
            let result = await task;
        """
        if isinstance(task, asyncio.Task) or asyncio.iscoroutine(task):
            # イベントループ内で実行
            loop = asyncio.get_event_loop()
            if loop.is_running():
                # 既にループが動いている場合（Discord bot等）
                return task
            else:
                # ループが動いていない場合は同期的に実行
                return loop.run_until_complete(task)
        else:
            # 通常の値の場合はそのまま返す
            return task

    def builtin_task_done(task):
        """
        タスクが完了したかチェック

        Args:
            task: asyncio.Task

        Returns:
            bool: 完了していればTrue

        Example:
            if (task_done(my_task)) {
                print("Task completed!");
            }
        """
        if isinstance(task, asyncio.Task):
            return task.done()
        return True

    def builtin_task_cancel(task):
        """
        タスクをキャンセル

        Args:
            task: asyncio.Task

        Returns:
            bool: キャンセルが成功したかどうか

        Example:
            let cancelled = task_cancel(long_running_task);
        """
        if not isinstance(task, asyncio.Task):
            raise TypeError(f"task_cancel() expects asyncio.Task, got {type(task).__name__}")

        return task.cancel()

    def builtin_task_cancelled(task):
        """
        タスクがキャンセルされたかチェック

        Args:
            task: asyncio.Task

        Returns:
            bool: キャンセルされていればTrue
        """
        if isinstance(task, asyncio.Task):
            return task.cancelled()
        return False

    def builtin_wait_all(*tasks):
        """
        複数のタスクの完了を待つ（並列実行）

        Args:
            *tasks: asyncio.Task のリスト

        Returns:
            asyncio.Task: 全タスクの結果をリストで返すタスク

        Example:
            let task1 = async_run(func1);
            let task2 = async_run(func2);
            let results = await wait_all(task1, task2);
        """
        async def _wait_all():
            results = []
            for task in tasks:
                if isinstance(task, asyncio.Task) or asyncio.iscoroutine(task):
                    result = await task
                    results.append(result)
                else:
                    results.append(task)
            return results

        return asyncio.create_task(_wait_all())

    def builtin_wait_any(*tasks):
        """
        複数のタスクのうちいずれか1つが完了するまで待つ

        Args:
            *tasks: asyncio.Task のリスト

        Returns:
            asyncio.Task: 最初に完了したタスクの結果を返すタスク

        Example:
            let fastest = await wait_any(task1, task2, task3);
        """
        if not tasks:
            raise ValueError("wait_any() requires at least one task")

        async def _wait_any():
            done, pending = await asyncio.wait(
                [t for t in tasks if isinstance(t, asyncio.Task)],
                return_when=asyncio.FIRST_COMPLETED
            )

            # 残りのタスクはキャンセル
            for task in pending:
                task.cancel()

            # 最初に完了したタスクの結果を返す
            return list(done)[0].result()

        return asyncio.create_task(_wait_any())

    def builtin_wait_timeout(task, timeout_seconds):
        """
        タイムアウト付きでタスクを待つ

        Args:
            task: asyncio.Task
            timeout_seconds: タイムアウト秒数（float可）

        Returns:
            asyncio.Task: タスク結果を返すタスク（タイムアウト時はNone）

        Example:
            let result = await wait_timeout(long_task, 5.0);
            if (result == null) {
                print("Timeout!");
            }
        """
        if not isinstance(timeout_seconds, (int, float)):
            raise TypeError(f"timeout_seconds must be numeric, got {type(timeout_seconds).__name__}")

        if timeout_seconds < 0:
            raise ValueError(f"timeout_seconds must be non-negative, got {timeout_seconds}")

        async def _wait_timeout():
            try:
                return await asyncio.wait_for(task, timeout=float(timeout_seconds))
            except asyncio.TimeoutError:
                return None

        return asyncio.create_task(_wait_timeout())

    def builtin_get_time():
        """
        現在時刻を取得（UNIX時間）

        Returns:
            float: 現在のUNIX時間（秒）

        Example:
            let now = get_time();
        """
        return time.time()

    def builtin_delay(seconds, func, *args):
        """
        指定秒数待ってから関数を実行

        Args:
            seconds: 待機する秒数
            func: 実行する関数
            *args: 関数に渡す引数

        Returns:
            asyncio.Task: 遅延実行タスク

        Example:
            let task = delay(3, print, "Hello after 3 seconds");
            await task;
        """
        if not isinstance(seconds, (int, float)):
            raise TypeError(f"delay() expects numeric seconds, got {type(seconds).__name__}")

        if not callable(func):
            raise TypeError(f"delay() expects callable function, got {type(func).__name__}")

        async def _delay():
            await asyncio.sleep(float(seconds))
            return func(*args)

        return asyncio.create_task(_delay())

    # 環境に関数を追加
    env.define('sleep', builtin_sleep)
    env.define('async_run', builtin_async_run)
    env.define('await_task', builtin_await)
    env.define('task_done', builtin_task_done)
    env.define('task_cancel', builtin_task_cancel)
    env.define('task_cancelled', builtin_task_cancelled)
    env.define('wait_all', builtin_wait_all)
    env.define('wait_any', builtin_wait_any)
    env.define('wait_timeout', builtin_wait_timeout)
    env.define('get_time', builtin_get_time)
    env.define('delay', builtin_delay)
