use pyo3::prelude::*;
use pyo3::types::PyDict;
use serde_json::json;
use std::collections::HashMap;
use std::sync::Mutex;
use once_cell::sync::Lazy;

const DISCORD_API_BASE: &str = "https://discord.com/api/v10";

/// Global Discord bot token
static BOT_TOKEN: Lazy<Mutex<Option<String>>> = Lazy::new(|| Mutex::new(None));

/// Set Discord bot token
#[pyfunction]
pub fn discord_set_token(token: String) -> PyResult<()> {
    let mut global_token = BOT_TOKEN.lock().unwrap();
    *global_token = Some(token);
    Ok(())
}

/// Get authorization header with bot token
fn get_auth_header() -> Result<HashMap<String, String>, String> {
    let global_token = BOT_TOKEN.lock().unwrap();

    if let Some(token) = global_token.as_ref() {
        let mut headers = HashMap::new();
        headers.insert("Authorization".to_string(), format!("Bot {}", token));
        headers.insert("Content-Type".to_string(), "application/json".to_string());
        Ok(headers)
    } else {
        Err("Discord token not set. Call discord_set_token() first.".to_string())
    }
}

/// Send message to a channel
#[pyfunction]
pub fn discord_send_message(channel_id: String, content: String) -> PyResult<String> {
    let url = format!("{}/channels/{}/messages", DISCORD_API_BASE, channel_id);
    let body = json!({
        "content": content
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    // Use the HTTP module
    crate::http::http_post_json(url, body, None)
}

/// Send embed message to a channel
#[pyfunction]
pub fn discord_send_embed(
    channel_id: String,
    title: String,
    description: String,
    color: i64,
) -> PyResult<String> {
    let url = format!("{}/channels/{}/messages", DISCORD_API_BASE, channel_id);
    let body = json!({
        "embeds": [{
            "title": title,
            "description": description,
            "color": color
        }]
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_post_json(url, body, None)
}

/// Get channel information
#[pyfunction]
pub fn discord_get_channel(py: Python, channel_id: String) -> PyResult<PyObject> {
    let url = format!("{}/channels/{}", DISCORD_API_BASE, channel_id);

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let response = crate::http::http_get(url, None)?;
    crate::http::json_parse(py, response)
}

/// Get guild (server) information
#[pyfunction]
pub fn discord_get_guild(py: Python, guild_id: String) -> PyResult<PyObject> {
    let url = format!("{}/guilds/{}", DISCORD_API_BASE, guild_id);

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let response = crate::http::http_get(url, None)?;
    crate::http::json_parse(py, response)
}

/// Delete a message
#[pyfunction]
pub fn discord_delete_message(channel_id: String, message_id: String) -> PyResult<String> {
    let url = format!("{}/channels/{}/messages/{}", DISCORD_API_BASE, channel_id, message_id);

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_delete(url, None)
}

/// Edit a message
#[pyfunction]
pub fn discord_edit_message(
    channel_id: String,
    message_id: String,
    new_content: String,
) -> PyResult<String> {
    let url = format!("{}/channels/{}/messages/{}", DISCORD_API_BASE, channel_id, message_id);
    let body = json!({
        "content": new_content
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_patch(url, body, None)
}

/// Add reaction to a message
#[pyfunction]
pub fn discord_add_reaction(
    channel_id: String,
    message_id: String,
    emoji: String,
) -> PyResult<String> {
    // URL encode emoji
    let encoded_emoji = urlencoding::encode(&emoji);
    let url = format!(
        "{}/channels/{}/messages/{}/reactions/{}/@me",
        DISCORD_API_BASE, channel_id, message_id, encoded_emoji
    );

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_put(url, String::new(), None)
}

/// Create a text channel
#[pyfunction]
pub fn discord_create_text_channel(guild_id: String, name: String) -> PyResult<String> {
    let url = format!("{}/guilds/{}/channels", DISCORD_API_BASE, guild_id);
    let body = json!({
        "name": name,
        "type": 0  // 0 = GUILD_TEXT
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_post_json(url, body, None)
}

/// Create a voice channel
#[pyfunction]
pub fn discord_create_voice_channel(guild_id: String, name: String) -> PyResult<String> {
    let url = format!("{}/guilds/{}/channels", DISCORD_API_BASE, guild_id);
    let body = json!({
        "name": name,
        "type": 2  // 2 = GUILD_VOICE
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_post_json(url, body, None)
}

/// Delete a channel
#[pyfunction]
pub fn discord_delete_channel(channel_id: String) -> PyResult<String> {
    let url = format!("{}/channels/{}", DISCORD_API_BASE, channel_id);

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_delete(url, None)
}

/// Modify a channel (rename, etc.)
#[pyfunction]
pub fn discord_rename_channel(channel_id: String, new_name: String) -> PyResult<String> {
    let url = format!("{}/channels/{}", DISCORD_API_BASE, channel_id);
    let body = json!({
        "name": new_name
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_patch(url, body, None)
}

/// Create a role
#[pyfunction]
pub fn discord_create_role(guild_id: String, name: String, color: i64) -> PyResult<String> {
    let url = format!("{}/guilds/{}/roles", DISCORD_API_BASE, guild_id);
    let body = json!({
        "name": name,
        "color": color
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_post_json(url, body, None)
}

/// Add role to member
#[pyfunction]
pub fn discord_add_role_to_member(
    guild_id: String,
    user_id: String,
    role_id: String,
) -> PyResult<String> {
    let url = format!(
        "{}/guilds/{}/members/{}/roles/{}",
        DISCORD_API_BASE, guild_id, user_id, role_id
    );

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_put(url, String::new(), None)
}

/// Remove role from member
#[pyfunction]
pub fn discord_remove_role_from_member(
    guild_id: String,
    user_id: String,
    role_id: String,
) -> PyResult<String> {
    let url = format!(
        "{}/guilds/{}/members/{}/roles/{}",
        DISCORD_API_BASE, guild_id, user_id, role_id
    );

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_delete(url, None)
}

/// Kick member from guild
#[pyfunction]
pub fn discord_kick_member(guild_id: String, user_id: String, reason: Option<String>) -> PyResult<String> {
    let url = format!("{}/guilds/{}/members/{}", DISCORD_API_BASE, guild_id, user_id);

    let mut headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    if let Some(r) = reason {
        headers.insert("X-Audit-Log-Reason".to_string(), r);
    }

    crate::http::http_delete(url, None)
}

/// Ban member from guild
#[pyfunction]
pub fn discord_ban_member(guild_id: String, user_id: String, reason: Option<String>) -> PyResult<String> {
    let url = format!("{}/guilds/{}/bans/{}", DISCORD_API_BASE, guild_id, user_id);

    let mut headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    if let Some(r) = reason {
        headers.insert("X-Audit-Log-Reason".to_string(), r);
    }

    let body = json!({}).to_string();
    crate::http::http_put(url, body, None)
}

/// Set member nickname
#[pyfunction]
pub fn discord_set_nickname(guild_id: String, user_id: String, nickname: String) -> PyResult<String> {
    let url = format!("{}/guilds/{}/members/{}", DISCORD_API_BASE, guild_id, user_id);
    let body = json!({
        "nick": nickname
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    crate::http::http_patch(url, body, None)
}

/// Get message history
#[pyfunction]
pub fn discord_get_message_history(
    py: Python,
    channel_id: String,
    limit: Option<i32>,
) -> PyResult<PyObject> {
    let limit_param = limit.unwrap_or(50).min(100);
    let url = format!(
        "{}/channels/{}/messages?limit={}",
        DISCORD_API_BASE, channel_id, limit_param
    );

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let response = crate::http::http_get(url, None)?;
    crate::http::json_parse(py, response)
}

/// Send message via webhook
#[pyfunction]
pub fn discord_webhook_post(webhook_url: String, content: String) -> PyResult<String> {
    let body = json!({
        "content": content
    }).to_string();

    crate::http::http_post_json(webhook_url, body, None)
}

/// Send embed via webhook
#[pyfunction]
pub fn discord_webhook_post_embed(webhook_url: String, embed_data: String) -> PyResult<String> {
    // embed_data should already be JSON
    crate::http::http_post_json(webhook_url, embed_data, None)
}

/// Create webhook
#[pyfunction]
pub fn discord_create_webhook(py: Python, channel_id: String, name: String) -> PyResult<PyObject> {
    let url = format!("{}/channels/{}/webhooks", DISCORD_API_BASE, channel_id);
    let body = json!({
        "name": name
    }).to_string();

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let response = crate::http::http_post_json(url, body, None)?;
    crate::http::json_parse(py, response)
}

/// Get user information
#[pyfunction]
pub fn discord_get_user(py: Python, user_id: String) -> PyResult<PyObject> {
    let url = format!("{}/users/{}", DISCORD_API_BASE, user_id);

    let headers = get_auth_header()
        .map_err(|e| PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(e))?;

    let response = crate::http::http_get(url, None)?;
    crate::http::json_parse(py, response)
}

/// Register Discord functions with Python module
pub fn register_discord_functions(m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(discord_set_token, m)?)?;
    m.add_function(wrap_pyfunction!(discord_send_message, m)?)?;
    m.add_function(wrap_pyfunction!(discord_send_embed, m)?)?;
    m.add_function(wrap_pyfunction!(discord_get_channel, m)?)?;
    m.add_function(wrap_pyfunction!(discord_get_guild, m)?)?;
    m.add_function(wrap_pyfunction!(discord_delete_message, m)?)?;
    m.add_function(wrap_pyfunction!(discord_edit_message, m)?)?;
    m.add_function(wrap_pyfunction!(discord_add_reaction, m)?)?;
    m.add_function(wrap_pyfunction!(discord_create_text_channel, m)?)?;
    m.add_function(wrap_pyfunction!(discord_create_voice_channel, m)?)?;
    m.add_function(wrap_pyfunction!(discord_delete_channel, m)?)?;
    m.add_function(wrap_pyfunction!(discord_rename_channel, m)?)?;
    m.add_function(wrap_pyfunction!(discord_create_role, m)?)?;
    m.add_function(wrap_pyfunction!(discord_add_role_to_member, m)?)?;
    m.add_function(wrap_pyfunction!(discord_remove_role_from_member, m)?)?;
    m.add_function(wrap_pyfunction!(discord_kick_member, m)?)?;
    m.add_function(wrap_pyfunction!(discord_ban_member, m)?)?;
    m.add_function(wrap_pyfunction!(discord_set_nickname, m)?)?;
    m.add_function(wrap_pyfunction!(discord_get_message_history, m)?)?;
    m.add_function(wrap_pyfunction!(discord_webhook_post, m)?)?;
    m.add_function(wrap_pyfunction!(discord_webhook_post_embed, m)?)?;
    m.add_function(wrap_pyfunction!(discord_create_webhook, m)?)?;
    m.add_function(wrap_pyfunction!(discord_get_user, m)?)?;
    Ok(())
}
