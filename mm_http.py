"""
Mumei HTTP Request Module
HTTP request functionality for Mumei language
"""

import urllib.request
import urllib.parse
import json

def http_get(url, headers=None):
    """
    Send HTTP GET request
    Returns: response body as string
    """
    try:
        req = urllib.request.Request(url, method='GET')

        if headers:
            for key, value in headers.items():
                req.add_header(key, value)

        with urllib.request.urlopen(req) as response:
            body = response.read().decode('utf-8')
            return body
    except Exception as e:
        raise Exception(f"HTTP GET request failed: {str(e)}")

def http_post(url, data=None, headers=None):
    """
    Send HTTP POST request
    data: dict or string
    Returns: response body as string
    """
    try:
        # Convert data to bytes
        if isinstance(data, dict):
            data = json.dumps(data).encode('utf-8')
        elif isinstance(data, str):
            data = data.encode('utf-8')
        elif data is None:
            data = b''

        req = urllib.request.Request(url, data=data, method='POST')

        # Add default content-type for JSON
        if isinstance(data, dict):
            req.add_header('Content-Type', 'application/json')

        if headers:
            for key, value in headers.items():
                req.add_header(key, value)

        with urllib.request.urlopen(req) as response:
            body = response.read().decode('utf-8')
            return body
    except Exception as e:
        raise Exception(f"HTTP POST request failed: {str(e)}")

def http_request(method, url, data=None, headers=None):
    """
    Send HTTP request with custom method
    method: GET, POST, PUT, DELETE, etc.
    data: dict or string
    headers: dict
    Returns: response body as string
    """
    try:
        # Convert data to bytes
        encoded_data = None
        if data:
            if isinstance(data, dict):
                encoded_data = json.dumps(data).encode('utf-8')
            elif isinstance(data, str):
                encoded_data = data.encode('utf-8')

        req = urllib.request.Request(url, data=encoded_data, method=method.upper())

        # Add default content-type for JSON
        if isinstance(data, dict):
            req.add_header('Content-Type', 'application/json')

        if headers:
            for key, value in headers.items():
                req.add_header(key, value)

        with urllib.request.urlopen(req) as response:
            body = response.read().decode('utf-8')
            return body
    except Exception as e:
        raise Exception(f"HTTP {method} request failed: {str(e)}")

def json_parse(json_string):
    """Parse JSON string to dict"""
    try:
        return json.loads(json_string)
    except Exception as e:
        raise Exception(f"JSON parse failed: {str(e)}")

def json_stringify(obj):
    """Convert dict to JSON string"""
    try:
        return json.dumps(obj)
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
