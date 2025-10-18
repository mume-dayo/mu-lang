use pyo3::prelude::*;
use pyo3::types::{PyDict, PyList};
use reqwest::blocking::{Client, Response};
use reqwest::header::{HeaderMap, HeaderName, HeaderValue, AUTHORIZATION, CONTENT_TYPE};
use serde_json::Value as JsonValue;
use std::collections::HashMap;
use std::time::Duration;

/// HTTP Client for making REST API requests
pub struct HttpClient {
    client: Client,
    default_headers: HeaderMap,
}

impl HttpClient {
    pub fn new() -> Result<Self, String> {
        let client = Client::builder()
            .timeout(Duration::from_secs(30))
            .build()
            .map_err(|e| format!("Failed to create HTTP client: {}", e))?;

        Ok(HttpClient {
            client,
            default_headers: HeaderMap::new(),
        })
    }

    pub fn set_default_header(&mut self, key: &str, value: &str) -> Result<(), String> {
        let header_name = HeaderName::from_bytes(key.as_bytes())
            .map_err(|e| format!("Invalid header name: {}", e))?;
        let header_value = HeaderValue::from_str(value)
            .map_err(|e| format!("Invalid header value: {}", e))?;

        self.default_headers.insert(header_name, header_value);
        Ok(())
    }

    pub fn get(&self, url: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.get(url);

        // Add default headers
        request = request.headers(self.default_headers.clone());

        // Add custom headers
        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .send()
            .map_err(|e| format!("GET request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }

    pub fn post(&self, url: &str, body: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.post(url);

        // Add default headers
        request = request.headers(self.default_headers.clone());

        // Add custom headers
        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .body(body.to_string())
            .send()
            .map_err(|e| format!("POST request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }

    pub fn post_json(&self, url: &str, json_body: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.post(url);

        // Add default headers
        request = request.headers(self.default_headers.clone());
        request = request.header(CONTENT_TYPE, "application/json");

        // Add custom headers
        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .body(json_body.to_string())
            .send()
            .map_err(|e| format!("POST JSON request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }

    pub fn put(&self, url: &str, body: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.put(url);

        request = request.headers(self.default_headers.clone());

        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .body(body.to_string())
            .send()
            .map_err(|e| format!("PUT request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }

    pub fn delete(&self, url: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.delete(url);

        request = request.headers(self.default_headers.clone());

        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .send()
            .map_err(|e| format!("DELETE request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }

    pub fn patch(&self, url: &str, body: &str, headers: Option<HashMap<String, String>>) -> Result<String, String> {
        let mut request = self.client.patch(url);

        request = request.headers(self.default_headers.clone());

        if let Some(custom_headers) = headers {
            for (key, value) in custom_headers {
                request = request.header(key, value);
            }
        }

        let response = request
            .body(body.to_string())
            .send()
            .map_err(|e| format!("PATCH request failed: {}", e))?;

        response
            .text()
            .map_err(|e| format!("Failed to read response: {}", e))
    }
}

// Global HTTP client instance
use once_cell::sync::Lazy;
use std::sync::Mutex;

static HTTP_CLIENT: Lazy<Mutex<Option<HttpClient>>> = Lazy::new(|| Mutex::new(None));

/// Initialize HTTP client
#[pyfunction]
pub fn http_init() -> PyResult<bool> {
    let client = HttpClient::new()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let mut global_client = HTTP_CLIENT.lock().unwrap();
    *global_client = Some(client);

    Ok(true)
}

/// Set default header for all requests
#[pyfunction]
pub fn http_set_header(key: String, value: String) -> PyResult<bool> {
    let mut global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_mut() {
        client.set_default_header(&key, &value)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;
        Ok(true)
    } else {
        Err(PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(
            "HTTP client not initialized. Call http_init() first."
        ))
    }
}

/// Convert Python dict to HashMap
fn py_dict_to_hashmap(py_dict: &PyDict) -> HashMap<String, String> {
    let mut map = HashMap::new();
    for (key, value) in py_dict.iter() {
        if let (Ok(k), Ok(v)) = (key.extract::<String>(), value.extract::<String>()) {
            map.insert(k, v);
        }
    }
    map
}

/// HTTP GET request
#[pyfunction]
pub fn http_get(url: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.get(&url, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_get(url, headers)
    }
}

/// HTTP POST request
#[pyfunction]
pub fn http_post(url: String, body: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.post(&url, &body, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_post(url, body, headers)
    }
}

/// HTTP POST JSON request
#[pyfunction]
pub fn http_post_json(url: String, json_body: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.post_json(&url, &json_body, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_post_json(url, json_body, headers)
    }
}

/// HTTP PUT request
#[pyfunction]
pub fn http_put(url: String, body: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.put(&url, &body, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_put(url, body, headers)
    }
}

/// HTTP DELETE request
#[pyfunction]
pub fn http_delete(url: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.delete(&url, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_delete(url, headers)
    }
}

/// HTTP PATCH request
#[pyfunction]
pub fn http_patch(url: String, body: String, headers: Option<&PyDict>) -> PyResult<String> {
    let global_client = HTTP_CLIENT.lock().unwrap();

    if let Some(client) = global_client.as_ref() {
        let headers_map = headers.map(py_dict_to_hashmap);
        client.patch(&url, &body, headers_map)
            .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))
    } else {
        http_init()?;
        drop(global_client);
        http_patch(url, body, headers)
    }
}

/// Parse JSON string to Python object
#[pyfunction]
pub fn json_parse(py: Python, json_str: String) -> PyResult<PyObject> {
    let value: JsonValue = serde_json::from_str(&json_str)
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyValueError, _>(format!("JSON parse error: {}", e)))?;

    json_value_to_py(py, &value)
}

/// Convert serde_json::Value to PyObject
fn json_value_to_py(py: Python, value: &JsonValue) -> PyResult<PyObject> {
    match value {
        JsonValue::Null => Ok(py.None()),
        JsonValue::Bool(b) => Ok(b.to_object(py)),
        JsonValue::Number(n) => {
            if let Some(i) = n.as_i64() {
                Ok(i.to_object(py))
            } else if let Some(f) = n.as_f64() {
                Ok(f.to_object(py))
            } else {
                Ok(n.to_string().to_object(py))
            }
        }
        JsonValue::String(s) => Ok(s.to_object(py)),
        JsonValue::Array(arr) => {
            let py_list = PyList::empty(py);
            for item in arr {
                py_list.append(json_value_to_py(py, item)?)?;
            }
            Ok(py_list.to_object(py))
        }
        JsonValue::Object(obj) => {
            let py_dict = PyDict::new(py);
            for (key, val) in obj {
                py_dict.set_item(key, json_value_to_py(py, val)?)?;
            }
            Ok(py_dict.to_object(py))
        }
    }
}

/// Stringify Python object to JSON
#[pyfunction]
pub fn json_stringify(py: Python, obj: PyObject) -> PyResult<String> {
    let value = py_object_to_json_value(py, &obj)?;
    serde_json::to_string(&value)
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyValueError, _>(format!("JSON stringify error: {}", e)))
}

/// Convert PyObject to serde_json::Value
fn py_object_to_json_value(py: Python, obj: &PyObject) -> PyResult<JsonValue> {
    if obj.is_none(py) {
        return Ok(JsonValue::Null);
    }

    if let Ok(b) = obj.extract::<bool>(py) {
        return Ok(JsonValue::Bool(b));
    }

    if let Ok(i) = obj.extract::<i64>(py) {
        return Ok(JsonValue::Number(i.into()));
    }

    if let Ok(f) = obj.extract::<f64>(py) {
        if let Some(n) = serde_json::Number::from_f64(f) {
            return Ok(JsonValue::Number(n));
        }
    }

    if let Ok(s) = obj.extract::<String>(py) {
        return Ok(JsonValue::String(s));
    }

    if let Ok(list) = obj.downcast::<PyList>(py) {
        let mut arr = Vec::new();
        for item in list.iter() {
            arr.push(py_object_to_json_value(py, &item.to_object(py))?);
        }
        return Ok(JsonValue::Array(arr));
    }

    if let Ok(dict) = obj.downcast::<PyDict>(py) {
        let mut map = serde_json::Map::new();
        for (key, value) in dict.iter() {
            if let Ok(k) = key.extract::<String>() {
                map.insert(k, py_object_to_json_value(py, &value.to_object(py))?);
            }
        }
        return Ok(JsonValue::Object(map));
    }

    Err(PyErr::new::<pyo3::exceptions::PyTypeError, _>(
        "Unsupported type for JSON serialization"
    ))
}

/// Register HTTP functions with Python module
pub fn register_http_functions(m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(http_init, m)?)?;
    m.add_function(wrap_pyfunction!(http_set_header, m)?)?;
    m.add_function(wrap_pyfunction!(http_get, m)?)?;
    m.add_function(wrap_pyfunction!(http_post, m)?)?;
    m.add_function(wrap_pyfunction!(http_post_json, m)?)?;
    m.add_function(wrap_pyfunction!(http_put, m)?)?;
    m.add_function(wrap_pyfunction!(http_delete, m)?)?;
    m.add_function(wrap_pyfunction!(http_patch, m)?)?;
    m.add_function(wrap_pyfunction!(json_parse, m)?)?;
    m.add_function(wrap_pyfunction!(json_stringify, m)?)?;
    Ok(())
}
