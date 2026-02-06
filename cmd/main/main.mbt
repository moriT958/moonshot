// Entry point - exports functions for JavaScript

fn main {
  // Entry point - game starts when game_init is called from JS
}

pub fn game_init() -> Unit {
  @lib.game_init()
}

pub fn update(delta : Double) -> Unit {
  @lib.update(delta)
}

pub fn on_key_down(key_code : Int) -> Unit {
  @lib.on_key_down(key_code)
}

pub fn on_key_up(key_code : Int) -> Unit {
  @lib.on_key_up(key_code)
}

pub fn on_ws_message(message : String) -> Unit {
  @lib.on_ws_message(message)
}
