///|
/// プレーヤー

///|
priv struct Player {
  id : String
  username : String
  x : Double
  y : Double
  radius : Double
  health : Int
  max_health : Int
  color : String
}

///|
fn Player::is_alive(self : Player) -> Bool {
  self.health > 0
}

///|
fn Player::render(
  self : Player,
  ctx : @canvas.CanvasRenderingContext2D,
) -> Unit {
  // 外郭を描画
  set_fill_color(ctx, self.color)
  fill_circle(ctx, self.x, self.y, self.radius)

  // 体力バーを描画
  draw_health_bar(ctx, self.x, self.y, 40.0, self.health, self.max_health)

  // ユーザ名を描画
  set_fill_color(ctx, "#FFFFFF")
  set_font(ctx, "12px Arial")
  set_text_align(ctx, "center")
  fill_text(ctx, self.username, self.x, self.y - 40.0)
}
