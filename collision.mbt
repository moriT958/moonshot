// Collision detection

/// Check if two circles are colliding
pub fn circles_collide(
  x1 : Double,
  y1 : Double,
  r1 : Double,
  x2 : Double,
  y2 : Double,
  r2 : Double
) -> Bool {
  let dx = x2 - x1
  let dy = y2 - y1
  let distance_squared = dx * dx + dy * dy
  let radii_sum = r1 + r2
  distance_squared < radii_sum * radii_sum
}

/// Check if a bullet collides with a player
pub fn bullet_hits_player(bullet : Bullet, player : Player) -> Bool {
  // Don't check collision with owner
  if bullet.owner_id == player.id {
    return false
  }
  // Don't check if bullet is dead or player is dead
  if not(bullet.alive) || not(player.is_alive()) {
    return false
  }
  circles_collide(bullet.x, bullet.y, bullet.radius, player.x, player.y, player.radius)
}
