///|
/// ゲーム全体の状態管理

///|
priv struct GameState {
  mut local_player_id : String
  mut local_username : String
  mut local_player : Player?
  mut remote_players : Array[Player]
  mut bullets : Array[Bullet]
  input : InputState
  canvas_width : Double
  canvas_height : Double
  mut ctx : @canvas.CanvasRenderingContext2D?
  mut ws : @websocket.WebSocket?
  mut connected : Bool
}

///|
let game : GameState = {
  local_player_id: "local",
  local_username: "Player1",
  local_player: None,
  remote_players: [],
  bullets: [],
  input: InputState::new(),
  canvas_width: 800.0,
  canvas_height: 600.0,
  ctx: None,
  ws: None,
  connected: false,
}

///|
pub fn game_init() -> Unit {
  game.ctx = Some(get_context("game"))

  // プレイヤー (自分) を作成
  game.local_player = Some(
    Player::new(
      "local",
      "Player1",
      game.canvas_width / 2.0,
      game.canvas_height / 2.0,
      "#3498db",
    ),
  )

  // WebSocket 接続
  let protocol = get_ws_protocol()
  let host = get_host()
  let ws_url = protocol + "://" + host + "/ws"
  @console.log(@core.any("Connecting to: " + ws_url))
  game.ws = Some(ws_connect(ws_url))
}

///|
fn get_ws_protocol() -> String {
  let loc = @location.location()
  if loc.protocol == "https:" {
    "wss"
  } else {
    "ws"
  }
}

///|
fn get_host() -> String {
  @location.location().host
}

///|
pub fn update(_delta : Double) -> Unit {
  handle_input()
  match game.ctx {
    Some(ctx) => render_game(ctx)
    None => ()
  }
}

///|
fn handle_input() -> Unit {
  match game.ws {
    Some(ws) => {
      let input_json = build_input_json(
        game.input.move_left,
        game.input.move_right,
        game.input.move_up,
        game.input.move_down,
      )
      ws_send(ws, input_json)
      if game.input.shoot {
        ws_send(ws, "{\"type\":\"shoot\"}")
        game.input.reset_shoot()
      }
    }
    None => ()
  }
}

///|
pub fn on_key_press(key_code : Int) -> Unit {
  game.input.press_key(key_code)
}

///|
pub fn on_key_release(key_code : Int) -> Unit {
  game.input.release_key(key_code)
}
