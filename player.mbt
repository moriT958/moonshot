// Player entity

pub enum Direction {
  Up
  Down
  Left
  Right
}

pub struct Player {
  id : String
  username : String
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  radius : Double
  speed : Double
  mut health : Int
  max_health : Int
  mut facing : Direction
  color : String
}

pub fn Player::new(
  id : String,
  username : String,
  x : Double,
  y : Double,
  color : String
) -> Player {
  {
    id,
    username,
    x,
    y,
    vx: 0.0,
    vy: 0.0,
    radius: 20.0,
    speed: 200.0,
    health: 100,
    max_health: 100,
    facing: Right,
    color,
  }
}

pub fn Player::update(self : Player, delta : Double) -> Unit {
  self.x = self.x + self.vx * delta
  self.y = self.y + self.vy * delta
}

pub fn Player::clamp_to_bounds(
  self : Player,
  width : Double,
  height : Double
) -> Unit {
  if self.x < self.radius {
    self.x = self.radius
  }
  if self.x > width - self.radius {
    self.x = width - self.radius
  }
  if self.y < self.radius {
    self.y = self.radius
  }
  if self.y > height - self.radius {
    self.y = height - self.radius
  }
}

pub fn Player::set_velocity(
  self : Player,
  move_left : Bool,
  move_right : Bool,
  move_up : Bool,
  move_down : Bool
) -> Unit {
  self.vx = 0.0
  self.vy = 0.0
  if move_left {
    self.vx = -self.speed
    self.facing = Left
  }
  if move_right {
    self.vx = self.speed
    self.facing = Right
  }
  if move_up {
    self.vy = -self.speed
    self.facing = Up
  }
  if move_down {
    self.vy = self.speed
    self.facing = Down
  }
}

pub fn Player::is_alive(self : Player) -> Bool {
  self.health > 0
}

pub fn Player::take_damage(self : Player, damage : Int) -> Unit {
  self.health = self.health - damage
  if self.health < 0 {
    self.health = 0
  }
}

pub fn Player::render(self : Player, ctx : CanvasContext) -> Unit {
  // Draw player circle
  set_fill_color(ctx, self.color)
  fill_circle(ctx, self.x, self.y, self.radius)

  // Draw health bar
  draw_health_bar(ctx, self.x, self.y, 40.0, self.health, self.max_health)

  // Draw username
  set_fill_color(ctx, "#FFFFFF")
  set_font(ctx, "12px Arial")
  set_text_align(ctx, "center")
  fill_text(ctx, self.username, self.x, self.y - 40.0)
}
