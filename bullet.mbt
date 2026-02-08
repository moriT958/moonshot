///|
/// 弾丸

///|
priv struct Bullet {
  x : Double
  y : Double
  radius : Double
  alive : Bool
}

///|
fn Bullet::render(
  self : Bullet,
  ctx : @canvas.CanvasRenderingContext2D,
) -> Unit {
  set_fill_color(ctx, "#FFFF00")
  fill_circle(ctx, self.x, self.y, self.radius)
}
