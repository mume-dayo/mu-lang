"""
Mumei File I/O Module
File operations for Mumei language
"""

def file_read(filepath):
    """
    ファイルの内容を読み込む
    Returns: ファイルの内容（文字列）
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        raise Exception(f"Failed to read file '{filepath}': {str(e)}")


def file_write(filepath, content):
    """
    ファイルに書き込む（上書き）
    """
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(str(content))
        return None
    except Exception as e:
        raise Exception(f"Failed to write to file '{filepath}': {str(e)}")


def file_append(filepath, content):
    """
    ファイルに追記する
    """
    try:
        with open(filepath, 'a', encoding='utf-8') as f:
            f.write(str(content))
        return None
    except Exception as e:
        raise Exception(f"Failed to append to file '{filepath}': {str(e)}")


def file_exists(filepath):
    """
    ファイルが存在するかチェック
    Returns: True/False
    """
    import os
    return os.path.exists(filepath)


def file_delete(filepath):
    """
    ファイルを削除
    """
    try:
        import os
        os.remove(filepath)
        return None
    except Exception as e:
        raise Exception(f"Failed to delete file '{filepath}': {str(e)}")


def file_readlines(filepath):
    """
    ファイルを行ごとに読み込む
    Returns: 行のリスト
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.readlines()
    except Exception as e:
        raise Exception(f"Failed to read lines from '{filepath}': {str(e)}")


def file_writelines(filepath, lines):
    """
    行のリストをファイルに書き込む
    """
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            for line in lines:
                f.write(str(line))
                if not str(line).endswith('\n'):
                    f.write('\n')
        return None
    except Exception as e:
        raise Exception(f"Failed to write lines to '{filepath}': {str(e)}")


def dir_list(dirpath='.'):
    """
    ディレクトリ内のファイルとフォルダをリスト
    Returns: ファイル名のリスト
    """
    try:
        import os
        return os.listdir(dirpath)
    except Exception as e:
        raise Exception(f"Failed to list directory '{dirpath}': {str(e)}")


def dir_create(dirpath):
    """
    ディレクトリを作成
    """
    try:
        import os
        os.makedirs(dirpath, exist_ok=True)
        return None
    except Exception as e:
        raise Exception(f"Failed to create directory '{dirpath}': {str(e)}")


def dir_exists(dirpath):
    """
    ディレクトリが存在するかチェック
    """
    import os
    return os.path.isdir(dirpath)


def path_join(*paths):
    """
    パスを結合
    """
    import os
    return os.path.join(*[str(p) for p in paths])


def path_basename(filepath):
    """
    ファイル名を取得（パスから）
    """
    import os
    return os.path.basename(str(filepath))


def path_dirname(filepath):
    """
    ディレクトリ名を取得（パスから）
    """
    import os
    return os.path.dirname(str(filepath))


def path_ext(filepath):
    """
    拡張子を取得
    """
    import os
    return os.path.splitext(str(filepath))[1]


def setup_file_builtins(env):
    """Setup file I/O functions in the global environment"""
    env.define('file_read', file_read)
    env.define('file_write', file_write)
    env.define('file_append', file_append)
    env.define('file_exists', file_exists)
    env.define('file_delete', file_delete)
    env.define('file_readlines', file_readlines)
    env.define('file_writelines', file_writelines)
    env.define('dir_list', dir_list)
    env.define('dir_create', dir_create)
    env.define('dir_exists', dir_exists)
    env.define('path_join', path_join)
    env.define('path_basename', path_basename)
    env.define('path_dirname', path_dirname)
    env.define('path_ext', path_ext)


# Export functions for Mumei interpreter
FILE_FUNCTIONS = {
    'file_read': file_read,
    'file_write': file_write,
    'file_append': file_append,
    'file_exists': file_exists,
    'file_delete': file_delete,
    'file_readlines': file_readlines,
    'file_writelines': file_writelines,
    'dir_list': dir_list,
    'dir_create': dir_create,
    'dir_exists': dir_exists,
    'path_join': path_join,
    'path_basename': path_basename,
    'path_dirname': path_dirname,
    'path_ext': path_ext,
}
