///|
/// WebSocket メッセージ処理

///|
pub fn on_ws_message(message : String) -> Unit {
  let msg_type = parse_message_type(message)
  if msg_type == "init" {
    handle_init_message(message)
  } else if msg_type == "state" {
    handle_state_message(message)
  }
}

///|
fn parse_message_type(message : String) -> String {
  let parsed : @core.Any = @core.json_parse(message)
  if @core.is_nullish(parsed) {
    return ""
  }
  let type_val = parsed._get("type")
  if @core.is_nullish(type_val) {
    ""
  } else {
    type_val.cast()
  }
}

///|
fn handle_init_message(message : String) -> Unit {
  let player_data = parse_init_player(message)
  game.local_player_id = player_data.0
  game.local_username = player_data.1
  game.connected = true
  mark_connected()
  @console.log(@core.any("Connected as: " + game.local_username))
  game.remote_players = []
}

///|
fn mark_connected() -> Unit {
  @global.globalThis()._set("_moonshot_connected", @core.any(true))
}

///|
fn parse_init_player(message : String) -> (String, String) {
  let parsed : @core.Any = @core.json_parse(message)
  if @core.is_nullish(parsed) {
    return ("", "")
  }
  let data = parsed._get("data")
  if @core.is_nullish(data) {
    return ("", "")
  }
  let player_id_val = data._get("playerId")
  let username_val = data._get("username")
  let player_id : String = if @core.is_nullish(player_id_val) {
    ""
  } else {
    player_id_val.cast()
  }
  let username : String = if @core.is_nullish(username_val) {
    ""
  } else {
    username_val.cast()
  }
  (player_id, username)
}

///|
fn handle_state_message(message : String) -> Unit {
  // Parse players from server
  let player_count = get_player_count(message)
  let new_remote_players : Array[Player] = []
  for i = 0; i < player_count; i = i + 1 {
    let p = get_player_at(message, i)
    if p.id == game.local_player_id {
      game.local_player = Some(p)
    } else {
      new_remote_players.push(p)
    }
  }
  game.remote_players = new_remote_players

  // Parse bullets from server
  let bullet_count = get_bullet_count(message)
  let new_bullets : Array[Bullet] = []
  for i = 0; i < bullet_count; i = i + 1 {
    new_bullets.push(get_bullet_at(message, i))
  }
  game.bullets = new_bullets
}

///|
fn get_player_count(message : String) -> Int {
  let parsed : @core.Any = @core.json_parse(message)
  if @core.is_nullish(parsed) {
    return 0
  }
  let data = parsed._get("data")
  if @core.is_nullish(data) {
    return 0
  }
  let players = data._get("players")
  if @core.is_nullish(players) {
    return 0
  }
  @core.object_keys(players).length()
}

///|
fn get_player_at(message : String, index : Int) -> Player {
  let parsed : @core.Any = @core.json_parse(message)
  let data = parsed._get("data")
  let players = data._get("players")
  let player_values = @core.object_values(players)
  let p = player_values[index]
  let id : String = p._get("id").cast()
  let username : String = p._get("username").cast()
  let x : Double = p._get("x").cast()
  let y : Double = p._get("y").cast()
  let health : Int = p._get("health").cast()
  let color_val = p._get("color")
  let color : String = if @core.is_nullish(color_val) {
    "#3498db"
  } else {
    color_val.cast()
  }
  { id, username, x, y, radius: 20.0, health, max_health: 100, color }
}

///|
fn get_bullet_count(message : String) -> Int {
  let parsed : @core.Any = @core.json_parse(message)
  if @core.is_nullish(parsed) {
    return 0
  }
  let data = parsed._get("data")
  if @core.is_nullish(data) {
    return 0
  }
  let bullets = data._get("bullets")
  if @core.is_nullish(bullets) {
    return 0
  }
  let arr : Array[@core.Any] = @core.array_from(bullets)
  arr.length()
}

///|
fn get_bullet_at(message : String, index : Int) -> Bullet {
  let parsed : @core.Any = @core.json_parse(message)
  let data = parsed._get("data")
  let bullets = data._get("bullets")
  let bullet_arr : Array[@core.Any] = @core.array_from(bullets)
  let b = bullet_arr[index]
  let x : Double = b._get("x").cast()
  let y : Double = b._get("y").cast()
  let radius_val = b._get("radius")
  let radius : Double = if @core.is_nullish(radius_val) {
    5.0
  } else {
    radius_val.cast()
  }
  let alive : Bool = b._get("alive").cast()
  { x, y, radius, alive }
}

///|
fn build_input_json(
  left : Bool,
  right : Bool,
  up : Bool,
  down : Bool,
) -> String {
  let left_str = if left { "true" } else { "false" }
  let right_str = if right { "true" } else { "false" }
  let up_str = if up { "true" } else { "false" }
  let down_str = if down { "true" } else { "false" }
  "{\"type\":\"input\",\"data\":{\"left\":" +
  left_str +
  ",\"right\":" +
  right_str +
  ",\"up\":" +
  up_str +
  ",\"down\":" +
  down_str +
  "}}"
}
