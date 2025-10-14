"""
Mumei Standard Library Module
Python standard library functions for Mumei language
"""

import math
import random
import datetime
import re


# Math functions
def math_abs(x):
    """絶対値"""
    return abs(x)


def math_ceil(x):
    """切り上げ"""
    return math.ceil(x)


def math_floor(x):
    """切り捨て"""
    return math.floor(x)


def math_round(x, digits=0):
    """四捨五入"""
    return round(x, digits)


def math_sqrt(x):
    """平方根"""
    return math.sqrt(x)


def math_pow(x, y):
    """累乗"""
    return pow(x, y)


def math_max(*args):
    """最大値"""
    if len(args) == 1 and isinstance(args[0], list):
        return max(args[0])
    return max(args)


def math_min(*args):
    """最小値"""
    if len(args) == 1 and isinstance(args[0], list):
        return min(args[0])
    return min(args)


def math_sum(iterable):
    """合計"""
    return sum(iterable)


def math_sin(x):
    """サイン"""
    return math.sin(x)


def math_cos(x):
    """コサイン"""
    return math.cos(x)


def math_tan(x):
    """タンジェント"""
    return math.tan(x)


def math_pi():
    """円周率"""
    return math.pi


def math_e():
    """自然対数の底"""
    return math.e


# Random functions
def random_random():
    """0.0〜1.0のランダムな浮動小数点数"""
    return random.random()


def random_randint(a, b):
    """a〜bのランダムな整数"""
    return random.randint(a, b)


def random_choice(seq):
    """リストからランダムに1つ選択"""
    return random.choice(seq)


def random_shuffle(seq):
    """リストをシャッフル"""
    result = list(seq)
    random.shuffle(result)
    return result


def random_seed(x):
    """乱数シードを設定"""
    random.seed(x)
    return None


# String functions
def str_upper(s):
    """大文字に変換"""
    return str(s).upper()


def str_lower(s):
    """小文字に変換"""
    return str(s).lower()


def str_capitalize(s):
    """先頭を大文字に"""
    return str(s).capitalize()


def str_strip(s):
    """前後の空白を削除"""
    return str(s).strip()


def str_split(s, sep=None):
    """文字列を分割"""
    return str(s).split(sep)


def str_join(sep, iterable):
    """リストを文字列で結合"""
    return str(sep).join([str(x) for x in iterable])


def str_replace(s, old, new):
    """文字列を置換"""
    return str(s).replace(str(old), str(new))


def str_startswith(s, prefix):
    """指定の文字列で始まるかチェック"""
    return str(s).startswith(str(prefix))


def str_endswith(s, suffix):
    """指定の文字列で終わるかチェック"""
    return str(s).endswith(str(suffix))


def str_find(s, sub):
    """部分文字列の位置を検索"""
    return str(s).find(str(sub))


def str_count(s, sub):
    """部分文字列の出現回数"""
    return str(s).count(str(sub))


# List functions
def list_reverse(lst):
    """リストを反転"""
    result = list(lst)
    result.reverse()
    return result


def list_sort(lst):
    """リストをソート"""
    result = list(lst)
    result.sort()
    return result


def list_clear(lst):
    """リストをクリア"""
    lst.clear()
    return None


def list_copy(lst):
    """リストをコピー"""
    return list(lst).copy()


def list_extend(lst, iterable):
    """リストを拡張"""
    lst.extend(iterable)
    return None


def list_insert(lst, index, item):
    """指定位置に挿入"""
    lst.insert(index, item)
    return None


def list_remove(lst, item):
    """最初に見つかった要素を削除"""
    lst.remove(item)
    return None


def list_index(lst, item):
    """要素のインデックスを取得"""
    return lst.index(item)


def list_count_item(lst, item):
    """要素の出現回数"""
    return lst.count(item)


# Dict functions
def dict_keys(d):
    """辞書のキーのリスト"""
    return list(d.keys())


def dict_values(d):
    """辞書の値のリスト"""
    return list(d.values())


def dict_items(d):
    """辞書のキーと値のペアのリスト"""
    return list(d.items())


def dict_get(d, key, default=None):
    """辞書から値を取得（キーがない場合はデフォルト値）"""
    return d.get(key, default)


def dict_has_key(d, key):
    """キーが存在するかチェック"""
    return key in d


def dict_clear(d):
    """辞書をクリア"""
    d.clear()
    return None


def dict_copy(d):
    """辞書をコピー"""
    return d.copy()


def dict_update(d, other):
    """辞書を更新"""
    d.update(other)
    return None


# Date/Time functions
def datetime_now():
    """現在の日時を文字列で取得"""
    return str(datetime.datetime.now())


def datetime_today():
    """今日の日付を文字列で取得"""
    return str(datetime.date.today())


def datetime_timestamp():
    """現在のUNIXタイムスタンプ"""
    return datetime.datetime.now().timestamp()


# Regular expression functions
def regex_match(pattern, string):
    """正規表現でマッチ"""
    match = re.match(pattern, string)
    return match is not None


def regex_search(pattern, string):
    """正規表現で検索"""
    match = re.search(pattern, string)
    if match:
        return match.group()
    return None


def regex_findall(pattern, string):
    """正規表現で全てマッチ"""
    return re.findall(pattern, string)


def regex_replace(pattern, repl, string):
    """正規表現で置換"""
    return re.sub(pattern, repl, string)


def setup_stdlib_builtins(env):
    """Setup standard library functions in the global environment"""
    # Math
    env.define('abs', math_abs)
    env.define('ceil', math_ceil)
    env.define('floor', math_floor)
    env.define('round', math_round)
    env.define('sqrt', math_sqrt)
    env.define('pow', math_pow)
    env.define('max', math_max)
    env.define('min', math_min)
    env.define('sum', math_sum)
    env.define('sin', math_sin)
    env.define('cos', math_cos)
    env.define('tan', math_tan)
    env.define('pi', math_pi)
    env.define('e', math_e)

    # Random
    env.define('random', random_random)
    env.define('randint', random_randint)
    env.define('choice', random_choice)
    env.define('shuffle', random_shuffle)
    env.define('seed', random_seed)

    # String
    env.define('upper', str_upper)
    env.define('lower', str_lower)
    env.define('capitalize', str_capitalize)
    env.define('strip', str_strip)
    env.define('split', str_split)
    env.define('join', str_join)
    env.define('replace', str_replace)
    env.define('startswith', str_startswith)
    env.define('endswith', str_endswith)
    env.define('find', str_find)
    env.define('count_str', str_count)

    # List
    env.define('reverse', list_reverse)
    env.define('sort', list_sort)
    env.define('list_clear', list_clear)
    env.define('list_copy', list_copy)
    env.define('extend', list_extend)
    env.define('insert', list_insert)
    env.define('remove', list_remove)
    env.define('list_index', list_index)
    env.define('count_item', list_count_item)

    # Dict
    env.define('keys', dict_keys)
    env.define('values', dict_values)
    env.define('items', dict_items)
    env.define('dict_get', dict_get)
    env.define('has_key', dict_has_key)
    env.define('dict_clear', dict_clear)
    env.define('dict_copy', dict_copy)
    env.define('dict_update', dict_update)

    # DateTime
    env.define('now', datetime_now)
    env.define('today', datetime_today)
    env.define('timestamp', datetime_timestamp)

    # Regex
    env.define('regex_match', regex_match)
    env.define('regex_search', regex_search)
    env.define('regex_findall', regex_findall)
    env.define('regex_replace', regex_replace)
