///|
/// キーボード入力の制御

///|
priv struct InputState {
  mut move_left : Bool
  mut move_down : Bool
  mut move_up : Bool
  mut move_right : Bool
  mut shoot : Bool
}

///|
fn InputState::new() -> InputState {
  {
    move_left: false,
    move_down: false,
    move_up: false,
    move_right: false,
    shoot: false,
  }
}

///|
priv enum KeyCode {
  H
  J
  K
  L
  Space
  Other
}

///|
fn KeyCode::from_string(key : String) -> KeyCode {
  match key {
    "h" => H
    "j" => J
    "k" => K
    "l" => L
    " " => Space
    _ => Other
  }
}

///|
fn InputState::press_key(self : InputState, key : String) -> Unit {
  match KeyCode::from_string(key) {
    H => self.move_left = true
    J => self.move_down = true
    K => self.move_up = true
    L => self.move_right = true
    Space => self.shoot = true
    Other => ()
  }
}

///|
fn InputState::release_key(self : InputState, key : String) -> Unit {
  match KeyCode::from_string(key) {
    H => self.move_left = false
    J => self.move_down = false
    K => self.move_up = false
    L => self.move_right = false
    Space => self.shoot = false
    Other => ()
  }
}

///|
fn InputState::reset_shoot(self : InputState) -> Unit {
  self.shoot = false
}
