// Bullet entity

///|
pub struct Bullet {
  id : String
  owner_id : String
  mut x : Double
  mut y : Double
  vx : Double
  vy : Double
  radius : Double
  damage : Int
  mut alive : Bool
}

///|
let bullet_speed : Double = 400.0

///|
let bullet_radius : Double = 5.0

///|
let bullet_damage : Int = 25

///|
pub fn Bullet::new(
  id : String,
  owner_id : String,
  x : Double,
  y : Double,
  direction : Direction,
) -> Bullet {
  let (vx, vy) = match direction {
    Up => (0.0, -bullet_speed)
    Down => (0.0, bullet_speed)
    Left => (-bullet_speed, 0.0)
    Right => (bullet_speed, 0.0)
  }
  {
    id,
    owner_id,
    x,
    y,
    vx,
    vy,
    radius: bullet_radius,
    damage: bullet_damage,
    alive: true,
  }
}

///|
pub fn Bullet::update(self : Bullet, delta : Double) -> Unit {
  self.x = self.x + self.vx * delta
  self.y = self.y + self.vy * delta
}

///|
pub fn Bullet::is_out_of_bounds(
  self : Bullet,
  width : Double,
  height : Double,
) -> Bool {
  self.x < -self.radius ||
  self.x > width + self.radius ||
  self.y < -self.radius ||
  self.y > height + self.radius
}

///|
pub fn Bullet::render(self : Bullet, ctx : CanvasContext) -> Unit {
  set_fill_color(ctx, "#FFFF00")
  fill_circle(ctx, self.x, self.y, self.radius)
}
