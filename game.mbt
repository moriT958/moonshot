// Game state and loop

pub struct GameState {
  player : Player
  input : InputState
  canvas_width : Double
  canvas_height : Double
  mut ctx : CanvasContext?
}

// Global game state
let game : GameState = {
  player: Player::new("local", "Player1", 400.0, 300.0, "#3498db"),
  input: InputState::new(),
  canvas_width: 800.0,
  canvas_height: 600.0,
  ctx: None,
}

// Initialize game (called from JS)
pub fn game_init() -> Unit {
  game.ctx = Some(get_context("game"))
  game.player.x = game.canvas_width / 2.0
  game.player.y = game.canvas_height / 2.0
}

// Update game state (called each frame with delta time in seconds)
pub fn update(delta : Double) -> Unit {
  // Apply input to player velocity
  game.player.set_velocity(
    game.input.move_left,
    game.input.move_right,
    game.input.move_up,
    game.input.move_down,
  )

  // Update player position
  game.player.update(delta)

  // Keep player in bounds
  game.player.clamp_to_bounds(game.canvas_width, game.canvas_height)

  // Render
  match game.ctx {
    Some(ctx) => render(ctx)
    None => ()
  }
}

// Render the game
fn render(ctx : CanvasContext) -> Unit {
  // Clear canvas with dark background
  set_fill_color(ctx, "#1a1a2e")
  fill_rect(ctx, 0.0, 0.0, game.canvas_width, game.canvas_height)

  // Render player
  game.player.render(ctx)

  // Render controls hint
  set_fill_color(ctx, "#888888")
  set_font(ctx, "14px Arial")
  set_text_align(ctx, "left")
  fill_text(ctx, "Controls: h/j/k/l to move, space to shoot", 10.0, 20.0)
}

// Handle key down (called from JS)
pub fn on_key_down(key_code : Int) -> Unit {
  game.input.handle_key_down(key_code)
}

// Handle key up (called from JS)
pub fn on_key_up(key_code : Int) -> Unit {
  game.input.handle_key_up(key_code)
}
