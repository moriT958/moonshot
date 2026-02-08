///|
/// WebSocket 接続

///|
extern "js" fn create_websocket(url : String) -> @websocket.WebSocket =
  #| (url) => new WebSocket(url)

///|
fn ws_connect(url : String) -> @websocket.WebSocket {
  let ws = create_websocket(url)

  // Set event handlers
  ws.set_onopen(fn(_event) { @console.log(@core.any("WebSocket connected")) })
  ws.set_onerror(fn(event) {
    @console.error(@core.any("WebSocket error:"))
    @console.error(event)
  })
  ws.set_onclose(fn(_event) { @console.log(@core.any("WebSocket closed")) })
  ws.set_onmessage(fn(event) {
    let data = @websocket.get_message_data(event)
    on_ws_message(data)
  })
  ws
}

///|
fn ws_send(ws : @websocket.WebSocket, message : String) -> Unit {
  if ws.readyState == 1 {
    ws.send_string(message)
  }
}
