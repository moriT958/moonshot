// Entry point - exports functions for JavaScript

///|
fn main {
  // Entry point - game starts when game_init is called from JS
}

///|
pub fn game_init() -> Unit {
  @lib.game_init()
}

///|
pub fn update(delta : Double) -> Unit {
  @lib.update(delta)
}

///|
pub fn on_key_press(key : String) -> Unit {
  @lib.on_key_press(key)
}

///|
pub fn on_key_release(key : String) -> Unit {
  @lib.on_key_release(key)
}

///|
pub fn on_ws_message(message : String) -> Unit {
  @lib.on_ws_message(message)
}
