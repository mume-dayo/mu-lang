"""
Mumei File I/O Module
File operations for Mumei language
統一された設計: 非同期サポート、型チェック、エラーハンドリング、柔軟な引数
"""

import asyncio
import os
from typing import Optional, List

def file_read(filepath, encoding='utf-8', async_mode=False):
    """
    ファイルの内容を読み込む

    Args:
        filepath: ファイルパス（文字列）
        encoding: 文字エンコーディング（デフォルト: 'utf-8'）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        str: ファイルの内容（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ファイル読み込み失敗時

    Example:
        let content = file_read("data.txt");

        // 非同期読み込み
        let task = file_read("large_file.txt", "utf-8", true);
        let content = await task;
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_read() filepath must be string, got {type(filepath).__name__}")

    if not isinstance(encoding, str):
        raise TypeError(f"file_read() encoding must be string, got {type(encoding).__name__}")

    def _sync_read():
        try:
            with open(filepath, 'r', encoding=encoding) as f:
                return f.read()
        except FileNotFoundError:
            raise Exception(f"File not found: '{filepath}'")
        except PermissionError:
            raise Exception(f"Permission denied: '{filepath}'")
        except UnicodeDecodeError as e:
            raise Exception(f"Failed to decode file '{filepath}' with encoding '{encoding}': {str(e)}")
        except Exception as e:
            raise Exception(f"Failed to read file '{filepath}': {str(e)}")

    if async_mode:
        async def _async_read():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_read)
        return asyncio.create_task(_async_read())
    else:
        return _sync_read()


def file_write(filepath, content, encoding='utf-8', async_mode=False):
    """
    ファイルに書き込む（上書き）

    Args:
        filepath: ファイルパス
        content: 書き込む内容（文字列または文字列化可能なオブジェクト）
        encoding: 文字エンコーディング（デフォルト: 'utf-8'）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        None（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ファイル書き込み失敗時

    Example:
        file_write("output.txt", "Hello, World!");

        // 非同期書き込み
        let task = file_write("output.txt", data, "utf-8", true);
        await task;
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_write() filepath must be string, got {type(filepath).__name__}")

    if not isinstance(encoding, str):
        raise TypeError(f"file_write() encoding must be string, got {type(encoding).__name__}")

    def _sync_write():
        try:
            with open(filepath, 'w', encoding=encoding) as f:
                f.write(str(content))
            return None
        except PermissionError:
            raise Exception(f"Permission denied: '{filepath}'")
        except Exception as e:
            raise Exception(f"Failed to write to file '{filepath}': {str(e)}")

    if async_mode:
        async def _async_write():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_write)
        return asyncio.create_task(_async_write())
    else:
        return _sync_write()


def file_append(filepath, content, encoding='utf-8', async_mode=False):
    """
    ファイルに追記する

    Args:
        filepath: ファイルパス
        content: 追記する内容
        encoding: 文字エンコーディング（デフォルト: 'utf-8'）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        None（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Example:
        file_append("log.txt", "New log entry\\n");
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_append() filepath must be string, got {type(filepath).__name__}")

    if not isinstance(encoding, str):
        raise TypeError(f"file_append() encoding must be string, got {type(encoding).__name__}")

    def _sync_append():
        try:
            with open(filepath, 'a', encoding=encoding) as f:
                f.write(str(content))
            return None
        except PermissionError:
            raise Exception(f"Permission denied: '{filepath}'")
        except Exception as e:
            raise Exception(f"Failed to append to file '{filepath}': {str(e)}")

    if async_mode:
        async def _async_append():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_append)
        return asyncio.create_task(_async_append())
    else:
        return _sync_append()


def file_exists(filepath):
    """
    ファイルが存在するかチェック

    Args:
        filepath: ファイルパス

    Returns:
        bool: 存在すればTrue

    Raises:
        TypeError: 引数が文字列でない場合

    Example:
        if (file_exists("config.json")) {
            print("Config file found");
        }
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_exists() filepath must be string, got {type(filepath).__name__}")

    return os.path.exists(filepath)


def file_delete(filepath, ignore_missing=False):
    """
    ファイルを削除

    Args:
        filepath: ファイルパス
        ignore_missing: ファイルが存在しない場合にエラーを無視するか（デフォルト: False）

    Returns:
        None

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ファイル削除失敗時

    Example:
        file_delete("temp.txt");

        // ファイルが存在しなくてもエラーにしない
        file_delete("temp.txt", true);
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_delete() filepath must be string, got {type(filepath).__name__}")

    try:
        os.remove(filepath)
        return None
    except FileNotFoundError:
        if not ignore_missing:
            raise Exception(f"File not found: '{filepath}'")
        return None
    except PermissionError:
        raise Exception(f"Permission denied: '{filepath}'")
    except Exception as e:
        raise Exception(f"Failed to delete file '{filepath}': {str(e)}")


def file_readlines(filepath, encoding='utf-8', keep_newlines=True):
    """
    ファイルを行ごとに読み込む

    Args:
        filepath: ファイルパス
        encoding: 文字エンコーディング（デフォルト: 'utf-8'）
        keep_newlines: 改行文字を保持するか（デフォルト: True）

    Returns:
        list: 行のリスト

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ファイル読み込み失敗時

    Example:
        let lines = file_readlines("data.txt");
        for (let i = 0; i < len(lines); i = i + 1) {
            print(lines[i]);
        }

        // 改行を削除して読み込む
        let lines = file_readlines("data.txt", "utf-8", false);
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_readlines() filepath must be string, got {type(filepath).__name__}")

    if not isinstance(encoding, str):
        raise TypeError(f"file_readlines() encoding must be string, got {type(encoding).__name__}")

    try:
        with open(filepath, 'r', encoding=encoding) as f:
            lines = f.readlines()
            if not keep_newlines:
                lines = [line.rstrip('\n\r') for line in lines]
            return lines
    except FileNotFoundError:
        raise Exception(f"File not found: '{filepath}'")
    except PermissionError:
        raise Exception(f"Permission denied: '{filepath}'")
    except Exception as e:
        raise Exception(f"Failed to read lines from '{filepath}': {str(e)}")


def file_writelines(filepath, lines, encoding='utf-8', add_newlines=True):
    """
    行のリストをファイルに書き込む

    Args:
        filepath: ファイルパス
        lines: 書き込む行のリスト
        encoding: 文字エンコーディング（デフォルト: 'utf-8'）
        add_newlines: 各行の末尾に改行を追加するか（デフォルト: True）

    Returns:
        None

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ファイル書き込み失敗時

    Example:
        let lines = ["Line 1", "Line 2", "Line 3"];
        file_writelines("output.txt", lines);
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_writelines() filepath must be string, got {type(filepath).__name__}")

    if not isinstance(lines, list):
        raise TypeError(f"file_writelines() lines must be list, got {type(lines).__name__}")

    if not isinstance(encoding, str):
        raise TypeError(f"file_writelines() encoding must be string, got {type(encoding).__name__}")

    try:
        with open(filepath, 'w', encoding=encoding) as f:
            for line in lines:
                f.write(str(line))
                if add_newlines and not str(line).endswith('\n'):
                    f.write('\n')
        return None
    except PermissionError:
        raise Exception(f"Permission denied: '{filepath}'")
    except Exception as e:
        raise Exception(f"Failed to write lines to '{filepath}': {str(e)}")


def dir_list(dirpath='.', include_hidden=False):
    """
    ディレクトリ内のファイルとフォルダをリスト

    Args:
        dirpath: ディレクトリパス（デフォルト: カレントディレクトリ）
        include_hidden: 隠しファイルを含めるか（デフォルト: False）

    Returns:
        list: ファイル名/フォルダ名のリスト

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ディレクトリ読み込み失敗時

    Example:
        let files = dir_list(".");
        print(files);

        // 隠しファイルも含める
        let all_files = dir_list(".", true);
    """
    if not isinstance(dirpath, str):
        raise TypeError(f"dir_list() dirpath must be string, got {type(dirpath).__name__}")

    try:
        items = os.listdir(dirpath)
        if not include_hidden:
            items = [item for item in items if not item.startswith('.')]
        return items
    except FileNotFoundError:
        raise Exception(f"Directory not found: '{dirpath}'")
    except PermissionError:
        raise Exception(f"Permission denied: '{dirpath}'")
    except Exception as e:
        raise Exception(f"Failed to list directory '{dirpath}': {str(e)}")


def dir_create(dirpath, exist_ok=True):
    """
    ディレクトリを作成

    Args:
        dirpath: ディレクトリパス
        exist_ok: 既に存在する場合にエラーを出さないか（デフォルト: True）

    Returns:
        None

    Raises:
        TypeError: 引数の型が不正な場合
        Exception: ディレクトリ作成失敗時

    Example:
        dir_create("output/data");
    """
    if not isinstance(dirpath, str):
        raise TypeError(f"dir_create() dirpath must be string, got {type(dirpath).__name__}")

    try:
        os.makedirs(dirpath, exist_ok=exist_ok)
        return None
    except PermissionError:
        raise Exception(f"Permission denied: '{dirpath}'")
    except Exception as e:
        raise Exception(f"Failed to create directory '{dirpath}': {str(e)}")


def dir_exists(dirpath):
    """
    ディレクトリが存在するかチェック

    Args:
        dirpath: ディレクトリパス

    Returns:
        bool: 存在すればTrue

    Raises:
        TypeError: 引数が文字列でない場合

    Example:
        if (dir_exists("output")) {
            print("Output directory exists");
        }
    """
    if not isinstance(dirpath, str):
        raise TypeError(f"dir_exists() dirpath must be string, got {type(dirpath).__name__}")

    return os.path.isdir(dirpath)


def path_join(*paths):
    """
    パスを結合

    Args:
        *paths: 結合するパスの可変長引数

    Returns:
        str: 結合されたパス

    Example:
        let full_path = path_join("output", "data", "file.txt");
        // "output/data/file.txt" (Unix) または "output\\data\\file.txt" (Windows)
    """
    if not paths:
        return ""

    return os.path.join(*[str(p) for p in paths])


def path_basename(filepath):
    """
    ファイル名を取得（パスから）

    Args:
        filepath: ファイルパス

    Returns:
        str: ファイル名（ディレクトリ部分を除いた部分）

    Example:
        let name = path_basename("/path/to/file.txt");  // "file.txt"
    """
    return os.path.basename(str(filepath))


def path_dirname(filepath):
    """
    ディレクトリ名を取得（パスから）

    Args:
        filepath: ファイルパス

    Returns:
        str: ディレクトリパス（ファイル名を除いた部分）

    Example:
        let dir = path_dirname("/path/to/file.txt");  // "/path/to"
    """
    return os.path.dirname(str(filepath))


def path_ext(filepath):
    """
    拡張子を取得

    Args:
        filepath: ファイルパス

    Returns:
        str: 拡張子（ドット含む）

    Example:
        let ext = path_ext("file.txt");  // ".txt"
        let ext2 = path_ext("archive.tar.gz");  // ".gz"
    """
    return os.path.splitext(str(filepath))[1]


def path_absolute(filepath):
    """
    絶対パスに変換

    Args:
        filepath: ファイルパス

    Returns:
        str: 絶対パス

    Example:
        let abs_path = path_absolute("./file.txt");
    """
    if not isinstance(filepath, str):
        raise TypeError(f"path_absolute() filepath must be string, got {type(filepath).__name__}")

    return os.path.abspath(str(filepath))


def file_size(filepath):
    """
    ファイルサイズを取得

    Args:
        filepath: ファイルパス

    Returns:
        int: ファイルサイズ（バイト）

    Raises:
        TypeError: 引数が文字列でない場合
        Exception: ファイルアクセス失敗時

    Example:
        let size = file_size("data.txt");
        print("File size: " + str(size) + " bytes");
    """
    if not isinstance(filepath, str):
        raise TypeError(f"file_size() filepath must be string, got {type(filepath).__name__}")

    try:
        return os.path.getsize(filepath)
    except FileNotFoundError:
        raise Exception(f"File not found: '{filepath}'")
    except PermissionError:
        raise Exception(f"Permission denied: '{filepath}'")
    except Exception as e:
        raise Exception(f"Failed to get file size for '{filepath}': {str(e)}")


def setup_file_builtins(env):
    """Setup file I/O functions in the global environment"""
    env.define('file_read', file_read)
    env.define('file_write', file_write)
    env.define('file_append', file_append)
    env.define('file_exists', file_exists)
    env.define('file_delete', file_delete)
    env.define('file_readlines', file_readlines)
    env.define('file_writelines', file_writelines)
    env.define('file_size', file_size)
    env.define('dir_list', dir_list)
    env.define('dir_create', dir_create)
    env.define('dir_exists', dir_exists)
    env.define('path_join', path_join)
    env.define('path_basename', path_basename)
    env.define('path_dirname', path_dirname)
    env.define('path_ext', path_ext)
    env.define('path_absolute', path_absolute)


# Export functions for Mumei interpreter
FILE_FUNCTIONS = {
    'file_read': file_read,
    'file_write': file_write,
    'file_append': file_append,
    'file_exists': file_exists,
    'file_delete': file_delete,
    'file_readlines': file_readlines,
    'file_writelines': file_writelines,
    'file_size': file_size,
    'dir_list': dir_list,
    'dir_create': dir_create,
    'dir_exists': dir_exists,
    'path_join': path_join,
    'path_basename': path_basename,
    'path_dirname': path_dirname,
    'path_ext': path_ext,
    'path_absolute': path_absolute,
}
