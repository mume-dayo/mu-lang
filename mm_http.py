"""
Mumei HTTP Request Module
HTTP request functionality for Mumei language
統一された設計: 非同期サポート、型チェック、エラーハンドリング、柔軟な引数
"""

import urllib.request
import urllib.parse
import json
import asyncio
from typing import Optional, Dict, Any

def http_get(url, headers=None, timeout=None, async_mode=False):
    """
    HTTP GETリクエストを送信

    Args:
        url: リクエストURL（文字列）
        headers: HTTPヘッダー（辞書、オプショナル）
        timeout: タイムアウト秒数（float、オプショナル）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        str: レスポンスボディ（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Raises:
        TypeError: 引数の型が不正な場合
        ValueError: URLが不正な場合
        Exception: HTTPリクエスト失敗時

    Example:
        // 同期モード
        let response = http_get("https://api.example.com/data");

        // 非同期モード
        let task = http_get("https://api.example.com/data", null, null, true);
        let response = await task;

        // ヘッダー付き
        let headers = {"Authorization": "Bearer token123"};
        let response = http_get("https://api.example.com/data", headers);
    """
    # 型チェック
    if not isinstance(url, str):
        raise TypeError(f"http_get() url must be string, got {type(url).__name__}")

    if headers is not None and not isinstance(headers, dict):
        raise TypeError(f"http_get() headers must be dict or None, got {type(headers).__name__}")

    if timeout is not None and not isinstance(timeout, (int, float)):
        raise TypeError(f"http_get() timeout must be numeric or None, got {type(timeout).__name__}")

    if not url.startswith(('http://', 'https://')):
        raise ValueError(f"http_get() url must start with http:// or https://, got: {url}")

    def _sync_get():
        try:
            req = urllib.request.Request(url, method='GET')

            if headers:
                for key, value in headers.items():
                    req.add_header(str(key), str(value))

            timeout_val = float(timeout) if timeout else None
            with urllib.request.urlopen(req, timeout=timeout_val) as response:
                body = response.read().decode('utf-8')
                return body
        except urllib.error.HTTPError as e:
            raise Exception(f"HTTP GET failed with status {e.code}: {e.reason}")
        except urllib.error.URLError as e:
            raise Exception(f"HTTP GET failed: {e.reason}")
        except Exception as e:
            raise Exception(f"HTTP GET request failed: {str(e)}")

    if async_mode:
        async def _async_get():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_get)
        return asyncio.create_task(_async_get())
    else:
        return _sync_get()


def http_post(url, data=None, headers=None, timeout=None, async_mode=False):
    """
    HTTP POSTリクエストを送信

    Args:
        url: リクエストURL
        data: 送信データ（dict、str、またはNone）
        headers: HTTPヘッダー（dict、オプショナル）
        timeout: タイムアウト秒数（float、オプショナル）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        str: レスポンスボディ（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Example:
        // JSON送信
        let data = {"name": "John", "age": 30};
        let response = http_post("https://api.example.com/users", data);

        // 非同期POST
        let task = http_post("https://api.example.com/users", data, null, null, true);
        let response = await task;
    """
    # 型チェック
    if not isinstance(url, str):
        raise TypeError(f"http_post() url must be string, got {type(url).__name__}")

    if data is not None and not isinstance(data, (dict, str, bytes)):
        raise TypeError(f"http_post() data must be dict, str, bytes, or None, got {type(data).__name__}")

    if headers is not None and not isinstance(headers, dict):
        raise TypeError(f"http_post() headers must be dict or None, got {type(headers).__name__}")

    if timeout is not None and not isinstance(timeout, (int, float)):
        raise TypeError(f"http_post() timeout must be numeric or None, got {type(timeout).__name__}")

    if not url.startswith(('http://', 'https://')):
        raise ValueError(f"http_post() url must start with http:// or https://, got: {url}")

    def _sync_post():
        try:
            # データをバイトに変換
            encoded_data = b''
            content_type = None

            if isinstance(data, dict):
                encoded_data = json.dumps(data).encode('utf-8')
                content_type = 'application/json'
            elif isinstance(data, str):
                encoded_data = data.encode('utf-8')
            elif isinstance(data, bytes):
                encoded_data = data
            elif data is not None:
                encoded_data = str(data).encode('utf-8')

            req = urllib.request.Request(url, data=encoded_data, method='POST')

            # Content-Typeを設定
            if content_type:
                req.add_header('Content-Type', content_type)

            if headers:
                for key, value in headers.items():
                    req.add_header(str(key), str(value))

            timeout_val = float(timeout) if timeout else None
            with urllib.request.urlopen(req, timeout=timeout_val) as response:
                body = response.read().decode('utf-8')
                return body
        except urllib.error.HTTPError as e:
            raise Exception(f"HTTP POST failed with status {e.code}: {e.reason}")
        except urllib.error.URLError as e:
            raise Exception(f"HTTP POST failed: {e.reason}")
        except Exception as e:
            raise Exception(f"HTTP POST request failed: {str(e)}")

    if async_mode:
        async def _async_post():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_post)
        return asyncio.create_task(_async_post())
    else:
        return _sync_post()


def http_request(method, url, data=None, headers=None, timeout=None, async_mode=False):
    """
    カスタムメソッドでHTTPリクエストを送信

    Args:
        method: HTTPメソッド（GET, POST, PUT, DELETE, PATCH等）
        url: リクエストURL
        data: 送信データ（dict、str、またはNone）
        headers: HTTPヘッダー（dict、オプショナル）
        timeout: タイムアウト秒数（float、オプショナル）
        async_mode: 非同期実行するか（bool、デフォルトFalse）

    Returns:
        str: レスポンスボディ（同期モード）
        asyncio.Task: 非同期タスク（非同期モード）

    Example:
        // PUT request
        let response = http_request("PUT", "https://api.example.com/users/1", data);

        // DELETE request
        let response = http_request("DELETE", "https://api.example.com/users/1");

        // PATCH request (async)
        let task = http_request("PATCH", url, data, null, null, true);
        let response = await task;
    """
    # 型チェック
    if not isinstance(method, str):
        raise TypeError(f"http_request() method must be string, got {type(method).__name__}")

    if not isinstance(url, str):
        raise TypeError(f"http_request() url must be string, got {type(url).__name__}")

    if data is not None and not isinstance(data, (dict, str, bytes)):
        raise TypeError(f"http_request() data must be dict, str, bytes, or None, got {type(data).__name__}")

    if headers is not None and not isinstance(headers, dict):
        raise TypeError(f"http_request() headers must be dict or None, got {type(headers).__name__}")

    if timeout is not None and not isinstance(timeout, (int, float)):
        raise TypeError(f"http_request() timeout must be numeric or None, got {type(timeout).__name__}")

    if not url.startswith(('http://', 'https://')):
        raise ValueError(f"http_request() url must start with http:// or https://, got: {url}")

    def _sync_request():
        try:
            # データをバイトに変換
            encoded_data = None
            content_type = None

            if data:
                if isinstance(data, dict):
                    encoded_data = json.dumps(data).encode('utf-8')
                    content_type = 'application/json'
                elif isinstance(data, str):
                    encoded_data = data.encode('utf-8')
                elif isinstance(data, bytes):
                    encoded_data = data

            req = urllib.request.Request(url, data=encoded_data, method=method.upper())

            # Content-Typeを設定
            if content_type:
                req.add_header('Content-Type', content_type)

            if headers:
                for key, value in headers.items():
                    req.add_header(str(key), str(value))

            timeout_val = float(timeout) if timeout else None
            with urllib.request.urlopen(req, timeout=timeout_val) as response:
                body = response.read().decode('utf-8')
                return body
        except urllib.error.HTTPError as e:
            raise Exception(f"HTTP {method} failed with status {e.code}: {e.reason}")
        except urllib.error.URLError as e:
            raise Exception(f"HTTP {method} failed: {e.reason}")
        except Exception as e:
            raise Exception(f"HTTP {method} request failed: {str(e)}")

    if async_mode:
        async def _async_request():
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, _sync_request)
        return asyncio.create_task(_async_request())
    else:
        return _sync_request()

def json_parse(json_string):
    """
    JSON文字列をパース

    Args:
        json_string: JSON文字列

    Returns:
        dict/list: パースされたオブジェクト

    Raises:
        TypeError: 引数が文字列でない場合
        Exception: パース失敗時

    Example:
        let json_str = '{"name": "John", "age": 30}';
        let data = json_parse(json_str);
        print(data.name);  // "John"
    """
    if not isinstance(json_string, str):
        raise TypeError(f"json_parse() expects string, got {type(json_string).__name__}")

    try:
        return json.loads(json_string)
    except json.JSONDecodeError as e:
        raise Exception(f"JSON parse failed at position {e.pos}: {e.msg}")
    except Exception as e:
        raise Exception(f"JSON parse failed: {str(e)}")


def json_stringify(obj, indent=None, ensure_ascii=True):
    """
    オブジェクトをJSON文字列に変換

    Args:
        obj: 変換するオブジェクト（dict, list等）
        indent: インデント幅（int、オプショナル。整形する場合は2や4を指定）
        ensure_ascii: ASCII文字のみにするか（bool、デフォルトTrue）

    Returns:
        str: JSON文字列

    Raises:
        Exception: 変換失敗時

    Example:
        let data = {"name": "John", "age": 30};
        let json_str = json_stringify(data);

        // 整形して出力
        let pretty_json = json_stringify(data, 2);
        print(pretty_json);
    """
    if indent is not None and not isinstance(indent, int):
        raise TypeError(f"json_stringify() indent must be int or None, got {type(indent).__name__}")

    try:
        return json.dumps(obj, indent=indent, ensure_ascii=ensure_ascii)
    except TypeError as e:
        raise Exception(f"JSON stringify failed: Object not serializable - {str(e)}")
    except Exception as e:
        raise Exception(f"JSON stringify failed: {str(e)}")

def setup_http_builtins(env):
    """Setup HTTP functions in the global environment"""
    env.define('http_get', http_get)
    env.define('http_post', http_post)
    env.define('http_request', http_request)
    env.define('json_parse', json_parse)
    env.define('json_stringify', json_stringify)

# Export functions for Mumei interpreter
HTTP_FUNCTIONS = {
    'http_get': http_get,
    'http_post': http_post,
    'http_request': http_request,
    'json_parse': json_parse,
    'json_stringify': json_stringify,
}
