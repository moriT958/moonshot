// WebSocket FFI for multiplayer communication

// External type for WebSocket
type WebSocket

// WebSocket FFI functions
pub extern "js" fn ws_connect(url : String) -> WebSocket =
  #| (url) => {
  #|   const ws = new WebSocket(url);
  #|   ws.onopen = () => console.log('WebSocket connected');
  #|   ws.onerror = (e) => console.error('WebSocket error:', e);
  #|   ws.onclose = () => console.log('WebSocket closed');
  #|   ws.onmessage = (e) => {
  #|     try {
  #|       on_ws_message(e.data);
  #|     } catch(err) {
  #|       console.error('Error handling message:', err);
  #|     }
  #|   };
  #|   return ws;
  #| }

pub extern "js" fn ws_send(ws : WebSocket, message : String) -> Unit =
  #| (ws, msg) => { if (ws.readyState === WebSocket.OPEN) ws.send(msg); }

pub extern "js" fn ws_close(ws : WebSocket) -> Unit =
  #| (ws) => ws.close()

// Console logging for debugging
pub extern "js" fn console_log(message : String) -> Unit =
  #| (msg) => console.log(msg)
