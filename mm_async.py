"""
Mumei Language Async Support
非同期処理のためのシンプルなサポート
"""

import time
import threading
from typing import Callable, Any


class AsyncTask:
    """非同期タスクを表すクラス"""
    def __init__(self, func: Callable, *args, **kwargs):
        self.func = func
        self.args = args
        self.kwargs = kwargs
        self.result = None
        self.done = False
        self.error = None
        self.thread = None

    def start(self):
        """タスクを開始"""
        def run():
            try:
                self.result = self.func(*self.args, **self.kwargs)
            except Exception as e:
                self.error = e
            finally:
                self.done = True

        self.thread = threading.Thread(target=run, daemon=True)
        self.thread.start()

    def wait(self):
        """タスクの完了を待つ"""
        if self.thread:
            self.thread.join()
        if self.error:
            raise self.error
        return self.result

    def is_done(self):
        """タスクが完了したかチェック"""
        return self.done


def setup_async_builtins(env):
    """
    Mumeiインタプリタに非同期関連の組み込み関数を追加
    """

    def builtin_sleep(seconds):
        """指定秒数スリープ"""
        time.sleep(float(seconds))
        return None

    def builtin_async_run(func, *args):
        """
        関数を非同期で実行
        タスクオブジェクトを返す
        """
        # MMFunctionの場合は、インタプリタを介して実行する必要がある
        # ここでは簡略化して、通常のPython関数のみサポート
        if not callable(func):
            raise TypeError(f"async_run requires a callable function, got {type(func).__name__}")

        task = AsyncTask(func, *args)
        task.start()
        return task

    def builtin_await(task):
        """
        非同期タスクの完了を待つ
        """
        if isinstance(task, AsyncTask):
            return task.wait()
        else:
            # 通常の値の場合はそのまま返す
            return task

    def builtin_task_done(task):
        """タスクが完了したかチェック"""
        if isinstance(task, AsyncTask):
            return task.is_done()
        return True

    def builtin_wait_all(*tasks):
        """複数のタスクの完了を待つ"""
        results = []
        for task in tasks:
            if isinstance(task, AsyncTask):
                results.append(task.wait())
            else:
                results.append(task)
        return results

    def builtin_get_time():
        """現在時刻を取得（UNIX時間）"""
        return time.time()

    # 環境に関数を追加
    env.define('sleep', builtin_sleep)
    env.define('async_run', builtin_async_run)
    env.define('await_task', builtin_await)
    env.define('task_done', builtin_task_done)
    env.define('wait_all', builtin_wait_all)
    env.define('get_time', builtin_get_time)
