use pyo3::prelude::*;
use pyo3::types::{PyDict, PyList};
use tokio_tungstenite::{connect_async, tungstenite::Message};
use futures_util::{SinkExt, StreamExt};
use serde_json::{json, Value as JsonValue};
use std::sync::{Arc, Mutex};
use tokio::sync::mpsc;
use std::collections::HashMap;

const GATEWAY_URL: &str = "wss://gateway.discord.gg/?v=10&encoding=json";

/// Discord Gateway client
pub struct Gateway {
    token: String,
    intents: u32,
    session_id: Option<String>,
    sequence: Option<u64>,
}

/// Event handler type
type EventHandler = Arc<Mutex<Option<PyObject>>>;

/// Global event handlers
static EVENT_HANDLERS: once_cell::sync::Lazy<Arc<Mutex<HashMap<String, Vec<PyObject>>>>> =
    once_cell::sync::Lazy::new(|| Arc::new(Mutex::new(HashMap::new())));

/// Global gateway client
static GATEWAY_CLIENT: once_cell::sync::Lazy<Arc<Mutex<Option<String>>>> =
    once_cell::sync::Lazy::new(|| Arc::new(Mutex::new(None)));

impl Gateway {
    pub fn new(token: String, intents: u32) -> Self {
        Gateway {
            token,
            intents,
            session_id: None,
            sequence: None,
        }
    }

    /// Connect to Discord Gateway
    pub async fn connect(&mut self) -> Result<(), String> {
        let url = url::Url::parse(GATEWAY_URL)
            .map_err(|e| format!("Invalid gateway URL: {}", e))?;

        let (ws_stream, _) = connect_async(url)
            .await
            .map_err(|e| format!("WebSocket connection failed: {}", e))?;

        let (mut write, mut read) = ws_stream.split();

        // Send identify payload
        let identify = json!({
            "op": 2,
            "d": {
                "token": self.token,
                "intents": self.intents,
                "properties": {
                    "$os": "linux",
                    "$browser": "mumei-rust",
                    "$device": "mumei-rust"
                }
            }
        });

        write
            .send(Message::Text(identify.to_string()))
            .await
            .map_err(|e| format!("Failed to send identify: {}", e))?;

        // Event loop
        while let Some(msg) = read.next().await {
            match msg {
                Ok(Message::Text(text)) => {
                    self.handle_message(&text).await?;
                }
                Ok(Message::Close(_)) => {
                    println!("Gateway connection closed");
                    break;
                }
                Err(e) => {
                    return Err(format!("WebSocket error: {}", e));
                }
                _ => {}
            }
        }

        Ok(())
    }

    /// Handle incoming gateway message
    async fn handle_message(&mut self, text: &str) -> Result<(), String> {
        let payload: JsonValue = serde_json::from_str(text)
            .map_err(|e| format!("Failed to parse payload: {}", e))?;

        let op = payload["op"].as_u64().unwrap_or(0);
        let data = &payload["d"];
        let seq = payload["s"].as_u64();

        if let Some(s) = seq {
            self.sequence = Some(s);
        }

        match op {
            0 => {
                // Dispatch event
                let event_name = payload["t"].as_str().unwrap_or("");
                self.dispatch_event(event_name, data).await?;
            }
            1 => {
                // Heartbeat request
                // TODO: Send heartbeat
            }
            10 => {
                // Hello
                let heartbeat_interval = data["heartbeat_interval"].as_u64().unwrap_or(41250);
                println!("Gateway connected, heartbeat interval: {}ms", heartbeat_interval);
            }
            11 => {
                // Heartbeat ACK
                println!("Heartbeat ACK received");
            }
            _ => {
                println!("Unknown opcode: {}", op);
            }
        }

        Ok(())
    }

    /// Dispatch event to handlers
    async fn dispatch_event(&self, event_name: &str, data: &JsonValue) -> Result<(), String> {
        match event_name {
            "READY" => {
                println!("✅ Bot is ready!");
                if let Some(session_id) = data["session_id"].as_str() {
                    println!("   Session ID: {}", session_id);
                }
                trigger_event("ready", vec![]);
            }
            "MESSAGE_CREATE" => {
                trigger_event_with_data("message", data.clone());
            }
            "INTERACTION_CREATE" => {
                trigger_event_with_data("interaction", data.clone());
            }
            _ => {
                println!("Unhandled event: {}", event_name);
            }
        }

        Ok(())
    }
}

/// Trigger event with no data
fn trigger_event(event_name: &str, _args: Vec<PyObject>) {
    let handlers = EVENT_HANDLERS.lock().unwrap();
    if let Some(handler_list) = handlers.get(event_name) {
        for _handler in handler_list {
            // TODO: Call Python handler
            println!("Triggering event: {}", event_name);
        }
    }
}

/// Trigger event with JSON data
fn trigger_event_with_data(event_name: &str, data: JsonValue) {
    let handlers = EVENT_HANDLERS.lock().unwrap();
    if let Some(handler_list) = handlers.get(event_name) {
        for _handler in handler_list {
            // TODO: Convert JSON to Python object and call handler
            println!("Triggering event: {} with data", event_name);
        }
    }
}

/// Register event handler
#[pyfunction]
pub fn gateway_on(event_name: String, handler: PyObject) -> PyResult<()> {
    let mut handlers = EVENT_HANDLERS.lock().unwrap();
    handlers
        .entry(event_name.clone())
        .or_insert_with(Vec::new)
        .push(handler);

    println!("Registered handler for event: {}", event_name);
    Ok(())
}

/// Start Discord Gateway connection
#[pyfunction]
pub fn gateway_connect(token: String, intents: Option<u32>) -> PyResult<()> {
    let intents = intents.unwrap_or(32767); // Default: all intents

    // Store token
    let mut client = GATEWAY_CLIENT.lock().unwrap();
    *client = Some(token.clone());

    // Start gateway in background
    tokio::spawn(async move {
        let mut gateway = Gateway::new(token, intents);
        if let Err(e) = gateway.connect().await {
            eprintln!("Gateway error: {}", e);
        }
    });

    Ok(())
}

/// Send slash command registration
#[pyfunction]
pub fn gateway_register_slash_command(
    application_id: String,
    command_name: String,
    description: String,
    guild_id: Option<String>,
) -> PyResult<String> {
    let token = GATEWAY_CLIENT.lock().unwrap().clone();
    if token.is_none() {
        return Err(PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(
            "Gateway not connected"
        ));
    }

    let url = if let Some(gid) = guild_id {
        format!(
            "https://discord.com/api/v10/applications/{}/guilds/{}/commands",
            application_id, gid
        )
    } else {
        format!(
            "https://discord.com/api/v10/applications/{}/commands",
            application_id
        )
    };

    let body = json!({
        "name": command_name,
        "description": description,
        "type": 1
    })
    .to_string();

    let mut headers = HashMap::new();
    headers.insert("Authorization".to_string(), format!("Bot {}", token.unwrap()));

    crate::http::http_post_json(url, body, None)
}

/// Send interaction response
#[pyfunction]
pub fn gateway_interaction_respond(
    interaction_id: String,
    interaction_token: String,
    content: String,
) -> PyResult<String> {
    let url = format!(
        "https://discord.com/api/v10/interactions/{}/{}/callback",
        interaction_id, interaction_token
    );

    let body = json!({
        "type": 4,
        "data": {
            "content": content
        }
    })
    .to_string();

    crate::http::http_post_json(url, body, None)
}

/// Send message with button
#[pyfunction]
pub fn gateway_send_button(
    channel_id: String,
    content: String,
    button_label: String,
    button_custom_id: String,
    button_style: Option<i32>,
) -> PyResult<String> {
    let url = format!("https://discord.com/api/v10/channels/{}/messages", channel_id);

    let style = button_style.unwrap_or(1); // Default: Primary (blue)

    let body = json!({
        "content": content,
        "components": [{
            "type": 1,
            "components": [{
                "type": 2,
                "label": button_label,
                "style": style,
                "custom_id": button_custom_id
            }]
        }]
    })
    .to_string();

    let token = GATEWAY_CLIENT.lock().unwrap().clone();
    if token.is_none() {
        return Err(PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(
            "Gateway not connected"
        ));
    }

    let mut headers = HashMap::new();
    headers.insert("Authorization".to_string(), format!("Bot {}", token.unwrap()));

    crate::http::http_post_json(url, body, None)
}

/// Send message with select menu
#[pyfunction]
pub fn gateway_send_select(
    channel_id: String,
    content: String,
    custom_id: String,
    options: Vec<(String, String)>, // (label, value) pairs
) -> PyResult<String> {
    let url = format!("https://discord.com/api/v10/channels/{}/messages", channel_id);

    let select_options: Vec<JsonValue> = options
        .iter()
        .map(|(label, value)| {
            json!({
                "label": label,
                "value": value
            })
        })
        .collect();

    let body = json!({
        "content": content,
        "components": [{
            "type": 1,
            "components": [{
                "type": 3,
                "custom_id": custom_id,
                "options": select_options
            }]
        }]
    })
    .to_string();

    let token = GATEWAY_CLIENT.lock().unwrap().clone();
    if token.is_none() {
        return Err(PyErr::new::<pyo3::exceptions::PyRuntimeError, _>(
            "Gateway not connected"
        ));
    }

    let mut headers = HashMap::new();
    headers.insert("Authorization".to_string(), format!("Bot {}", token.unwrap()));

    crate::http::http_post_json(url, body, None)
}

/// Register gateway functions
pub fn register_gateway_functions(m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(gateway_on, m)?)?;
    m.add_function(wrap_pyfunction!(gateway_connect, m)?)?;
    m.add_function(wrap_pyfunction!(gateway_register_slash_command, m)?)?;
    m.add_function(wrap_pyfunction!(gateway_interaction_respond, m)?)?;
    m.add_function(wrap_pyfunction!(gateway_send_button, m)?)?;
    m.add_function(wrap_pyfunction!(gateway_send_select, m)?)?;
    Ok(())
}
