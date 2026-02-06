// Keyboard input handling (vim-style: h/j/k/l + space)

pub struct InputState {
  mut move_left : Bool   // h
  mut move_down : Bool   // j
  mut move_up : Bool     // k
  mut move_right : Bool  // l
  mut shoot : Bool       // space
}

pub fn InputState::new() -> InputState {
  { move_left: false, move_down: false, move_up: false, move_right: false, shoot: false }
}

// Key codes
let key_h : Int = 72
let key_j : Int = 74
let key_k : Int = 75
let key_l : Int = 76
let key_space : Int = 32

pub fn InputState::handle_key_down(self : InputState, key_code : Int) -> Unit {
  if key_code == key_h {
    self.move_left = true
  } else if key_code == key_j {
    self.move_down = true
  } else if key_code == key_k {
    self.move_up = true
  } else if key_code == key_l {
    self.move_right = true
  } else if key_code == key_space {
    self.shoot = true
  }
}

pub fn InputState::handle_key_up(self : InputState, key_code : Int) -> Unit {
  if key_code == key_h {
    self.move_left = false
  } else if key_code == key_j {
    self.move_down = false
  } else if key_code == key_k {
    self.move_up = false
  } else if key_code == key_l {
    self.move_right = false
  } else if key_code == key_space {
    self.shoot = false
  }
}

pub fn InputState::reset_shoot(self : InputState) -> Unit {
  self.shoot = false
}
