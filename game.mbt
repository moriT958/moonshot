// Game state and loop

pub struct GameState {
  mut local_player_id : String
  mut local_username : String
  mut local_player : Player?
  mut remote_players : Array[Player]
  mut bullets : Array[Bullet]
  input : InputState
  canvas_width : Double
  canvas_height : Double
  mut ctx : CanvasContext?
  mut ws : WebSocket?
  mut connected : Bool
  mut bullet_counter : Int
  offline_mode : Bool
}

// Global game state
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
  bullet_counter: 0,
  offline_mode: false,
}

// Initialize game (called from JS)
pub fn game_init() -> Unit {
  game.ctx = Some(get_context("game"))

  // Create local player immediately for offline mode
  game.local_player = Some(
    Player::new("local", "Player1", game.canvas_width / 2.0, game.canvas_height / 2.0, "#3498db"),
  )

  // Add dummy enemies for offline mode
  game.remote_players = [
    Player::new("bot1", "Bot1", 200.0, 200.0, "#e74c3c"),
    Player::new("bot2", "Bot2", 600.0, 400.0, "#9b59b6"),
  ]

  // Try to connect to WebSocket server
  let protocol = get_ws_protocol()
  let host = get_host()
  let ws_url = protocol + "://" + host + "/ws"
  console_log("Connecting to: " + ws_url)
  game.ws = Some(ws_connect(ws_url))

  // Set timeout to enable offline mode if connection fails
  set_offline_timeout()
}

// Set timeout to enable offline mode
extern "js" fn set_offline_timeout() -> Unit =
  #| () => {
  #|   setTimeout(() => {
  #|     if (!window._moonshot_connected) {
  #|       console.log('Server not available, running in offline mode');
  #|     }
  #|   }, 2000);
  #| }

// Get WebSocket protocol based on page protocol
extern "js" fn get_ws_protocol() -> String =
  #| () => window.location.protocol === 'https:' ? 'wss' : 'ws'

// Get host from window.location
extern "js" fn get_host() -> String =
  #| () => window.location.host

// Update game state (called each frame with delta time in seconds)
pub fn update(delta : Double) -> Unit {
  if game.connected {
    // Online mode: send input to server
    handle_input_online()
  } else {
    // Offline mode: handle locally
    handle_input_offline(delta)
  }

  // Render
  match game.ctx {
    Some(ctx) => render(ctx)
    None => ()
  }
}

// Handle input in online mode (send to server)
fn handle_input_online() -> Unit {
  match game.ws {
    Some(ws) => {
      // Send input state to server
      let input_json = build_input_json(
        game.input.move_left,
        game.input.move_right,
        game.input.move_up,
        game.input.move_down,
      )
      ws_send(ws, input_json)

      // Handle shooting
      if game.input.shoot {
        ws_send(ws, "{\"type\":\"shoot\"}")
        game.input.reset_shoot()
      }
    }
    None => ()
  }
}

// Handle input in offline mode (local physics)
fn handle_input_offline(delta : Double) -> Unit {
  match game.local_player {
    Some(player) => {
      // Apply input to player velocity
      player.set_velocity(
        game.input.move_left,
        game.input.move_right,
        game.input.move_up,
        game.input.move_down,
      )

      // Handle shooting
      if game.input.shoot {
        shoot_bullet_offline(player)
        game.input.reset_shoot()
      }

      // Update player position
      player.update(delta)

      // Keep player in bounds
      player.clamp_to_bounds(game.canvas_width, game.canvas_height)
    }
    None => ()
  }

  // Update bullets
  update_bullets_offline(delta)

  // Check bullet collisions
  check_bullet_collisions_offline()

  // Remove dead bullets
  game.bullets = game.bullets.filter(fn(b) { b.alive })
}

// Shoot a bullet in offline mode
fn shoot_bullet_offline(player : Player) -> Unit {
  if not(player.is_alive()) {
    return
  }
  game.bullet_counter = game.bullet_counter + 1
  let bullet_id = "bullet_" + game.bullet_counter.to_string()
  let bullet = Bullet::new(bullet_id, player.id, player.x, player.y, player.facing)
  game.bullets.push(bullet)
}

// Update bullets in offline mode
fn update_bullets_offline(delta : Double) -> Unit {
  for bullet in game.bullets {
    bullet.update(delta)
    if bullet.is_out_of_bounds(game.canvas_width, game.canvas_height) {
      bullet.alive = false
    }
  }
}

// Check bullet collisions in offline mode
fn check_bullet_collisions_offline() -> Unit {
  for bullet in game.bullets {
    if not(bullet.alive) {
      continue
    }
    for enemy in game.remote_players {
      if bullet_hits_player(bullet, enemy) {
        bullet.alive = false
        enemy.take_damage(bullet.damage)
      }
    }
  }
}

// Build JSON for input message
fn build_input_json(left : Bool, right : Bool, up : Bool, down : Bool) -> String {
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

// Handle WebSocket message (called from JS via FFI)
pub fn on_ws_message(message : String) -> Unit {
  let msg_type = parse_message_type(message)
  if msg_type == "init" {
    handle_init_message(message)
  } else if msg_type == "state" {
    handle_state_message(message)
  }
}

// Parse message type from JSON
extern "js" fn parse_message_type(message : String) -> String =
  #| (msg) => { try { return JSON.parse(msg).type || ''; } catch { return ''; } }

// Handle init message
fn handle_init_message(message : String) -> Unit {
  let player_data = parse_init_player(message)
  game.local_player_id = player_data.0
  game.local_username = player_data.1
  game.connected = true
  mark_connected()
  console_log("Connected as: " + game.local_username)

  // Clear offline players
  game.remote_players = []
}

// Mark as connected in JS
extern "js" fn mark_connected() -> Unit =
  #| () => { window._moonshot_connected = true; }

// Parse init message player data
extern "js" fn parse_init_player(message : String) -> (String, String) =
  #| (msg) => {
  #|   try {
  #|     const data = JSON.parse(msg).data;
  #|     return [data.playerId || '', data.username || ''];
  #|   } catch { return ['', '']; }
  #| }

// Handle state update message
fn handle_state_message(message : String) -> Unit {
  // Parse players from server
  let player_count = get_player_count(message)
  let new_remote_players : Array[Player] = []

  for i = 0; i < player_count; i = i + 1 {
    let p = get_player_at(message, i)
    if p.id == game.local_player_id {
      // Update local player
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

// Get player count from message
extern "js" fn get_player_count(message : String) -> Int =
  #| (msg) => {
  #|   try {
  #|     const data = JSON.parse(msg).data;
  #|     return Object.keys(data.players || {}).length;
  #|   } catch { return 0; }
  #| }

// Get player at index from message
extern "js" fn get_player_at(message : String, index : Int) -> Player =
  #| (msg, idx) => {
  #|   try {
  #|     const data = JSON.parse(msg).data;
  #|     const players = Object.values(data.players || {});
  #|     const p = players[idx];
  #|     if (!p) return null;
  #|     return {
  #|       id: p.id,
  #|       username: p.username,
  #|       x: p.x,
  #|       y: p.y,
  #|       vx: p.vx || 0,
  #|       vy: p.vy || 0,
  #|       radius: p.radius || 20,
  #|       speed: p.speed || 200,
  #|       health: p.health,
  #|       max_health: p.maxHealth || 100,
  #|       facing: p.facing || 'Right',
  #|       color: p.color || '#3498db'
  #|     };
  #|   } catch { return null; }
  #| }

// Get bullet count from message
extern "js" fn get_bullet_count(message : String) -> Int =
  #| (msg) => {
  #|   try {
  #|     const data = JSON.parse(msg).data;
  #|     return (data.bullets || []).length;
  #|   } catch { return 0; }
  #| }

// Get bullet at index from message
extern "js" fn get_bullet_at(message : String, index : Int) -> Bullet =
  #| (msg, idx) => {
  #|   try {
  #|     const data = JSON.parse(msg).data;
  #|     const b = (data.bullets || [])[idx];
  #|     if (!b) return null;
  #|     return {
  #|       id: b.id,
  #|       owner_id: b.ownerId,
  #|       x: b.x,
  #|       y: b.y,
  #|       vx: b.vx,
  #|       vy: b.vy,
  #|       radius: b.radius || 5,
  #|       damage: b.damage || 25,
  #|       alive: b.alive
  #|     };
  #|   } catch { return null; }
  #| }

// Render the game
fn render(ctx : CanvasContext) -> Unit {
  // Clear canvas with dark background
  set_fill_color(ctx, "#1a1a2e")
  fill_rect(ctx, 0.0, 0.0, game.canvas_width, game.canvas_height)

  // Render remote players
  for player in game.remote_players {
    if player.is_alive() {
      player.render(ctx)
    }
  }

  // Render local player
  match game.local_player {
    Some(player) => {
      if player.is_alive() {
        // Highlight local player with white ring
        set_stroke_color(ctx, "#FFFFFF")
        set_line_width(ctx, 3.0)
        stroke_circle(ctx, player.x, player.y, player.radius + 5.0)
        player.render(ctx)
      }
    }
    None => ()
  }

  // Render bullets
  for bullet in game.bullets {
    if bullet.alive {
      bullet.render(ctx)
    }
  }

  // Render UI
  render_ui(ctx)
}

// Render UI elements
fn render_ui(ctx : CanvasContext) -> Unit {
  set_fill_color(ctx, "#888888")
  set_font(ctx, "14px Arial")
  set_text_align(ctx, "left")
  fill_text(ctx, "Controls: h/j/k/l to move, space to shoot", 10.0, 20.0)

  // Connection status
  let status = if game.connected {
    "Online: " + game.local_username
  } else {
    "Offline mode (start server for multiplayer)"
  }
  fill_text(ctx, status, 10.0, 40.0)

  // Player count
  let player_count = game.remote_players.length() + 1
  fill_text(ctx, "Players: " + player_count.to_string(), 10.0, 60.0)
}

// Handle key down (called from JS)
pub fn on_key_down(key_code : Int) -> Unit {
  game.input.handle_key_down(key_code)
}

// Handle key up (called from JS)
pub fn on_key_up(key_code : Int) -> Unit {
  game.input.handle_key_up(key_code)
}
